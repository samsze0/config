local M = {}

local core = require("fzf.core")
local helpers = require("fzf.helpers")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local undo_utils = require("utils.undo")
local uv_utils = require("utils.uv")

M.lsp_implementations = function(opts)
  opts = vim.tbl_extend("force", {}, opts or {})

  local handle = vim.lsp.buf.implementation({
    on_list = function(impls)
      local entries = {}
      for _, im in ipairs(impls) do
      end
    end,
  })
end

M.lsp_document_symbols = function(opts)
  -- TODO: integration w/ treesitter & initial pos
  opts = vim.tbl_extend("force", {}, opts or {})

  local handle = vim.lsp.buf.document_symbol({
    on_list = function(list)
      local symbols = list.items
      local context = list.context
      local title = list.title

      local entries = {}
      for _, s in ipairs(symbols) do
        table.insert(
          entries,
          string.format(
            string.rep("%s", 5, utils.nbsp),
            vim.fn.fnamemodify(s.filename, ":~:."),
            s.lnum,
            s.col,
            utils.ansi_codes.blue(s.kind),
            string.gsub(s.text, "^%[%S+%] ", "")
          )
        )
      end

      local function get_selection()
        local index = FZF_STATE.current_selection_index
        local symbol = symbols[index]
        return symbol
      end

      core.fzf(entries, {
        fzf_on_select = function()
          local symbol = get_selection()

          vim.cmd("e " .. symbol.filename)
          vim.fn.cursor({ symbol.lnum, symbol.col })
          vim.cmd("normal! zz")
        end,
        fzf_preview_cmd = string.format(
          "bat %s --highlight-line {2} {1}",
          helpers.bat_default_opts
        ),
        fzf_prompt = "LSP Document Symbols",
        fzf_on_focus = function() end,
        fzf_binds = vim.tbl_extend("force", helpers.custom_fzf_keybinds, {}),
        fzf_extra_args = "--with-nth=4,5 " .. string.format(
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

M.lsp_workspace_symbols = function(opts)
  opts = vim.tbl_extend("force", {}, opts or {})

  local current_bufnr = vim.api.nvim_get_current_buf()
  local handle
  local current_symbols

  local function get_selection()
    local index = FZF_STATE.current_selection_index
    local symbol = current_symbols[index]
    return symbol
  end

  core.fzf({}, {
    fzf_on_query_change = function()
      local query = FZF_STATE.current_query

      if handle then
        handle() -- Cancel ongoing request
      end

      vim.api.nvim_buf_call(current_bufnr, function()
        handle = vim.lsp.buf.workspace_symbol(query, {
          on_list = function(list)
            local symbols = list.items
            local context = list.context
            local title = list.title

            local entries = {}
            for _, s in ipairs(symbols) do
              table.insert(
                entries,
                string.format(
                  string.rep("%s", 5, utils.nbsp),
                  utils.ansi_codes.grey(
                    vim.fn.fnamemodify(s.filename, ":~:.")
                  ),
                  s.lnum,
                  s.col,
                  utils.ansi_codes.blue(s.kind),
                  string.gsub(s.text, "^%[%S+%] ", "")
                )
              )
            end

            current_symbols = entries

            core.send_to_fzf(fzf_utils.generate_fzf_reload_action(entries))
          end,
        })
      end)
    end,
    fzf_on_select = function()
      local symbol = get_selection()

      vim.cmd("e " .. symbol.filename)
      vim.fn.cursor({ symbol.lnum, symbol.col })
      vim.cmd("normal! zz")
    end,
    fzf_preview_cmd = string.format(
      "bat %s --highlight-line {2} {1}",
      helpers.bat_default_opts
    ),
    fzf_prompt = "LSP Workspace Symbols",
    fzf_on_focus = function() end,
    fzf_binds = vim.tbl_extend("force", helpers.custom_fzf_keybinds, {}),
    fzf_extra_args = "--with-nth=1,4,5 "
      .. string.format(
        "--preview-window=%s,%s",
        helpers.fzf_default_preview_window_args,
        fzf_utils.fzf_initial_preview_scroll_offset("{2}", { fixed_header = 3 })
      ),
  })
end

return M
