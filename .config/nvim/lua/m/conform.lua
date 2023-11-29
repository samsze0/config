-- https://github.com/mfussenegger/nvim-lint#available-linters
require("conform").setup({
  formatters_by_ft = {
    -- List: multiple formatters sequentially
    -- Sublist: only run the first available formatter
    lua = { "stylua" },
    javascript = { { "prettierd", "prettier" } },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
})
