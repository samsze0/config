local M = {}

-- See default
-- https://github.com/ibhagwan/fzf-lua/blob/main/lua/fzf-lua/defaults.lua

local utils = require("utils")
local config = require("config")
local timeago = require("utils.timeago")
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
        ["ctrl-b"] = function(selected) -- deprecated
          -- Expect entry to be in the either formats:
          -- ((.*) nbsp*) relpath
          -- ((.*) nbsp*) relpath:row:col[:(.*)*]
          local s = utils.strip_ansi_coloring(selected[1])
          s = utils.strip_before_last_occurrence_of(s, utils.nbsp)
          local parts = vim.split(s, ":")
          local relpath
          if #parts > 1 then
            relpath = parts[1]
          else
            relpath = s
          end
          vim.cmd([[vsplit]])
          vim.cmd([[wincmd l]])
          vim.cmd(string.format("e %s", vim.fn.fnameescape(relpath)))
          if #parts > 1 then
            vim.cmd(string.format([[call cursor(%s, %s)]], parts[2], parts[3]))
            vim.api.nvim_feedkeys("zz", "n", true) -- Center screen
          end
        end,
        ["ctrl-t"] = actions.file_tabedit,
        ["ctrl-y"] = {
          function(selected)
            -- Expect entry to be in the either formats:
            -- ((.*) nbsp*) relpath
            -- ((.*) nbsp*) relpath:(.*)*
            local s = utils.strip_ansi_coloring(selected[1])
            s = utils.strip_before_last_occurrence_of(s, utils.nbsp)
            local parts = vim.split(s, ":")
            if #parts > 0 then s = parts[1] end
            local relpath = s
            vim.fn.setreg("+", relpath)
            vim.notify(string.format("Copied %s", relpath))
          end,
          -- https://github.com/ibhagwan/fzf-lua/wiki/Advanced#fzf-exec-act-resume
          actions.resume,
        },
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
        -- inherits from 'actions.files', here we can override
        -- or set bind to 'false' to disable a default action
        ["default"] = actions.file_edit,
        ["ctrl-i"] = { actions.toggle_ignore },
      },
    },
    git = require("config.fzflua-git"),
    grep = {
      prompt = "Rg❯ ",
      input_prompt = "Grep For❯ ",
      -- executed command priority is 'cmd' (if exists)
      -- otherwise auto-detect prioritizes `rg` over `grep`
      rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e",
      rg_glob = false, -- default to glob parsing?
      glob_flag = "--iglob", -- for case sensitive globs use '--glob'
      glob_separator = "%s%-%-", -- query separator pattern (lua): ' --'
      -- Advanced usage: for custom argument parsing define
      rg_glob_fn = function(query, opts) return query, "" end, -- Return pair: { search query, additional rg flags } }
      actions = {
        -- actions inherit from 'actions.files' and merge
        ["ctrl-g"] = { actions.grep_lgrep }, -- Toggle live grep
      },
    },
    args = {
      prompt = "Args❯ ",
      files_only = true,
      actions = {
        ["ctrl-x"] = { fn = actions.arg_del, reload = true },
      },
    },
    oldfiles = {
      prompt = "History❯ ",
      cwd_only = false,
      stat_file = true, -- verify files exist on disk
      include_current_session = false, -- include bufs from current session
    },
    buffers = {
      prompt = "Buffers❯ ",
      sort_lastused = true, -- sort buffers() by last used
      show_unloaded = true, -- show unloaded buffers
      cwd_only = false, -- buffers for the cwd only
      actions = {
        -- actions inherit from 'actions.buffers' and merge
        ["ctrl-x"] = { fn = actions.buf_del, reload = true },
      },
    },
    tabs = {
      prompt = "Tabs❯ ",
      tab_title = "Tab",
      tab_marker = "<<",
      actions = {
        -- actions inherit from 'actions.buffers' and merge
        ["default"] = actions.buf_switch,
        ["ctrl-x"] = { fn = actions.buf_del, reload = true },
      },
      fzf_opts = {
        -- hide tabnr
        ["--delimiter"] = "'[\\):]'",
        ["--with-nth"] = "2..",
      },
    },
    lines = {
      prompt = "Lines❯ ",
      previewer = "builtin", -- set to 'false' to disable
      show_unloaded = true, -- show unloaded buffers
      show_unlisted = false, -- include 'help' buffers
      no_term_buffers = true, -- exclude 'term' buffers
      fzf_opts = {
        -- do not include bufnr in fuzzy matching
        -- tiebreak by line no.
        ["--delimiter"] = "'[\\]:]'",
        ["--nth"] = "2..",
        ["--tiebreak"] = "index",
        ["--tabstop"] = "1",
      },
      actions = {
        ["default"] = actions.buf_edit_or_qf,
        ["ctrl-q"] = actions.buf_sel_to_qf,
        ["ctrl-l"] = actions.buf_sel_to_ll,
      },
    },
    blines = {
      prompt = "Lines❯ ",
      previewer = "builtin", -- set to 'false' to disable
      show_unlisted = true, -- include 'help' buffers
      no_term_buffers = false, -- include 'term' buffers
      start = "cursor", -- start display from cursor?
      fzf_opts = {
        -- hide filename, tiebreak by line no.
        ["--delimiter"] = "'[:]'",
        ["--with-nth"] = "2..",
        ["--tiebreak"] = "index",
        ["--tabstop"] = "1",
      },
      -- actions inherit from 'actions.buffers' and merge
      actions = {
        ["default"] = actions.buf_edit_or_qf,
        ["ctrl-q"] = actions.buf_sel_to_qf,
        ["ctrl-l"] = actions.buf_sel_to_ll,
      },
    },
    -- TODO: tag, btag, colorscheme, keymap, highlights, changes
    jumps = {
      prompt = "Jumps❯ ",
      actions = {
        ["default"] = actions.goto_jump,
      },
    },
    marks = {
      prompt = "Marks❯ ",
      actions = {
        ["default"] = actions.goto_mark,
      },
    },
    registers = {
      prompt = "Registers❯ ",
      ignore_empty = true,
      actions = {
        ["default"] = actions.paste_register,
      },
    },
    loclist = {
      prompt = "Loclist❯ ",
      actions = {},
    },
    loclist_stack = {
      prompt = "LoclistStack❯ ",
      cwd_only = false,
      marker = ">",
      actions = {
        ["default"] = actions.set_qflist,
      },
    },
    -- TODO: dap
    quickfix = {
      prompt = "Quickfix❯ ",
    },
    quickfix_stack = {
      prompt = "QuickfixStack❯ ",
      marker = ">",
      actions = {
        ["default"] = actions.set_qflist,
      },
    },
    lsp = require("config.fzflua-lsp"),
    diagnostics = {
      prompt = "Diagnostics❯ ",
      cwd_only = true,
      diag_icons = true,
      diag_source = true, -- display diag source (e.g. [pycodestyle])
      icon_padding = "",
      multiline = true, -- concatenate multi-line diags into a single line. Set to `false` to display first line only
      severity_limit = 3, -- 1 = hint; 2 = info; 3 = warn; 4 = error
    },
    -- TODO: complete_path, complete_file
  }

  require("fzf-lua").setup(vim.tbl_deep_extend("force", config, providers_config))

  -- vim.ui.select
  require("fzf-lua").register_ui_select()
end

return M
