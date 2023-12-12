_G.notification_subscribers = {}
_G.notifications = {}
_G.notification_meta = {
  unread = {},
}

vim.notify = function(msg, level)
  level = level or vim.log.levels.OFF

  msg = vim.inspect(msg)
  print(msg)

  local t = os.time()
  local message = {
    message = msg,
    level = level,
    time = t,
  }
  table.insert(_G.notifications, message)

  _G.notification_meta.latest = message
  _G.notification_meta.unread[level] = (_G.notification_meta.unread[level] or 0)
    + 1

  for _, sub in ipairs(_G.notification_subscribers) do
    sub(message)
  end
end
