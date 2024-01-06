local utils = require("utils")

_G.notification_subscribers = {}
_G.notifications = {}
_G.notification_meta = {
  unread = {},
}

local function log_level_to_str(level)
  if level == vim.log.levels.ERROR then
    return "Error"
  elseif level == vim.log.levels.WARN then
    return "Warn"
  elseif level == vim.log.levels.INFO then
    return "Info"
  elseif level == vim.log.levels.DEBUG then
    return "Debug"
  elseif level == vim.log.levels.TRACE then
    return "Trace"
  else
    return "Unknown"
  end
end

local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event

local popup_config = {
  max_width = 30,
  max_height = 80,
}

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
  },
})
popup:mount()
popup:hide()

local timer = vim.loop.new_timer()

vim.notify = function(msg, level) ---@diagnostic disable-line: duplicate-set-field
  level = level or vim.log.levels.OFF

  if type(msg) ~= "string" then msg = vim.inspect(msg) end

  local t = os.time()
  local message = {
    message = msg,
    level = level,
    time = t,
  }
  table.insert(_G.notifications, message)

  vim.schedule(function()
    local lines = vim.split(msg, "\n")
    local cols = utils.max(lines, function(_, line) return string.len(line) end)
    vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, lines)
    popup:update_layout({
      size = {
        width = math.min(popup_config.max_height, cols),
        height = math.min(popup_config.max_height, #lines),
      },
    })
    popup:show()
    vim.api.nvim_win_set_option(
      popup.winid,
      "winhighlight",
      string.format("Normal:Notify%sNormal", log_level_to_str(level))
    )
    timer:stop()
    local success, _ = timer:start(
      level == vim.log.levels.ERROR and 5000 or 3000,
      0,
      vim.schedule_wrap(function() popup:hide() end)
    )
    if not success then print("Failed to start timer") end
  end)

  _G.notification_meta.latest = message
  _G.notification_meta.unread[level] = (_G.notification_meta.unread[level] or 0)
    + 1

  for _, sub in ipairs(_G.notification_subscribers) do
    vim.schedule(function() sub(message) end)
  end
end

local function format(...)
  local args = { ... }
  local tbl = utils.map(args, function(_, arg)
    if type(arg) ~= "string" then
      return vim.inspect(arg)
    else
      return arg
    end
  end)
  return table.concat(tbl, " ")
end

vim.error = function(...) vim.notify(format(...), vim.log.levels.ERROR) end

vim.warn = function(...) vim.notify(format(...), vim.log.levels.WARN) end

vim.info = function(...) vim.notify(format(...), vim.log.levels.INFO) end

vim.debug = function(...) vim.notify(format(...), vim.log.levels.DEBUG) end

vim.trace = function(...) vim.notify(format(...), vim.log.levels.TRACE) end
