-- TODO: copilot chat support
-- https://github.com/zbirenbaum/copilot.lua/issues/172

require("copilot").setup({
  panel = {
    enabled = false,
    auto_refresh = false,
    keymap = {
      jump_prev = false,
      jump_next = false,
      accept = false,
      refresh = false,
      open = false,
    },
    layout = {
      position = "bottom", -- | top | left | right
      ratio = 0.4,
    },
  },
  suggestion = {
    enabled = true,
    auto_trigger = true,
    debounce = 75,
    keymap = {
      accept = false,
      accept_word = false,
      accept_line = false,
      next = false,
      prev = false,
      dismiss = false,
    },
  },
  filetypes = {
    ["*"] = true,
  },
  copilot_node_command = "node", -- Node.js version must be > 18.x
  server_opts_overrides = {},
})
