require("neoconf").setup({
  local_settings = ".neoconf.json",
  global_settings = "neoconf.json",
  import = {
    vscode = true, -- local .vscode/settings.json
    coc = true, -- global/local coc-settings.json
    nlsp = true, -- global/local nlsp-settings.nvim json settings
  },
  live_reload = true, -- send new configuration to lsp clients when changing json settings
  filetype_jsonc = true,
  plugins = {
    lspconfig = {
      enabled = true,
    },
    jsonls = {
      enabled = true,
      configured_servers_only = true,
    },
    lua_ls = {
      enabled_for_neovim_config = true,
      enabled = false,
    },
  },
})
