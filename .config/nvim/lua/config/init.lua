return {
  copilot_plugin = "lua",
  notify_backend = "custom",
  dap_plugins = false,
  diffview_plugin = false,
  tabline_plugin = "custom",
  statusline_plugin = "custom",
  treesitter_textobjects_plugin = "custom",
  nvim_dev_plugin = "neodev",
  persist_plugin = "custom",
  autopairs_plugin = false,
  format_on_save = false,
  indent_guide_plugin = false,
  bracket_colorizer_plugin = false,

  theme_opts = {
    debug = {
      enabled = false,
      toggle_colorizer = false,
      hide_defined_entries = false,
      show_non_ts_syntax_hl_only = false,
    },
  },
}
