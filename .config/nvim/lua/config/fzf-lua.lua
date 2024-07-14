local M = {}

-- See default
-- https://github.com/ibhagwan/fzf-lua/blob/main/lua/fzf-lua/defaults.lua

local utils = require("utils")
local actions = require("fzf-lua.actions")

M.setup = function()
  local config = {
    winopts = {
      fullscreen = false,
      height = 1,
      width = 0.9,
      preview = {
        border = "noborder",
        wrap = "nowrap",
        hidden = "nohidden",
        vertical = "down:50%",
        horizontal = "right:50%",
        layout = "horizontal",
        title = true,
        scrollbar = "float",
        delay = 100, -- delay(ms) displaying the preview
        winopts = {
          -- builtin previewer window options
          number = true,
          relativenumber = false,
          cursorline = true,
          cursorlineopt = "both",
          cursorcolumn = false,
          signcolumn = "no",
          list = false,
          foldenable = false,
          foldmethod = "manual",
        },
      },
      on_create = function() end,
      on_close = function() end,
    },
    keymap = {
      builtin = { -- For built-in previewer e.g. vim buffer
        ["<S-PageDown>"] = "preview-page-down",
        ["<S-PageUp>"] = "preview-page-up",
        ["<S-Down>"] = "preview-page-down",
        ["<S-Up>"] = "preview-page-up",
      },
      fzf = { -- For Fzf and Fzf previewer
        ["shift-down"] = "preview-page-down",
        ["shift-up"] = "preview-page-up",
      },
    },
    actions = {
      files = {
        -- providers that inherit these actions:
        --   files, git_files, git_status, grep, lsp
        --   oldfiles, quickfix, loclist, tags, btags
        --   args
        ["default"] = actions.file_edit,
        ["ctrl-q"] = actions.file_sel_to_qf, -- send to quickfix
        ["ctrl-l"] = actions.file_sel_to_ll, -- send to loclist
        ["ctrl-w"] = actions.file_vsplit,
        ["ctrl-t"] = actions.file_tabedit,
      },
      buffers = {
        -- providers that inherit these actions:
        --   buffers, tabs, lines, blines
        ["default"] = actions.buf_edit,
        ["ctrl-w"] = actions.buf_vsplit,
        ["ctrl-t"] = actions.buf_tabedit,
      },
    },
    fzf_opts = {
      -- Set to false to remove a flag
      ["--ansi"] = "",
      ["--info"] = "inline",
      ["--height"] = "100%",
      ["--layout"] = "reverse",
      ["--border"] = "none",
    },
    previewers = {
      git_diff = {
        cmd_deleted = "git diff --color HEAD --",
        cmd_modified = "git diff --color HEAD",
        cmd_untracked = "git diff --color --no-index /dev/null",
        pager = "delta --width=$FZF_PREVIEW_COLUMNS",
      },
      builtin = {
        treesitter = { enable = true, disable = {} },
        -- Preview extensions using a custom shell command:
        extensions = {
          ["jpg"] = { "chafa", "<file>" },
          ["svg"] = { "chafa", "<file>" },
          ["png"] = { "chafa", "<file>" },
        },
      },
    },
  }

  local providers_config = {
    defaults = {
      file_icons = false,
      git_icons = true,
      color_icons = true,
    },
    files = {
      prompt = "Files❯ ",
      -- executed command priority is 'cmd' (if exists)
      -- otherwise auto-detect prioritizes `fd`:`rg`:`find`
      fd_opts = "--color=never --type f --hidden --follow --exclude .git",
      rg_opts = "--color=never --files --hidden --follow -g '!.git'",
      toggle_ignore_flag = "--no-ignore", -- flag toggled in `actions.toggle_ignore`
      actions = {
        ["default"] = actions.file_edit,
        ["ctrl-i"] = { actions.toggle_ignore },
      },
    },
  }

  require("fzf-lua").setup(vim.tbl_deep_extend("force", config, providers_config))

  -- vim.ui.select
  require("fzf-lua").register_ui_select()
end

return M
