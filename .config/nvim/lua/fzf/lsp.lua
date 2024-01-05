local M = {}

local core = require("fzf.core")
local helpers = require("fzf.helpers")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local undo_utils = require("utils.undo")
local uv_utils = require("utils.uv")
local jumplist = require("jumplist")

-- Tweaked from:
-- folke/trouble.nvim
-- https://github.com/folke/trouble.nvim/blob/main/lua/trouble/util.lua
local function make_lsp_position_param(win, buf)
  local row, col = unpack(vim.api.nvim_win_get_cursor(win))
  row = row - 1
  local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, true)[1]
  if not line then return { line = 0, character = 0 } end
  col = vim.str_utfindex(line, col)

  return { line = row, character = col }
end

local function make_lsp_text_document_param(buf)
  return { uri = vim.uri_from_bufnr(buf) }
end

local function uri_to_path(uri)
  return vim.fn.fnamemodify(vim.uri_to_fname(uri), ":~:.")
end

M.lsp_document_symbols = function(opts)
  -- TODO: integration w/ treesitter & initial pos
  opts = vim.tbl_extend("force", {}, opts or {})

  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()
  local current_file = vim.api.nvim_buf_get_name(buf)

  vim.lsp.buf_request(buf, "textDocument/documentSymbol", {
    textDocument = make_lsp_text_document_param(buf),
  }, function(err, result)
    if err then
      vim.notify(
        "An error happened querying language server: " .. err.message,
        vim.log.levels.ERROR
      )
      return
    end

    -- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#documentSymbol
    local entries = {}
    local symbols = {}
    local function process_items(items, indent)
      for _, s in ipairs(items) do
        table.insert(
          entries,
          fzf_utils.create_fzf_entry(
            string.rep("⋅", indent + 1),
            s.selectionRange.start.line + 1,
            s.selectionRange.start.character + 1,
            utils.ansi_codes.blue(
              vim.lsp.protocol.SymbolKind[s.kind] or "Unknown"
            ),
            s.name
          )
        )
        table.insert(symbols, s)
        if s.children then process_items(s.children, indent + 1) end
      end
    end

    process_items(result, 0)

    local function get_selection()
      local index = FZF.current_selection_index
      local symbol = symbols[index]
      return symbol
    end

    core.fzf(entries, {
      fzf_on_select = function()
        local symbol = get_selection()

        jumplist.save(win)
        vim.fn.cursor({
          symbol.selectionRange.start.line + 1,
          symbol.selectionRange.start.character + 1,
        })
        vim.cmd("normal! zz")
      end,
      fzf_preview_cmd = string.format(
        "bat %s --highlight-line {2} %s",
        helpers.bat_default_opts,
        current_file
      ),
      fzf_prompt = "LSP-Document-Symbols",
      fzf_on_focus = function() end,
      fzf_binds = vim.tbl_extend("force", helpers.custom_fzf_keybinds, {
        ["ctrl-w"] = function()
          local symbol = get_selection()
          core.abort_and_execute(function()
            vim.cmd(string.format([[vsplit %s]], current_file))
            vim.cmd(
              string.format(
                [[normal! %sG%s|]],
                symbol.selectionRange.start.line + 1,
                symbol.selectionRange.start.character + 1
              )
            )
            vim.cmd([[normal! zz]])
          end)
        end,
        ["ctrl-t"] = function()
          local symbol = get_selection()
          core.abort_and_execute(function()
            vim.cmd(string.format([[tabnew %s]], current_file))
            vim.cmd(
              string.format(
                [[normal! %sG%s|]],
                symbol.selectionRange.start.line + 1,
                symbol.selectionRange.start.character + 1
              )
            )
            vim.cmd([[normal! zz]])
          end)
        end,
      }),
      fzf_extra_args = helpers.fzf_default_args
        .. " --with-nth=1,4,5 "
        .. string.format(
          "--preview-window=%s,%s",
          helpers.fzf_default_preview_window_args,
          fzf_utils.fzf_initial_preview_scroll_offset(
            "{2}",
            { fixed_header = 3 }
          )
        ),
    })
  end)
end

M.lsp_workspace_symbols = function(opts)
  opts = vim.tbl_extend("force", {}, opts or {})

  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()
  local handle
  local current_symbols

  local function get_selection()
    local index = FZF.current_selection_index
    local symbol = current_symbols[index]
    return symbol
  end

  core.fzf({}, {
    fzf_on_query_change = function()
      local query = FZF.current_query

      if handle then
        handle() -- Cancel ongoing request
      end

      _, handle = vim.lsp.buf_request(buf, "workspace/symbol", {
        query = query,
      }, function(err, result)
        if err then
          vim.notify(
            "An error happened querying language server: " .. err.message,
            vim.log.levels.ERROR
          )
          return
        end

        -- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#workspaceSymbol
        local entries = {}
        local symbols = {}
        local function process_items(items)
          for _, s in ipairs(items) do
            table.insert(
              entries,
              fzf_utils.create_fzf_entry(
                utils.ansi_codes.grey(uri_to_path(s.location.uri)),
                s.location.range.start.line + 1,
                s.location.range.start.character + 1,
                utils.ansi_codes.blue(
                  vim.lsp.protocol.SymbolKind[s.kind] or "Unknown"
                ),
                s.name
              )
            )
            table.insert(symbols, s)
          end
        end

        process_items(result)

        current_symbols = symbols

        core.send_to_fzf(fzf_utils.generate_fzf_reload_action(entries))
      end)
    end,
    fzf_on_select = function()
      local symbol = get_selection()

      jumplist.save(win)
      vim.cmd("e " .. symbol.filename)
      vim.fn.cursor({ symbol.lnum, symbol.col })
      vim.cmd("normal! zz")
    end,
    fzf_preview_cmd = string.format(
      "bat %s --highlight-line {2} {1}",
      helpers.bat_default_opts
    ),
    fzf_prompt = "LSP-Workspace-Symbols",
    fzf_on_focus = function() end,
    fzf_binds = vim.tbl_extend("force", helpers.custom_fzf_keybinds, {
      ["ctrl-w"] = function()
        local symbol = get_selection()
        core.abort_and_execute(function()
          vim.cmd(string.format([[vsplit %s]], symbol.filename))
          vim.cmd(string.format([[normal! %sG%s|]], symbol.lnum, symbol.col))
          vim.cmd([[normal! zz]])
        end)
      end,
      ["ctrl-t"] = function()
        local symbol = get_selection()
        core.abort_and_execute(function()
          vim.cmd(string.format([[tabnew %s]], symbol.filename))
          vim.cmd(string.format([[normal! %sG%s|]], symbol.lnum, symbol.col))
          vim.cmd([[normal! zz]])
        end)
      end,
    }),
    fzf_extra_args = helpers.fzf_default_args
      .. " --with-nth=1,4,5 "
      .. string.format(
        "--preview-window=%s,%s",
        helpers.fzf_default_preview_window_args,
        fzf_utils.fzf_initial_preview_scroll_offset("{2}", { fixed_header = 3 })
      ),
  })
end

M.lsp_references = function(opts)
  opts = vim.tbl_extend("force", {}, opts or {})

  local win_id = vim.api.nvim_get_current_win()

  local handle = vim.lsp.buf.references({
    includeDeclaration = false,
  }, {
    on_list = function(list)
      local refs = list.items
      local context = list.context
      local title = list.title

      local entries = {}
      for _, r in ipairs(refs) do
        table.insert(
          entries,
          fzf_utils.create_fzf_entry(
            utils.ansi_codes.grey(vim.fn.fnamemodify(r.filename, ":~:.")),
            r.lnum,
            r.col,
            vim.trim(r.text)
          )
        )
      end

      local function get_selection()
        local index = FZF.current_selection_index
        local symbol = refs[index]
        return symbol
      end

      core.fzf(entries, {
        fzf_on_select = function()
          local symbol = get_selection()

          jumplist.save(win_id)
          vim.cmd("e " .. symbol.filename)
          vim.fn.cursor({ symbol.lnum, symbol.col })
          vim.cmd("normal! zz")
        end,
        fzf_preview_cmd = string.format(
          "bat %s --highlight-line {2} {1}",
          helpers.bat_default_opts
        ),
        fzf_prompt = "LSP-References",
        fzf_on_focus = function() end,
        fzf_binds = vim.tbl_extend("force", helpers.custom_fzf_keybinds, {
          ["ctrl-w"] = function()
            local symbol = get_selection()
            core.abort_and_execute(function()
              vim.cmd(string.format([[vsplit %s]], symbol.filename))
              vim.cmd(
                string.format([[normal! %sG%s|]], symbol.lnum, symbol.col)
              )
              vim.cmd([[normal! zz]])
            end)
          end,
          ["ctrl-t"] = function()
            local symbol = get_selection()
            core.abort_and_execute(function()
              vim.cmd(string.format([[tabnew %s]], symbol.filename))
              vim.cmd(
                string.format([[normal! %sG%s|]], symbol.lnum, symbol.col)
              )
              vim.cmd([[normal! zz]])
            end)
          end,
        }),
        fzf_extra_args = helpers.fzf_default_args
          .. " --with-nth=1,4 "
          .. string.format(
            "--preview-window=%s,%s",
            helpers.fzf_default_preview_window_args,
            fzf_utils.fzf_initial_preview_scroll_offset(
              "{2}",
              { fixed_header = 3 }
            )
          ),
      })
    end,
  })
end

M.lsp_declarations = function(opts)
  opts = vim.tbl_extend("force", {}, opts or {})

  local handle = vim.lsp.buf.declaration({
    on_list = function(list)
      vim.notify(list)
      -- TODO
    end,
  })
end

M.lsp_implementations = function(opts)
  opts = vim.tbl_extend("force", {}, opts or {})

  local handle = vim.lsp.buf.implementation({
    on_list = function(list) vim.notify(list) end,
    -- TODO
  })
end

M.lsp_definitions = function(opts)
  opts = vim.tbl_extend("force", {}, opts or {})

  local win_id = vim.api.nvim_get_current_win()

  local handle = vim.lsp.buf.definition({
    on_list = function(list)
      local defs = list.items
      local context = list.context
      local title = list.title

      local entries = {}
      for _, d in ipairs(defs) do
        table.insert(
          entries,
          fzf_utils.create_fzf_entry(
            utils.ansi_codes.grey(vim.fn.fnamemodify(d.filename, ":~:.")),
            d.lnum,
            d.col,
            vim.trim(d.text)
          )
        )
      end

      local function get_selection()
        local index = FZF.current_selection_index
        local symbol = defs[index]
        return symbol
      end

      core.fzf(entries, {
        fzf_on_select = function()
          local symbol = get_selection()

          jumplist.save(win_id)
          vim.cmd("e " .. symbol.filename)
          vim.fn.cursor({ symbol.lnum, symbol.col })
          vim.cmd("normal! zz")
        end,
        fzf_preview_cmd = string.format(
          "bat %s --highlight-line {2} {1}",
          helpers.bat_default_opts
        ),
        fzf_prompt = "LSP-Definitions",
        fzf_on_focus = function() end,
        fzf_binds = vim.tbl_extend("force", helpers.custom_fzf_keybinds, {
          ["ctrl-w"] = function()
            local symbol = get_selection()
            core.abort_and_execute(function()
              vim.cmd(string.format([[vsplit %s]], symbol.filename))
              vim.cmd(
                string.format([[normal! %sG%s|]], symbol.lnum, symbol.col)
              )
              vim.cmd([[normal! zz]])
            end)
          end,
          ["ctrl-t"] = function()
            local symbol = get_selection()
            core.abort_and_execute(function()
              vim.cmd(string.format([[tabnew %s]], symbol.filename))
              vim.cmd(
                string.format([[normal! %sG%s|]], symbol.lnum, symbol.col)
              )
              vim.cmd([[normal! zz]])
            end)
          end,
        }),
        fzf_extra_args = helpers.fzf_default_args
          .. " --with-nth=1,4 "
          .. string.format(
            "--preview-window=%s,%s",
            helpers.fzf_default_preview_window_args,
            fzf_utils.fzf_initial_preview_scroll_offset(
              "{2}",
              { fixed_header = 3 }
            )
          ),
      })
    end,
  })
end

M.lsp_type_definitions = function(opts)
  opts = vim.tbl_extend("force", {}, opts or {})

  local handle = vim.lsp.buf.type_definition({
    on_list = function(list)
      vim.notify(list)
      -- TODO
    end,
  })
end

M.lsp_code_actions = function(opts)
  opts = vim.tbl_extend("force", {}, opts or {})

  local handle = vim.lsp.buf.code_action({
    on_list = function(list)
      vim.notify(list)
      -- TODO
    end,
  })
end

M.lsp_diagnostics = function(opts)
  opts = vim.tbl_extend("force", {}, opts or {})

  -- TODO
end

return M
