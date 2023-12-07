local config = require("m.config")

if config.nvim_dev_plugin == "neodev" then require("neodev").setup({}) end

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md

-- nvim-cmp supports more types of completion candidates than the default (omnifunc)
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Rust
require("lspconfig").rust_analyzer.setup({
  capabilities = capabilities,
})

-- Configuration
require("lspconfig").taplo.setup({ -- TODO
  capabilities = capabilities,
})
require("lspconfig").jsonls.setup({
  capabilities = capabilities,
})

-- Python
require("lspconfig").pyright.setup({
  capabilities = capabilities,
})
require("lspconfig").ruff_lsp.setup({ -- TODO
  capabilities = capabilities,
})

-- Nix
require("lspconfig").nil_ls.setup({
  capabilities = capabilities,
})

-- Bash
require("lspconfig").bashls.setup({
  capabilities = capabilities,
})

-- Lua
require("lspconfig").lua_ls.setup({
  capabilities = capabilities,
})

-- Go
require("lspconfig").gopls.setup({
  capabilities = capabilities,
})
require("lspconfig").golangci_lint_ls.setup({
  capabilities = capabilities,
})

-- C/C++
require("lspconfig").clangd.setup({
  capabilities = capabilities,
})
require("lspconfig").neocmake.setup({
  capabilities = capabilities,
})

-- Web
require("lspconfig").cssls.setup({ -- TODO
  capabilities = capabilities,
})
require("lspconfig").tailwindcss.setup({ -- TODO
  capabilities = capabilities,
})
require("lspconfig").html.setup({ -- TODO
  capabilities = capabilities,
})
require("lspconfig").cssls.setup({ -- TODO
  capabilities = capabilities,
})

-- Docker
require("lspconfig").docker_compose_language_service.setup({ -- TODO
  capabilities = capabilities,
})

-- Terraform
require("lspconfig").terraformls.setup({ -- TODO
  capabilities = capabilities,
})
require("lspconfig").tflint.setup({ -- TODO
  capabilities = capabilities,
})

-- Databases
require("lspconfig").postgres_lsp.setup({
  capabilities = capabilities,
})

-- Shading langauges
require("lspconfig").glsl_analyzer.setup({
  capabilities = capabilities,
})
