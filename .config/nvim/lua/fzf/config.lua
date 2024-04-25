return {
  keymaps = {
    move_to_pane = {
      left = "<C-s>",
      down = "<C-d>",
      up = "<C-e>",
      right = "<C-f>",
    },
    remote_scroll_preview_pane = {
      up = "<S-Up>",
      down = "<S-Down>",
      left = "<S-Left>",
      right = "<S-Right>",
    },
  },
  default_extra_args = {
    ["--scroll-off"] = "2",
    -- ["--with-nth"] = "1..",  -- Decrease performance: https://github.com/junegunn/fzf?tab=readme-ov-file#performance
  },
  default_extra_env_vars = {
    -- ["SHELL"] = "$(which bash)",
  },
  default_rg_args = {
    ["--smart-case"] = "",
    ["--no-ignore"] = "",
    ["--hidden"] = "",
    ["--trim"] = "",
    ["--color"] = "always",
    ["--colors"] = {
      "'match:fg:blue'",
      "'path:none'",
      "'line:none'",
    },
    ["--no-column"] = "",
    ["--line-number"] = "",
    ["--no-heading"] = "",
  },
}
