local M = {}

local core = require("fzf.core")
local helpers = require("fzf.helpers")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local jumplist = require("jumplist")

local fn = vim.fn

-- Show jump tree
--
---@param opts? { max_num_entries?: number }
M.jumps = function(opts)
  opts = vim.tbl_extend("force", {
    max_num_entries = 100,
  }, opts or {})

  ---@type jump[]
  local jumps

  local pos

  local current_win = vim.api.nvim_get_current_win()

  local function get_entries()
    jumps, pos = jumplist.get_jumps_as_list(
      current_win,
      { max_num_entries = opts.max_num_entries }
    )
    pos = pos or 0

    return utils.map(
      jumps,
      function(_, e)
        return fzf_utils.join_by_delim(
          utils.ansi_codes.grey(e.filename),
          e.line,
          e.col,
          e.text
        )
      end
    )
  end

  local parse_entry = function(entry)
    local args = vim.split(entry, utils.nbsp)
    return unpack(args)
  end

  local layout, popups, set_preview_content =
    helpers.create_nvim_preview_layout({
      preview_popup_win_options = {
        cursorline = true,
      },
    })

  core.fzf(get_entries(), {
    prompt = "Jumps",
    layout = layout,
    main_popup = popups.main,
    initial_position = pos,
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
        local filepath, row, col = parse_entry(state.focused_entry)

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
        local jump = jumps[state.focused_entry_index]

        vim.cmd(string.format([[e %s]], jump.filename))
        vim.cmd(string.format([[normal! %sG%s|]], jump.line, jump.col))
      end,
    },
  })
end

return M
