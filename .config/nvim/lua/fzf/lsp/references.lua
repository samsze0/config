local core = require("fzf.core")
local helpers = require("fzf.helpers")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local shared = require("fzf.lsp.shared")
local jumplist = require("jumplist")

-- Fzf references of symbol under cursor
--
---@param opts? { }
return function(opts)
  opts = vim.tbl_extend("force", {}, opts or {})

  local win = vim.api.nvim_get_current_win()

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
          fzf_utils.join_by_delim(
            utils.ansi_codes.grey(vim.fn.fnamemodify(r.filename, ":~:.")),
            r.lnum,
            r.col,
            vim.trim(r.text)
          )
        )
      end

      core.fzf(entries, {
        prompt = "LSP-References",
        preview_cmd = string.format(
          "bat %s --highlight-line {2} {1}",
          helpers.bat_default_opts
        ),
        binds = vim.tbl_extend("force", helpers.default_fzf_keybinds, {
          ["+select"] = function(state)
            local symbol = refs[state.focused_entry_index]

            jumplist.save(win)
            vim.cmd("e " .. symbol.filename)
            vim.fn.cursor({ symbol.lnum, symbol.col })
            vim.cmd("normal! zz")
          end,
          ["ctrl-w"] = function(state)
            local symbol = refs[state.focused_entry_index]

            core.abort_and_execute(state.id, function()
              vim.cmd(string.format([[vsplit %s]], symbol.filename))
              vim.cmd(
                string.format([[normal! %sG%s|]], symbol.lnum, symbol.col)
              )
              vim.cmd([[normal! zz]])
            end)
          end,
          ["ctrl-t"] = function(state)
            local symbol = refs[state.focused_entry_index]

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
          ["--preview-window"] = string.format(
            [['%s,%s']],
            helpers.fzf_default_preview_window_args,
            fzf_utils.preview_offset("{2}", { fixed_header = 3 })
          ),
        }),
      })
    end,
  })
end
