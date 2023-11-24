return {
  telescope_over_fzflua = false,
  ssr_plugin = true,
  spectre_plugin = false,
  copilot_plugin = "lua",       -- @type "vim" | "lua" | false
  terminal_plugin = "floaterm", -- @type "floaterm" | "toggleterm" | false
  filetree_plugin = nil,        -- @type "nvimtree" | false
  lf_plugin = "vim",            -- @type "vim" | "nvim" | false

  notify_backend = false,       -- @type "fidget" | "vim-notify" | false
  -- Fidget is totally unnecessary, notifications on the side make them hard to read too

  dap_plugins = false,
  chatgpt_plugin = false,  -- TODO

  vgit_plugin = false,     -- Tested v0.2.1, very unstable, and no updates for 7 months
  trouble_plugin = false,  -- Non-intuitive UI and totally replaceable by fzf
  maximize_plugin = false, -- Doesn't work with non-buffers e.g. help and command line window
}
