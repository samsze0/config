local M = {}

local core = require("fzf.core")
local config = require("fzf.config")
local fzf_utils = require("fzf.utils")
local utils = require("utils")

local fn = vim.fn

M.tabs = function()
  local function get_entries()
    local entries = utils.map(fn.gettabinfo(), function(_, tab)
      local tabnr = tab.tabnr

      return string.format(
        "%s%s%s",
        tabnr,
        utils.nbsp,
        utils.ansi_codes.blue(
          (true and _G.tabs[tabnr].full or _G.tabs[tabnr].display) or "  "
        )
      )
    end)
    return entries
  end

  local current_tabnr = fn.tabpagenr()

  core.fzf(table.concat(get_entries(), "\n"), function(selection)
    local tabnr = vim.split(selection[1], utils.nbsp)[1]
    vim.cmd(string.format([[tabnext %s]], tabnr))
  end, {
    fzf_preview_cmd = nil,
    fzf_extra_args = "--with-nth=1..",
    fzf_prompt = "Tabs",
    fzf_initial_position = current_tabnr,
    fzf_binds = {
      ["ctrl-x"] = function()
        local current_selection = FZF_CURRENT_SELECTION

        local tabnr = vim.split(current_selection, utils.nbsp)[1]
        vim.cmd(string.format([[tabclose %s]], tabnr))
        core.send_to_fzf(
          string.format(
            "track+reload(%s)",
            string.format(
              [[cat <<EOF
%s
EOF]],
              table.concat(get_entries(), "\n")
            )
          )
        )
      end,
    },
    fzf_on_focus = function(selection) end,
  })
end

return M
