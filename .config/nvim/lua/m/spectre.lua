require("spectre").setup({
  color_devicons = false,
  open_cmd = "vnew",
  live_update = false, -- auto execute search again when you write to any file in vim
  mapping = {
    ["toggle_line"] = {
      map = "dd",
      cmd = "<cmd>lua require('spectre').toggle_line()<CR>",
      desc = "toggle item",
    },
    ["enter_file"] = {
      map = "<cr>",
      cmd = "<cmd>lua require('spectre.actions').select_entry()<CR>",
      desc = "open file",
    },
    ["send_to_qf"] = {
      map = "<leader>q",
      cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
      desc = "send all items to quickfix",
    },
    ["replace_cmd"] = {
      map = "<leader>c",
      cmd = "<cmd>lua require('spectre.actions').replace_cmd()<CR>",
      desc = "input replace command",
    },
    ["show_option_menu"] = {
      map = "<leader>o",
      cmd = "<cmd>lua require('spectre').show_options()<CR>",
      desc = "show options",
    },
    ["run_current_replace"] = {
      map = "<leader>rc",
      cmd = "<cmd>lua require('spectre.actions').run_current_replace()<CR>",
      desc = "replace current line",
    },
    ["run_replace"] = {
      map = "<leader>R",
      cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>",
      desc = "replace all",
    },
    ["change_view_mode"] = {
      map = "<leader>v",
      cmd = "<cmd>lua require('spectre').change_view()<CR>",
      desc = "change result view mode",
    },
    ["toggle_ignore_case"] = {
      map = "ti",
      cmd = "<cmd>lua require('spectre').change_options('ignore-case')<CR>",
      desc = "toggle ignore case",
    },
    ["toggle_ignore_hidden"] = {
      map = "th",
      cmd = "<cmd>lua require('spectre').change_options('hidden')<CR>",
      desc = "toggle search hidden",
    },
  },
  find_engine = {
    ["rg"] = {
      cmd = "rg",
      args = {
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
      },
      options = {
        ["ignore-case"] = {
          value = "--ignore-case",
          icon = "[I]",
          desc = "ignore case",
        },
        ["hidden"] = {
          value = "--hidden",
          desc = "hidden file",
          icon = "[H]",
        },
      },
    },
    ["ag"] = {
      cmd = "ag",
      args = {
        "--vimgrep",
        "-s",
      },
      options = {
        ["ignore-case"] = {
          value = "-i",
          icon = "[I]",
          desc = "ignore case",
        },
        ["hidden"] = {
          value = "--hidden",
          desc = "hidden file",
          icon = "[H]",
        },
      },
    },
  },
  replace_engine = {
    ["sed"] = {
      cmd = "sed",
      args = nil,
      options = {
        ["ignore-case"] = {
          value = "--ignore-case",
          icon = "[I]",
          desc = "ignore case",
        },
      },
    },
    ["oxi"] = {
      cmd = "oxi",
      args = {},
      options = {
        ["ignore-case"] = {
          value = "i",
          icon = "[I]",
          desc = "ignore case",
        },
      },
    },
  },
  default = {
    find = {
      cmd = "rg",
      options = { "ignore-case" },
    },
    replace = {
      cmd = "sed",
    },
  },
  open_template = {},
})
