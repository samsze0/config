local config = require("config")

-- https://github.com/mfussenegger/nvim-lint#available-linters
require("conform").setup({
  formatters_by_ft = {
    -- List: multiple formatters sequentially
    -- Sublist: only run the first available formatter
    lua = { "stylua" },
    javascript = { { "prettierd", "prettier" } },
    json = { { "prettierd", "prettier" } },
    sh = { "shfmt" },
    zsh = { "shfmt" },
    bash = { "shfmt" },
  },
  format_on_save = config.format_on_save and {
    timeout_ms = 500,
    lsp_fallback = true,
  } or nil,
})
