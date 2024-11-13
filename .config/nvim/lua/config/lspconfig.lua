local safe_require = require("utils.lang").safe_require
local if_else = require("utils.lang").if_else
local nullish = require("utils.lang").nullish

---@module 'lspconfig'
local lspconfig = safe_require("lspconfig")
if not lspconfig then
  vim.warn("lspconfig module not found")
  return
end

---@module 'workspace-diagnostics'
local workspace_diagnostics = safe_require("workspace-diagnostics")

---@module 'schemastore'
local schemastore = safe_require("schemastore")

local on_attach = function(client, bufnr)
  nullish(workspace_diagnostics).populate_workspace_diagnostics(client, bufnr)
end

---@module 'cmp_nvim_lsp'
local cmp_nvim_lsp = safe_require("cmp_nvim_lsp")

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md

-- nvim-cmp supports more types of completion candidates than the default (omnifunc)
local capabilities = nullish(cmp_nvim_lsp).default_capabilities()

-- Rust
lspconfig.rust_analyzer.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

-- Configuration
lspconfig.taplo.setup({ -- TODO
  capabilities = capabilities,
  on_attach = on_attach,
})
-- See schemastore catalog
-- https://github.com/SchemaStore/schemastore/blob/master/src/api/json/catalog.json
lspconfig.jsonls.setup({
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    schemas = nullish(schemastore).json.schemas(),
    validate = { enable = true },
  },
})
lspconfig.yamlls.setup({
  on_attach = on_attach,
  settings = {
    yaml = {
      schemaStore = {
        -- You must disable built-in schemaStore support if you want to use
        -- this plugin and its advanced options like `ignore`.
        enable = false,
        -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
        url = "",
      },
      schemas = nullish(schemastore).yaml.schemas(),
    },
  },
})
lspconfig.lemminx.setup({ -- XML
  capabilities = capabilities,
  on_attach = on_attach,
})

-- Python
lspconfig.pyright.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})
lspconfig.ruff_lsp.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

-- Nix
lspconfig.nil_ls.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

-- Bash
lspconfig.bashls.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

-- Lua
lspconfig.lua_ls.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

-- Go
lspconfig.gopls.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

-- C/C++/Objective-C
lspconfig.clangd.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})
lspconfig.neocmake.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

-- Web
lspconfig.cssls.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})
lspconfig.tailwindcss.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})
lspconfig.html.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})
lspconfig.cssls.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})
lspconfig.tsserver.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

-- Docker
lspconfig.docker_compose_language_service.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

-- Terraform
lspconfig.terraformls.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})
lspconfig.tflint.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

-- Databases
lspconfig.postgres_lsp.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

-- Shading langauges
lspconfig.glsl_analyzer.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

-- Java
-- See also: ftplugin/java.lua
if not os.getenv("NVIM_USE_JDTLS") then
  lspconfig.jdtls.setup({
    capabilities = capabilities,
    on_attach = on_attach,
  })
end

-- Markdown
lspconfig.marksman.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})
