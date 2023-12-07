return {
  dir = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/"),
  session_options = { "buffers", "curdir", "tabpages", "winsize", "skiprtp" },
}
