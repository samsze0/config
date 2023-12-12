local M = {}

local core = require("fzf.core")
local config = require("fzf.config")
local fzf_utils = require("fzf.utils")
local timeago = require("utils.timeago")
local utils = require("utils")

M.notifications = function(opts)
  opts = vim.tbl_extend("force", {}, opts or {})

  local get_entries = function()
    local notifications = _G.notifications
    local num_unread = utils.sum(_G.notification_meta.unread)

    local entries = {}
    for i = #notifications, 1, -1 do
      local noti = notifications[i]
      local level = noti.level
      if level == vim.log.levels.INFO then
        level = utils.ansi_codes.blue("󰋼 ")
      elseif level == vim.log.levels.WARN then
        level = utils.ansi_codes.yellow(" ")
      elseif level == vim.log.levels.ERROR then
        level = utils.ansi_codes.red(" ")
      elseif level == vim.log.levels.DEBUG or level == vim.log.levels.TRACE then
        level = utils.ansi_codes.grey(" ")
      else
        level = utils.ansi_codes.grey(" ")
      end
      local brief = vim.split(noti.message, "\n")[1]
      local brief_max_length = 50
      brief = #brief > brief_max_length
          and brief:sub(1, brief_max_length - 3) .. "..."
        or utils.pad(brief, brief_max_length)
      table.insert(
        entries,
        string.format(
          "%s%s%s%s%s",
          level,
          utils.nbsp,
          timeago(noti.time),
          utils.nbsp,
          i <= num_unread and utils.ansi_codes.white(brief) or brief
          -- utils.nbsp,
          -- noti.message -- Doesn't work if message contains newlines
        )
      )
    end
    return entries
  end

  local entries = get_entries()
  local tmpfile = os.tmpname()

  core.fzf(table.concat(entries, "\n"), function(selection) end, {
    fzf_preview_cmd = string.format(
      [[bat %s %s]],
      config.bat_default_opts,
      tmpfile
    ),
    fzf_extra_args = "--with-nth=1..",
    fzf_prompt = "Notifications❯ ",
    fzf_initial_position = 1,
    fzf_on_focus = function()
      local selection_index = FZF_CURRENT_SELECTION_INDEX
      if selection_index == -1 then
        vim.fn.writefile({ "No selection" }, tmpfile)
        return
      end

      vim.fn.writefile(
        vim.split(
          notifications[#notifications - selection_index + 1].message,
          "\n"
        ),
        tmpfile
      )
    end,
    fzf_binds = {},
  })
end

return M
