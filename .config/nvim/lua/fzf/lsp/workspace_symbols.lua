local core = require("fzf.core")
local helpers = require("fzf.helpers")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local shared = require("fzf.lsp.shared")
local jumplist = require("jumplist")

-- Fzf all symbols in workspace
--
---@param opts? { }
return function(opts)
  opts = vim.tbl_extend("force", {}, opts or {})

  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()
  local handle
  local current_symbols

  core.fzf({}, {
    prompt = "LSP-Workspace-Symbols",
    preview_cmd = string.format(
      "bat %s --highlight-line {2} {1}",
      helpers.bat_default_opts
    ),
    binds = vim.tbl_extend("force", helpers.default_fzf_keybinds, {
      ["ctrl-w"] = function(state)
        local symbol = current_symbols[state.focused_entry_index]

        core.abort_and_execute(state.id, function()
          vim.cmd(string.format([[vsplit %s]], symbol.filename))
          vim.cmd(string.format([[normal! %sG%s|]], symbol.lnum, symbol.col))
          vim.cmd([[normal! zz]])
        end)
      end,
      ["ctrl-t"] = function(state)
        local symbol = current_symbols[state.focused_entry_index]

        core.abort_and_execute(state.id, function()
          vim.cmd(string.format([[tabnew %s]], symbol.filename))
          vim.cmd(string.format([[normal! %sG%s|]], symbol.lnum, symbol.col))
          vim.cmd([[normal! zz]])
        end)
      end,
      ["change"] = function(state)
        local query = state.query

        if handle then
          handle() -- Cancel ongoing request
        end

        -- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#workspaceSymbol
        _, handle = vim.lsp.buf_request(buf, "workspace/symbol", {
          query = query,
        }, function(err, result)
          if err then
            vim.error("An error happened querying language server", err.message)
            return
          end

          local entries = {}
          local symbols = {}

          local function process_list(items)
            for _, s in ipairs(items) do
              table.insert(
                entries,
                fzf_utils.join_by_delim(
                  utils.ansi_codes.grey(shared.uri_to_path(s.location.uri)),
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

          process_list(result)
          current_symbols = symbols

          core.send_to_fzf(state.id, fzf_utils.reload_action(entries))
        end)
      end,
      ["+select"] = function(state)
        local symbol = current_symbols[state.focused_entry_index]

        jumplist.save(win)
        vim.cmd("e " .. symbol.filename)
        vim.fn.cursor({ symbol.lnum, symbol.col })
        vim.cmd("normal! zz")
      end,
    }),
    extra_args = vim.tbl_extend("force", helpers.fzf_default_args, {
      ["--with-nth"] = "1,4,5..",
      ["--preview-window"] = string.format(
        [['%s,%s']],
        helpers.fzf_default_preview_window_args,
        fzf_utils.preview_offset("{2}", { fixed_header = 3 })
      ),
    }),
  })
end
