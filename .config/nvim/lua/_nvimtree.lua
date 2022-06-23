local list = {
  { key = "c", action = "cd" },
  { key = "z,", action = "close_node" },
  { key = "<Tab>", action = "preview" },
  { key = ".", action = "toggle_dotfiles" },
  { key = "i", action = "toggle_git_ignored" },
  { key = "R", action = "refresh" },
  { key = "a", action = "create" },
  { key = "r", action = "rename" },
  { key = "d", action = "remove" },
  { key = "y", action = "copy" },
  { key = "p", action = "paste" },
  { key = "Y", action = "copy_absolute_path" },
  { key = "o", action = "system_open" },
  { key = "h", action = "toggle_help" },
  { key = "z<", action = "collapse_all" },
  { key = "u", action = "toggle_file_info" },
  { key = "q", action = "close" },
  { key = "<CR>", action = "edit" },
}

require'nvim-tree'.setup {
  disable_netrw = true,
  -- open_on_setup = true,
  diagnostics = {
    enable = true,
    icons = {
      hint = "",
      info = "",
      warning = "",
      error = "",
    }
  },
  filters = {
    dotfiles = false,
  },
  git = {
    enable = true,
    ignore = false,
  },
  view = {
    width = 30,
    height = 30,
    hide_root_folder = false,
    side = 'left',
    preserve_window_proportions = true,
    mappings = {
      custom_only = true,
      list = list
    },
    number = false,
    relativenumber = false,
    signcolumn = "yes"
  },
  trash = {
    cmd = "trash",
    require_confirm = true
  },
  actions = {
    change_dir = {
      enable = true,
    },
    open_file = {
      window_picker = {
        enable = true,
      }
    }
  },
}

vim.g.nvim_tree_icons = {
  default = '',
  symlink = '',
  git = {
    unstaged = "⊖",
    staged = "⊕",
    unmerged = "⊜",
    renamed = "⟲",
    untracked = "⊖",
    deleted = "⊗",
    ignored = "⊙"
  },
  folder = {
    arrow_open = "",
    arrow_closed = "",
    default = "",
    open = "",
    empty = "",
    empty_open = "",
    symlink = "",
    symlink_open = "",
  }
}

-- require('nvim-tree.view').is_visible()

local colors = require('colors/' .. vim.g.colors_name)

vim.highlight.create("NvimTreeWindowPicker", {
  guibg = colors.graydark
})
