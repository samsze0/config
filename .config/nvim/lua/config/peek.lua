local peek = require("peek")

peek.setup({
  auto_load = true, -- whether to automatically load preview when opening a markdown file
  close_on_bdelete = true, -- close preview window on buffer delete
  syntax = true, -- enable syntax highlighting, affects performance
  theme = "light", -- 'dark' or 'light'
  update_on_change = true,
  app = "browser", -- 'webview', 'browser', string or a table of strings
  filetype = { "markdown" }, -- list of filetypes to recognize as markdown

  -- Below is relevant if update_on_change is true
  throttle_at = 200000, -- start throttling when file exceeds this amount of bytes in size
  throttle_time = "auto", -- minimum amount of time in milliseconds that has to pass before starting new render
})

vim.api.nvim_create_user_command("MarkdownPreviewOpen", peek.open, {})
vim.api.nvim_create_user_command("MarkdownPreviewClose", peek.close, {})