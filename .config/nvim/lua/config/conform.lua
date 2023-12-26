local config = require("config")

local prettier = { "prettierd", "prettier" }

-- https://github.com/mfussenegger/nvim-lint#available-linters
require("conform").setup({
  formatters_by_ft = {
    -- List: multiple formatters sequentially
    -- Sublist: only run the first available formatter
    lua = { "stylua" },
    javascript = { prettier },
    javascriptreact = { prettier },
    typescript = { prettier },
    typescriptreact = { prettier },
    json = { prettier },
    sh = { "shfmt" },
    zsh = { "shfmt" },
    bash = { "shfmt" },
  },
  format_on_save = config.format_on_save and {
    timeout_ms = 500,
    lsp_fallback = true,
  } or nil,
})
