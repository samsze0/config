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

  core.fzf(get_entries(), {
    prompt = "Tabs",
    initial_position = current_tab,
    preview_cmd = string.format([[bat %s {2}]], helpers.bat_default_opts),
    binds = {
      ["+select"] = function(state)
        local tabnr = parse_entry(state.focused_entry)

        vim.cmd(string.format([[tabnext %s]], tabnr))
      end,
      ["ctrl-x"] = function(state)
        local tabnr = parse_entry(state.focused_entry)

        vim.cmd(string.format([[tabclose %s]], tabnr))
        core.send_to_fzf(fzf_utils.reload_action(get_entries()))
      end,
    },
    extra_args = vim.tbl_extend("force", helpers.fzf_default_args, {
      ["--with-nth"] = "1,3",
      ["--preview-window"] = helpers.fzf_default_preview_window_args,
    }),
  })
end
