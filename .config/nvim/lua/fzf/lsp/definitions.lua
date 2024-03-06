local core = require("fzf.core")
local helpers = require("fzf.helpers")
local fzf_utils = require("fzf.utils")
local layouts = require("fzf.layouts")
local utils = require("utils")
local shared = require("fzf.lsp.shared")
local jumplist = require("jumplist")

-- Fzf definitions of symbol under cursor
--
---@param opts? { }
return function(opts)
  opts = vim.tbl_extend("force", {}, opts or {})

  local current_win = vim.api.nvim_get_current_win()

  local handle = vim.lsp.buf.definition({
    on_list = function(list)
      local defs = list.items
      local context = list.context
      local title = list.title

      local entries = {}
      for _, d in ipairs(defs) do
        table.insert(
          entries,
          fzf_utils.join_by_delim(
            utils.ansi_codes.grey(vim.fn.fnamemodify(d.filename, ":~:.")),
            d.lnum,
            d.col,
            vim.trim(d.text)
          )
        )
      end

      local parse_entry = function(entry)
        local args = vim.split(entry, utils.nbsp)
        return unpack(args)
      end

      local layout, popups, set_preview_content, binds =
        layouts.create_nvim_preview_layout({
          preview_popup_win_options = {
            cursorline = true,
          },
        })

      core.fzf(entries, {
        prompt = "LSP-Definitions",
        layout = layout,
        main_popup = popups.main,
        binds = fzf_utils.bind_extend(binds, {
          ["+before-start"] = function(state)
            popups.main.border:set_text(
              "bottom",
              " <select> goto | <w> goto (window) | <t> goto (tab) "
            )
          end,
          ["focus"] = function(state)
            local symbol = defs[state.focused_entry_index]

            popups.nvim_preview.border:set_text(
              "top",
              " " .. vim.fn.fnamemodify(symbol.filename, ":t") .. " "
            )

            helpers.preview_file(
              symbol.filename,
              popups.nvim_preview,
              { cursor_pos = { row = symbol.lnum, col = symbol.col } }
            )
          end,
          ["+select"] = function(state)
            local symbol = defs[state.focused_entry_index]

            jumplist.save(current_win)
            vim.cmd("e " .. symbol.filename)
            vim.fn.cursor({ symbol.lnum, symbol.col })
            vim.cmd("normal! zz")
          end,
          ["ctrl-w"] = function(state)
            local symbol = defs[state.focused_entry_index]

            core.abort_and_execute(state.id, function()
              vim.cmd(string.format([[vsplit %s]], symbol.filename))
              vim.cmd(
                string.format([[normal! %sG%s|]], symbol.lnum, symbol.col)
              )
              vim.cmd([[normal! zz]])
            end)
          end,
          ["ctrl-t"] = function(state)
            local symbol = defs[state.focused_entry_index]

            core.abort_and_execute(state.id, function()
              vim.cmd(string.format([[tabnew %s]], symbol.filename))
              vim.cmd(
                string.format([[normal! %sG%s|]], symbol.lnum, symbol.col)
              )
              vim.cmd([[normal! zz]])
            end)
          end,
        }),
        extra_args = vim.tbl_extend("force", helpers.fzf_default_args, {
          ["--with-nth"] = "1,4",
        }),
      })
    end,
  })
end
