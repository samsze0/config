local actions = require "fzf-lua.actions"

require('fzf-lua').setup({
  winopts = {
    fullscreen = false,
    preview    = {
      border     = 'noborder',
      wrap       = 'nowrap',
      hidden     = 'nohidden',
      vertical   = 'down:50%',
      horizontal = 'right:50%',
      layout     = 'horizontal',
      title      = true,
      scrollbar  = 'float',
      delay      = 100, -- delay(ms) displaying the preview
      winopts    = {
        -- builtin previewer window options
        number         = true,
        relativenumber = false,
        cursorline     = true,
        cursorlineopt  = 'both',
        cursorcolumn   = false,
        signcolumn     = 'no',
        list           = false,
        foldenable     = false,
        foldmethod     = 'manual',
      },
    },
    on_create  = function()
    end,
  },
  keymap = {
    builtin = {
      ["<S-PageDown>"] = "preview-page-down",
      ["<S-PageUp>"]   = "preview-page-up",
      ["<S-Down>"]     = "preview-page-down",
      ["<S-Up>"]       = "preview-page-up",
    },
    fzf = {
      ["shift-down"] = "preview-page-down",
      ["shift-up"]   = "preview-page-up",
    },
  },
  actions = {
    files = {
      ["default"] = actions.file_edit,
      ["alt-q"]   = actions.file_sel_to_qf, -- send to quickfix
      ["alt-l"]   = actions.file_sel_to_ll, -- send to loclist
    },
    buffers = {
      ["default"] = actions.buf_edit,
    }
  },
  fzf_opts = {

  },
  previewers = {
    git_diff = {
      pager = "delta --width=$FZF_PREVIEW_COLUMNS",
    },
    builtin = {
      treesitter = { enable = true, disable = {} },
      extensions = {
        ["jpg"] = { "chafa", "<file>" },
        ["svg"] = { "chafa", "<file>" },
        ["png"] = { "chafa", "<file>" },
      },
    },
    files = {
      rg_opts = "--color=never --files --hidden --follow -g '!.git'",
      fd_opts = "--color=never --type f --hidden --follow --exclude .git",
      toggle_ignore_flag = "--no-ignore", -- flag toggled in `actions.toggle_ignore`
    },
    git = {
      files = {
        cmd = 'git ls-files --exclude-standard',
      },
      status = {
        cmd = "git -c color.status=false status -su",
        preview_pager = "delta --width=$FZF_PREVIEW_COLUMNS",
        actions = {
          -- actions inherit from 'actions.files' and merge
          ["right"] = { fn = actions.git_unstage, reload = true },
          ["left"]  = { fn = actions.git_stage, reload = true },
          ["alt-x"] = { fn = actions.git_reset, reload = true },
        },
      },
      commits = {
        cmd =
        "git log --color --pretty=format:'%C(yellow)%h%Creset %Cgreen(%><(12)%cr%><|(12))%Creset %s %C(blue)<%an>%Creset'",
        preview_pager = "delta --width=$FZF_PREVIEW_COLUMNS",
        actions = {
          ["default"] = actions.git_checkout,
          ["alt-y"]   = { fn = actions.git_yank_commit, exec_silent = true },
        },
      },
      bcommits = {
        cmd =
        "git log --color --pretty=format:'%C(yellow)%h%Creset %Cgreen(%><(12)%cr%><|(12))%Creset %s %C(blue)<%an>%Creset' <file>",
        preview_pager = "delta --width=$FZF_PREVIEW_COLUMNS",
        actions = {
          ["default"] = actions.git_buf_edit,
          ["alt-w"]   = actions.git_buf_vsplit,
          ["alt-t"]   = actions.git_buf_tabedit,
          ["alt-y"]   = { fn = actions.git_yank_commit, exec_silent = true },
        },
      },
      branches = {
        cmd     = "git branch --all --color",
        preview = "git log --graph --pretty=oneline --abbrev-commit --color {1}",
        actions = {
          ["default"] = actions.git_switch,
        },
      },
      tags = {
        cmd      = "git for-each-ref --color --sort=-taggerdate --format "
            .. "'%(color:yellow)%(refname:short)%(color:reset) "
            .. "%(color:green)(%(taggerdate:relative))%(color:reset)"
            .. " %(subject) %(color:blue)%(taggername)%(color:reset)' refs/tags",
        preview  = "git log --graph --color --pretty=format:'%C(yellow)%h%Creset "
            .. "%Cgreen(%><(12)%cr%><|(12))%Creset %s %C(blue)<%an>%Creset' {1}",
        fzf_opts = { ["--no-multi"] = "" },
        actions  = { ["default"] = actions.git_checkout },
      },
      stash = {
        cmd      = "git --no-pager stash list",
        preview  = "git --no-pager stash show --patch --color {1}",
        actions  = {
          ["default"] = actions.git_stash_apply,
          ["alt-x"]   = { fn = actions.git_stash_drop, reload = true },
        },
        fzf_opts = {
          ["--no-multi"]  = '',
          ['--delimiter'] = "'[:]'",
        },
      },
    },
    grep = {
      rg_opts        = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e",
      rg_glob        = false,     -- default to glob parsing?
      glob_flag      = "--iglob", -- for case sensitive globs use '--glob'
      glob_separator = "%s%-%-",  -- query separator pattern (lua): ' --'
      actions        = {
        -- actions inherit from 'actions.files' and merge
        ["alt-g"] = { actions.grep_lgrep } -- Toggle live grep
      },
    },
    lsp = {

    },
    quickfix = {
    },
    buffers = {
      actions = {
        -- actions inherit from 'actions.buffers' and merge
        ["alt-x"] = { fn = actions.buf_del, reload = true },
      }
    },
    tabs = {
      tab_marker = "<<",
      actions    = {
        -- actions inherit from 'actions.buffers' and merge
        ["default"] = actions.buf_switch,
        ["alt-x"]   = { fn = actions.buf_del, reload = true },
      },
    },
    diagnostics = {
      severity_limit = 3 -- 1 = hint; 2 = info; 3 = warn; 4 = error
    }
  },
})

-- vim.ui.select
require('fzf-lua').register_ui_select()
