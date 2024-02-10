local core = require("fzf.core")
local fzf_utils = require("fzf.utils")
local helpers = require("fzf.helpers")
local utils = require("utils")

local fn = vim.fn

-- Fzf tabs
return function()
  local function get_entries()
    local entries = utils.map(fn.gettabinfo(), function(_, tab)
      local tabnr = tab.tabnr

      return fzf_utils.join_by_delim(
        tabnr,
        _G.tabs[tabnr].full or "  ",
        utils.ansi_codes.blue(_G.tabs[tabnr].display or "  ")
      )
    end)
    return entries
  end

  local current_tab = fn.tabpagenr()

  local parse_entry = function(entry)
    return unpack(vim.split(entry, utils.nbsp))
  end

  local layout, popups, set_preview_content =
    helpers.create_nvim_preview_layout({
      preview_popup_win_options = {},
    })

  core.fzf(get_entries(), {
    prompt = "Tabs",
    layout = layout,
    initial_position = current_tab,
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
        local tabnr, filepath = parse_entry(state.focused_entry)

        popups.nvim_preview.border:set_text(
          "top",
          " " .. vim.fn.fnamemodify(filepath, ":t") .. " "
        )

        helpers.preview_file(filepath, popups.nvim_preview)
      end,
      ["+select"] = function(state)
        local tabnr = parse_entry(state.focused_entry)

        vim.cmd(string.format([[tabnext %s]], tabnr))
      end,
      ["ctrl-x"] = function(state)
        local tabnr = parse_entry(state.focused_entry)

        vim.cmd(string.format([[tabclose %s]], tabnr))
        core.send_to_fzf(state.id, fzf_utils.reload_action(get_entries()))
      end,
    },
    extra_args = vim.tbl_extend("force", helpers.fzf_default_args, {
      ["--with-nth"] = "1,3",
    }),
  })
end
