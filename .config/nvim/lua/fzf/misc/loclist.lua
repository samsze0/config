local core = require("fzf.core")
local fzf_utils = require("fzf.utils")
local helpers = require("fzf.helpers")
local utils = require("utils")

local fn = vim.fn

-- Fzf the most recent loclist of current window
--
---@param opts? { }
return function(opts)
  opts = vim.tbl_extend("force", {}, opts or {})

  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()

  local function get_entries()
    local ll = vim.fn.getloclist(win)

    return utils.map(
      ll,
      function(_, l)
        return fzf_utils.join_by_delim(
          l.bufnr,
          utils.ansi_codes.grey(
            vim.fn.fnamemodify(vim.api.nvim_buf_get_name(l.bufnr), ":~:.")
          ),
          l.lnum,
          l.col,
          l.text
        )
      end
    )
  end

  local entries = get_entries()

  local parse_entry = function(entry)
    return unpack(vim.split(entry, utils.nbsp))
  end

  local layout, popups, set_preview_content =
    helpers.create_nvim_preview_layout({
      preview_popup_win_options = {
        cursorline = true,
      },
    })

  core.fzf(entries, {
    prompt = "Loclist",
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
        local bufnr, filepath, row, col = parse_entry(state.focused_entry)

        popups.nvim_preview.border:set_text(
          "top",
          " " .. vim.fn.fnamemodify(filepath, ":t") .. " "
        )

        helpers.preview_file(
          filepath,
          popups.nvim_preview,
          { cursor_pos = { row = row, col = col } }
        )
      end,
      ["+select"] = function(state)
        local bufnr = parse_entry(state.focused_entry)

        vim.cmd(string.format([[buffer %s]], bufnr))
      end,
      ["ctrl-w"] = function(state)
        vim.cmd([[ldo update]]) -- Write all changes
      end,
    },
    extra_args = vim.tbl_extend("force", helpers.fzf_default_args, {
      ["--with-nth"] = "2,5",
    }),
  })
end
