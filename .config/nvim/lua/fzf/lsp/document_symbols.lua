local core = require("fzf.core")
local helpers = require("fzf.helpers")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local shared = require("fzf.lsp.shared")
local jumplist = require("jumplist")

-- TODO: integration w/ treesitter to support initial pos

-- Fzf all symbols in current document
--
---@param opts? { }
return function(opts)
  opts = vim.tbl_extend("force", {}, opts or {})

  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()
  local current_file = vim.api.nvim_buf_get_name(buf)

  -- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#documentSymbol
  vim.lsp.buf_request(buf, "textDocument/documentSymbol", {
    textDocument = shared.make_lsp_text_document_param(buf),
  }, function(err, result)
    if err then
      vim.error("An error happened querying language server", err)
      return
    end

    local entries = {}
    local symbols = {}

    local function process_list(items, indent)
      indent = indent or 0

      for _, s in ipairs(items) do
        table.insert(
          entries,
          fzf_utils.join_by_delim(
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
        if s.children then process_list(s.children, indent + 1) end
      end
    end

    process_list(result)

    core.fzf(entries, {
      prompt = "LSP-Document-Symbols",
      preview_cmd = string.format(
        "bat %s --highlight-line {2} %s",
        helpers.bat_default_opts,
        current_file
      ),
      binds = vim.tbl_extend("force", helpers.default_fzf_keybinds, {
        ["ctrl-w"] = function(state)
          local symbol = symbols[state.focused_entry_index]

          core.abort_and_execute(state.id, function()
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
        ["ctrl-t"] = function(state)
          local symbol = symbols[state.focused_entry_index]

          core.abort_and_execute(state.id, function()
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
        ["+select"] = function(state)
          local symbol = symbols[state.focused_entry_index]

          jumplist.save(win)
          vim.fn.cursor({
            symbol.selectionRange.start.line + 1,
            symbol.selectionRange.start.character + 1,
          })
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
  end)
end
