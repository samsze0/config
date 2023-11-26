-- https://github.com/mfussenegger/nvim-lint#available-linters
require('conform').setup({
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
})
