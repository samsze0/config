require("notify").setup({
  background_colour = "NotifyBackground",
  fps = 30,
  icons = {
    DEBUG = "Debug",
    ERROR = "Error",
    INFO = "Info",
    TRACE = "Trace",
    WARN = "Warn",
  },
  level = 2,
  minimum_width = 50,
  timeout = 5000,
  top_down = true,
  render = "wrapped-compact",
  stages = "static",
})

vim.notify = require("notify")
