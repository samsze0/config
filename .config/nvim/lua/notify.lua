local utils = require("utils")
local format = require("utils").str_fmt

local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event

local config = {
  duration = {
    default = 3000,
    [vim.log.levels.ERROR] = 5000,
  },
  popup = {
    max_width = 30,
    max_height = 80,
  },
}

local M = {}

local notification_subscribers = {}

---@alias notification { message: string, level: number, time: number }

-- Subscribe to notifications
--
---@param callback fun(noti: notification)
M.subscribe = function(callback)
  table.insert(notification_subscribers, callback)
end

---@type notification[]
M.notifications = {}

---@type notification?
M.latest_notification = nil

---@type table<number, number>
M.unread_notifications = {}

-- Clear unread notifications
M.clear_unread = function() M.unread_notifications = {} end

-- Convert log level to string
--
---@param level number
---@return string
local function log_level_to_str(level)
  return utils.switch(level, {
    [vim.log.levels.ERROR] = "Error",
    [vim.log.levels.WARN] = "Warn",
    [vim.log.levels.INFO] = "Info",
    [vim.log.levels.DEBUG] = "Debug",
    [vim.log.levels.TRACE] = "Trace",
  }, "Unknown")
end

local popup = Popup({
  enter = false,
  focusable = true,
  border = {
    style = "none",
    -- vertical, horizontal padding
    padding = { 0, 0 },
  },
  anchor = "NE",
  position = {
    row = 2,
    col = vim.o.columns - 2,
  },
  relative = "editor",
  size = {
    width = 1,
    height = 1,
  },
  zindex = 100,
  buf_options = {
    filetype = "notify",
  },
  win_options = {
    winblend = 0,
    winhighlight = "Normal:NormalFloat",
    wrap = true,
  },
})
popup:mount()
popup:hide()

local timer = vim.loop.new_timer()

vim.notify = function(msg, level) ---@diagnostic disable-line: duplicate-set-field
  level = level or vim.log.levels.OFF

  if type(msg) ~= "string" then msg = vim.inspect(msg) end

  local t = os.time()
  local noti = {
    message = msg,
    level = level,
    time = t,
  }
  table.insert(M.notifications, noti)

  vim.schedule(function()
    local lines = vim.split(msg, "\n")
    local cols = utils.max(lines, function(_, line) return string.len(line) end)
    vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, lines)

    popup:update_layout({
      size = {
        width = math.min(config.popup.max_height, cols),
        height = math.min(config.popup.max_height, #lines),
      },
    })
    popup:show()

    vim.wo[popup.winid].winhighlight =
      string.format("Normal:Notify%sNormal", log_level_to_str(level))

    timer:stop()
    local success, _ = timer:start(
      config.duration[level] or config.duration.default,
      0,
      vim.schedule_wrap(function() popup:hide() end)
    )
    if not success then error("Failed to start timer") end
  end)

  M.latest_notification = noti
  M.unread_notifications[level] = (M.unread_notifications[level] or 0) + 1

  for _, sub in ipairs(notification_subscribers) do
    vim.schedule(function() sub(noti) end)
  end
end

vim.error = function(...) vim.notify(format(...), vim.log.levels.ERROR) end

vim.warn = function(...) vim.notify(format(...), vim.log.levels.WARN) end

vim.info = function(...) vim.notify(format(...), vim.log.levels.INFO) end

vim.debug = function(...) vim.notify(format(...), vim.log.levels.DEBUG) end

vim.trace = function(...) vim.notify(format(...), vim.log.levels.TRACE) end

return M
