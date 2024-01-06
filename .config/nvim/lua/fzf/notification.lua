local M = {}

local core = require("fzf.core")
local fzf_utils = require("fzf.utils")
local helpers = require("fzf.helpers")
local timeago = require("utils.timeago")
local utils = require("utils")

-- Fzf all notifications
--
---@param opts? { max_num_enxtires?: integer }
M.notifications = function(opts)
  local notify = vim.notify -- Restore vim.notify later
  vim.notify = function(...) end ---@diagnostic disable-line: duplicate-set-field

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
      local brief = noti.message
      local parts = vim.split(brief, "\n")
      if #parts > 1 then brief = parts[1] end
      if not brief or brief == "" then brief = "<empty>" end
      local brief_max_length = 50
      brief = #brief > brief_max_length
          and brief:sub(1, brief_max_length - 3) .. "..."
        or utils.pad_string(brief, brief_max_length)
      table.insert(
        entries,
        fzf_utils.join_by_delim(
          level,
          timeago(noti.time),
          unread and utils.ansi_codes.white(brief) or brief
        )
      )
    end
    return entries
  end

  local get_notification = function(index)
    return _G.notifications[#_G.notifications - index + 1]
  end

  core.fzf(get_entries(), {
    prompt = "Notifications",
    initial_position = 1,
    binds = vim.tbl_extend("force", helpers.default_fzf_keybinds, {
      ["focus"] = function(state)
        local noti = get_notification(state.focused_entry_index)

        core.send_to_fzf(
          "change-preview:"
            .. string.format(
              [[bat %s --file-name "none" %s]],
              helpers.bat_default_opts,
              fzf_utils.write_to_tmpfile(noti.message)
            )
        )
      end,
      ["+after-exit"] = function(state) vim.notify = notify end, -- Restore vim.notify
    }),
    extra_args = vim.tbl_extend("force", helpers.fzf_default_args, {
      ["--with-nth"] = "1..",
      ["--preview-window"] = helpers.fzf_default_preview_window_args,
    }),
  })
end

return M
