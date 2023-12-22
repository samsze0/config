local M = {}

local core = require("fzf.core")
local config = require("fzf.config")
local fzf_utils = require("fzf.utils")
local helpers = require("fzf.helpers")
local timeago = require("utils.timeago")
local utils = require("utils")

M.notifications = function(opts)
  local notify = vim.notify -- Restore vim.notify later
  vim.notify = function(...) end

  opts = vim.tbl_extend("force", {
    max_num_entries = 100,
  }, opts or {})

  local get_entries = function()
    local notifications = _G.notifications
    local num_unread = utils.sum(_G.notification_meta.unread)
    _G.notification_meta.unread = {} -- Clear unread

    local entries = {}
    for i = #notifications, 1, -1 do
      if #entries >= opts.max_num_entries then break end

      local noti = notifications[i]
      local level = noti.level
      local unread = #entries < num_unread
      if level == vim.log.levels.INFO then
        level = unread and utils.ansi_codes.blue("󰋼 ") or "󰋼 "
      elseif level == vim.log.levels.WARN then
        level = unread and utils.ansi_codes.yellow(" ") or " "
      elseif level == vim.log.levels.ERROR then
        level = unread and utils.ansi_codes.red(" ") or " "
      elseif level == vim.log.levels.DEBUG or level == vim.log.levels.TRACE then
        level = unread and utils.ansi_codes.grey(" ") or " "
      else
        level = unread and utils.ansi_codes.grey(" ") or " "
      end
      local brief = vim.fn.shellescape(noti.message)
      local parts = vim.split(brief, "\n")
      if #parts > 1 then brief = parts[1] end
      if not brief or brief == "" then brief = "<empty>" end
      local brief_max_length = 50
      brief = #brief > brief_max_length
          and brief:sub(1, brief_max_length - 3) .. "..."
        or utils.pad(brief, brief_max_length)
      table.insert(
        entries,
        fzf_utils.create_fzf_entry(
          level,
          timeago(noti.time),
          unread and utils.ansi_codes.white(brief) or brief
        )
      )
    end
    return entries
  end

  local entries = get_entries()

  local get_notification_from_selection = function(selection)
    local selection_index = FZF_STATE.current_selection_index
    selection = selection or FZF_STATE.current_selection

    return _G.notifications[#_G.notifications - selection_index + 1]
  end

  core.fzf(entries, {
    fzf_on_select = function() end,
    fzf_preview_cmd = nil,
    fzf_extra_args = helpers.fzf_default_args
      .. " --with-nth=1.. --preview-window="
      .. helpers.fzf_default_preview_window_args,
    fzf_prompt = "Notifications",
    fzf_initial_position = 1,
    fzf_on_focus = function()
      local noti = get_notification_from_selection()

      core.send_to_fzf(
        "change-preview:"
          .. string.format(
            [[bat %s --file-name "none" %s]],
            helpers.bat_default_opts,
            fzf_utils.write_to_tmpfile(noti.message)
          )
      )
    end,
    after_fzf = function() vim.notify = notify end, -- Restore vim.notify
    fzf_binds = vim.tbl_extend("force", helpers.custom_fzf_keybinds, {}),
  })
end

return M
