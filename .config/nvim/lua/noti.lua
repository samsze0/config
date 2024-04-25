local utils = require("utils")
local format = require("utils").str_fmt

local NuiPopup = require("nui.popup")

-- Could have impl this as a class, but not necessary

-- TODO: support marking individual notification as read/unread.
-- This would mean we have to iterate over all the notifications in order to find out
-- the list of unread ones. So we leave this out for now for performance reasons

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

---@alias Notification { message: string, level: number, time: number }

---@type Notification[]
local notifications = {}

---@alias NotificationSubscriber fun(noti: Notification)

---@type NotificationSubscriber[]
local subscribers = {}

---@type number Number of unread notifications
local _num_unread = 0

-- Subscribe to notifications
--
---@param callback NotificationSubscriber
M.subscribe = function(callback) table.insert(subscribers, callback) end

---@return Notification[]
M.all = function() return notifications end

---@return Notification?
M.latest = function() return notifications[#notifications] end

---@return Notification[]
M.unread = function()
  -- TODO: refactor by creating a slice function

  if _num_unread == 0 then return {} end

  local result = {}
  for i = 1, #_num_unread do
    table.insert(result, notifications[i])
  end
  return result
end

-- Clear unread notifications
M.clear_unread = function() _num_unread = 0 end

-- Number of unread notifications
--
---@return number
M.num_unread = function() return _num_unread end

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

local popup = NuiPopup({
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
    filetype = "noti",
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
  local n = {
    message = msg,
    level = level,
    time = t,
  }
  table.insert(notifications, 1, n)
  _num_unread = _num_unread + 1

  vim.schedule(function()
    local lines = vim.split(msg, "\n")
    local cols = utils.max(lines, function(_, line) return string.len(line) end)
    vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, lines)

    popup:update_layout({
      size = {
        width = math.min(config.popup.max_width, cols),
        height = math.min(config.popup.max_height, #lines),
      },
    })
    popup:show()

    vim.wo[popup.winid].winhighlight = ("Normal:Noti%s"):format(
      log_level_to_str(level)
    )

    if timer:is_active() then
      local ok, err = timer:stop()
      assert(ok, err)
    end
    local ok, err = timer:start(
      config.duration[level] or config.duration.default,
      0,
      vim.schedule_wrap(function() popup:hide() end)
    )
    assert(ok, err)
  end)

  for _, sub in ipairs(subscribers) do
    vim.schedule(function() sub(n) end)
  end
end

vim.error = function(...) vim.notify(format(...), vim.log.levels.ERROR) end

vim.warn = function(...) vim.notify(format(...), vim.log.levels.WARN) end

vim.info = function(...) vim.notify(format(...), vim.log.levels.INFO) end

vim.debug = function(...) vim.notify(format(...), vim.log.levels.DEBUG) end

vim.trace = function(...) vim.notify(format(...), vim.log.levels.TRACE) end

return M
