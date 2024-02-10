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

  local layout, popups, set_preview_content =
    helpers.create_nvim_preview_layout({
      preview_popup_win_options = {
        cursorline = true,
      },
    })

  core.fzf({}, {
    prompt = "LSP-Workspace-Symbols",
    layout = layout,
    binds = {
      ["+before-start"] = function(state)
        helpers.set_keymaps_for_preview_remote_nav(
          popups.main,
          popups.nvim_preview
        )
        helpers.set_keymaps_for_popups_nav({
          { popup = popups.main, key = "<C-s>", is_terminal = true },
          {
            popup = popups.nvim_preview,
            key = "<C-f>",
            is_terminal = false,
          },
        })
      end,
      ["focus"] = function(state)
        local symbol = current_symbols[state.focused_entry_index]

        popups.nvim_preview.border:set_text("top", " " .. symbol.name .. " ")

        helpers.preview_file(
          shared.uri_to_path(symbol.location.uri),
          popups.nvim_preview,
          {
            cursor_pos = {
              row = symbol.location.range.start.line + 1,
              col = symbol.location.range.start.character + 1,
            },
          }
        )
      end,
      ["ctrl-w"] = function(state)
        local symbol = current_symbols[state.focused_entry_index]

        core.abort_and_execute(state.id, function()
          vim.cmd(
            string.format(
              [[vsplit %s]],
              shared.uri_to_path(symbol.location.uri)
            )
          )
          vim.cmd(
            string.format(
              [[normal! %sG%s|]],
              symbol.location.range.start.line + 1,
              symbol.location.range.start.character + 1
            )
          )
          vim.cmd([[normal! zz]])
        end)
      end,
      ["ctrl-t"] = function(state)
        local symbol = current_symbols[state.focused_entry_index]

        core.abort_and_execute(state.id, function()
          vim.cmd(
            string.format(
              [[tabnew %s]],
              shared.uri_to_path(symbol.location.uri)
            )
          )
          vim.cmd(
            string.format(
              [[normal! %sG%s|]],
              symbol.location.range.start.line + 1,
              symbol.location.range.start.character + 1
            )
          )
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
        vim.cmd("e " .. shared.uri_to_path(symbol.location.uri))
        vim.fn.cursor({
          symbol.location.range.start.line + 1,
          symbol.location.range.start.character + 1,
        })
        vim.cmd("normal! zz")
      end,
    },
    extra_args = vim.tbl_extend("force", helpers.fzf_default_args, {
      ["--with-nth"] = "1,4,5..",
    }),
  })
end
