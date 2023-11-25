return {
  telescope_over_fzflua = false,
  copilot_plugin = "lua",       -- @type "vim" | "lua" | false
  terminal_plugin = "floaterm", -- @type "floaterm" | "toggleterm" | false
  filetree_plugin = nil,        -- @type "nvimtree" | false
  lf_plugin = "vim",            -- @type "vim" | "nvim" | false

  notify_backend = false,       -- @type "fidget" | "vim-notify" | false
  -- Fidget is totally unnecessary, notifications on the side make them hard to read too

  dap_plugins = false,
  diffview_plugin = true,  -- Most of its functionalities can be replicated w/ fzflua + custom mappings
  chatgpt_plugin = false,  -- TODO
  ssr_plugin = false,      -- TODO

  spectre_plugin = false,  -- Prefer quickfix/loclist over something that force writes to all buffers w/ no undo capabilities
  vgit_plugin = false,     -- Tested v0.2.1, very unstable, and no updates for 7 months
  trouble_plugin = false,  -- Non-intuitive UI and totally replaceable by fzf
  maximize_plugin = false, -- Doesn't work with non-buffers e.g. help and command line window
}
