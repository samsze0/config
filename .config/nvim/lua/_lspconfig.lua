-- nvim-cmp supports more types of completion candidates than the default (omnifunc)
local capabilities = require('cmp_nvim_lsp').default_capabilities()

require('lspconfig').rust_analyzer.setup({
  capabilities = capabilities,
})

require('lspconfig').pyright.setup({
  capabilities = capabilities,
})

require('lspconfig').nil_ls.setup({
  capabilities = capabilities,
})

require('lspconfig').bashls.setup({
  capabilities = capabilities,
})

require('lspconfig').lua_ls.setup({
  capabilities = capabilities,
})

require('lspconfig').gopls.setup({
  capabilities = capabilities,
})

require('lspconfig').clangd.setup({
  capabilities = capabilities,
})
