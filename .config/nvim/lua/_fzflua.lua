local M = {}

M.setup = function()
  local actions = require "fzf-lua.actions"

  local config = {
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
      on_close   = function()
      end
    },
    keymap = {
      builtin = { -- For built-in previewer e.g. vim buffer
        ["<S-PageDown>"] = "preview-page-down",
        ["<S-PageUp>"]   = "preview-page-up",
        ["<S-Down>"]     = "preview-page-down",
        ["<S-Up>"]       = "preview-page-up",
      },
      fzf = { -- For Fzf and Fzf previewer
        ["shift-down"] = "preview-page-down",
        ["shift-up"]   = "preview-page-up",
      },
    },
    actions = {
      files = {
        -- providers that inherit these actions:
        --   files, git_files, git_status, grep, lsp
        --   oldfiles, quickfix, loclist, tags, btags
        --   args
        ["default"] = actions.file_edit,
        ["alt-q"]   = actions.file_sel_to_qf, -- send to quickfix
        ["alt-l"]   = actions.file_sel_to_ll, -- send to loclist
      },
      buffers = {
        -- providers that inherit these actions:
        --   buffers, tabs, lines, blines
        ["default"] = actions.buf_edit,
      }
    },
    fzf_opts = {
      -- Set to false to remove a flag
      ["--ansi"]   = "",
      ["--info"]   = "inline",
      ["--height"] = "100%",
      ["--layout"] = "reverse",
      ["--border"] = "none",
    },
    previewers = {
      git_diff = {
        cmd_deleted   = "git diff --color HEAD --",
        cmd_modified  = "git diff --color HEAD",
        cmd_untracked = "git diff --color --no-index /dev/null",
        pager         = "delta --width=$FZF_PREVIEW_COLUMNS",
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

  local git_providers_config = {
    files = {
      prompt = 'GitFiles❯ ',
      cmd    = 'git ls-files --exclude-standard',
    },
    status = {
      prompt        = 'GitStatus❯ ',
      cmd           = "git -c color.status=false status -su", -- Disable color. Show in short format and show all untracked files.
      previewer     = "git_diff",
      preview_pager = "delta --width=$FZF_PREVIEW_COLUMNS",
      actions       = {
        -- actions inherit from 'actions.files' and merge
        ["right"] = { fn = actions.git_unstage, reload = true },
        ["left"]  = { fn = actions.git_stage, reload = true },
        ["alt-x"] = { fn = actions.git_reset, reload = true },
      },
    },
    commits = {
      prompt        = 'ProjectCommits❯ ',
      -- {1} : commit SHA
      -- <file> : current file

      -- Show hash (%h) in yellow,
      -- date (%cr) in green, right-aligned and padded to 12 chars w/ %><(12), truncates to 12 if longer w/ %><|(12)
      -- author (%an) in blue
      cmd           =
      "git log --color --pretty=format:'%C(yellow)%h%Creset %Cgreen(%><(12)%cr%><|(12))%Creset %s %C(blue)<%an>%Creset'",

      -- Show (diff in commit):
      -- commit hash (%H) in red,
      -- author (%an) and email (%ae) in blue,
      -- commit date (%cd) in yellow,
      -- commit subject (first line of commit msg) (%s) in green
      preview       = "git show --pretty='%Cred%H%n%Cblue%an <%ae>%n%C(yellow)%cD%n%Cgreen%s' --color {1}",
      preview_pager = "delta --width=$FZF_PREVIEW_COLUMNS",
      actions       = {
        ["default"] = actions.git_checkout,
        ["alt-y"]   = { fn = actions.git_yank_commit, exec_silent = true },
      },
    },
    bcommits = {
      prompt        = 'FileCommits❯ ',

      -- Show hash (%h) in yellow,
      -- date (%cr) in green, right-aligned and padded to 12 chars w/ %><(12), truncates to 12 if longer w/ %><|(12)
      -- author (%an) in blue
      cmd           =
      "git log --color --pretty=format:'%C(yellow)%h%Creset %C(green)(%><(12)%cr%><|(12))%Creset %s %C(blue)<%an>%Creset' <file>",

      -- Show diff between current and <file>:
      -- <hash>^! denotes single commit referred by the hash (^! means to ignore all of its parents)
      preview       = "git diff --color {1}^! -- <file>",
      preview_pager = "delta --width=$FZF_PREVIEW_COLUMNS",
      actions       = {
        ["default"] = actions.git_buf_edit,
        ["alt-w"]   = actions.git_buf_vsplit,
        ["alt-t"]   = actions.git_buf_tabedit,
        ["alt-y"]   = { fn = actions.git_yank_commit, exec_silent = true },
      },
    },
    branches = {
      prompt  = 'Branches❯ ',

      cmd     = "git branch --all --color",
      -- Show log graph of a branch where each commit is one-liner w/ abbreviated hash (%h)
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
      prompt   = 'Stash❯ ',
      cmd      = "git --no-pager stash list",
      -- Show in patch format (diff; like `git show`)
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
  }

  local providers_config = {
    defaults = {
      file_icons  = false,
      git_icons   = true,
      color_icons = true,
    },
    files = {
      prompt             = 'Files❯ ',
      -- executed command priority is 'cmd' (if exists)
      -- otherwise auto-detect prioritizes `fd`:`rg`:`find`
      fd_opts            = "--color=never --type f --hidden --follow --exclude .git",
      rg_opts            = "--color=never --files --hidden --follow -g '!.git'",
      toggle_ignore_flag = "--no-ignore", -- flag toggled in `actions.toggle_ignore`
      actions            = {
        -- inherits from 'actions.files', here we can override
        -- or set bind to 'false' to disable a default action
        ["default"] = actions.file_edit,
        ["alt-y"]   = function(selected) print(selected[1]) end,
        ["alt-i"]   = { actions.toggle_ignore },
      }
    },
    git = git_providers_config,
    grep = {
      prompt         = 'Rg❯ ',
      input_prompt   = 'Grep For❯ ',
      -- executed command priority is 'cmd' (if exists)
      -- otherwise auto-detect prioritizes `rg` over `grep`
      rg_opts        = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e",
      rg_glob        = false,     -- default to glob parsing?
      glob_flag      = "--iglob", -- for case sensitive globs use '--glob'
      glob_separator = "%s%-%-",  -- query separator pattern (lua): ' --'
      -- Advanced usage: for custom argument parsing define
      rg_glob_fn     = function(query, opts)
        return query, ""
      end, -- Return pair: { search query, additional rg flags } }
      actions        = {
        -- actions inherit from 'actions.files' and merge
        ["alt-g"] = { actions.grep_lgrep } -- Toggle live grep
      },
    },
    args = {
      prompt     = 'Args❯ ',
      files_only = true,
      actions    = {
        ["alt-x"] = { fn = actions.arg_del, reload = true }
      },
    },
    oldfiles = {
      prompt                  = 'History❯ ',
      cwd_only                = false,
      stat_file               = true,  -- verify files exist on disk
      include_current_session = false, -- include bufs from current session
    },
    buffers = {
      prompt        = 'Buffers❯ ',
      sort_lastused = true,  -- sort buffers() by last used
      show_unloaded = true,  -- show unloaded buffers
      cwd_only      = false, -- buffers for the cwd only
      actions       = {
        -- actions inherit from 'actions.buffers' and merge
        ["alt-x"] = { fn = actions.buf_del, reload = true },
      }
    },
    tabs = {
      prompt     = 'Tabs❯ ',
      tab_title  = "Tab",
      tab_marker = "<<",
      actions    = {
        -- actions inherit from 'actions.buffers' and merge
        ["default"] = actions.buf_switch,
        ["alt-x"]   = { fn = actions.buf_del, reload = true },
      },
      fzf_opts   = {
        -- hide tabnr
        ['--delimiter'] = "'[\\):]'",
        ["--with-nth"]  = '2..',
      },
    },
    lines = {
      prompt          = 'Lines❯ ',
      previewer       = "builtin", -- set to 'false' to disable
      show_unloaded   = true,      -- show unloaded buffers
      show_unlisted   = false,     -- include 'help' buffers
      no_term_buffers = true,      -- exclude 'term' buffers
      fzf_opts        = {
        -- do not include bufnr in fuzzy matching
        -- tiebreak by line no.
        ['--delimiter'] = "'[\\]:]'",
        ["--nth"]       = '2..',
        ["--tiebreak"]  = 'index',
        ["--tabstop"]   = "1",
      },
      actions         = {
        ["default"] = actions.buf_edit_or_qf,
        ["alt-q"]   = actions.buf_sel_to_qf,
        ["alt-l"]   = actions.buf_sel_to_ll
      },
    },
    blines = {
      prompt          = 'BLines❯ ',
      previewer       = "builtin", -- set to 'false' to disable
      show_unlisted   = true,      -- include 'help' buffers
      no_term_buffers = false,     -- include 'term' buffers
      start           = "cursor",  -- start display from cursor?
      fzf_opts        = {
        -- hide filename, tiebreak by line no.
        ["--delimiter"] = "'[:]'",
        ["--with-nth"]  = '2..',
        ["--tiebreak"]  = 'index',
        ["--tabstop"]   = "1",
      },
      -- actions inherit from 'actions.buffers' and merge
      actions         = {
        ["default"] = actions.buf_edit_or_qf,
        ["alt-q"]   = actions.buf_sel_to_qf,
        ["alt-l"]   = actions.buf_sel_to_ll
      },
    },
    -- TODO: tag, btag, colorscheme, keymap, highlights
    -- TODO: marks, jumps, registers, changes, loclist, loclist_stack
    -- TODO: dap
    quickfix = {
      prompt = "Quickfix❯ ",
    },
    quickfix_stack = {
      prompt = "QuickfixStack❯ ",
      marker = ">",
    },
    lsp = {
      prompt_postfix     = '❯ ',
      cwd_only           = true,
      -- :lua vim.lsp.buf.references({includeDeclaration = ?})
      includeDeclaration = true,
      symbols            = {
        symbol_style = 1, -- false = disable; 1 = icon + kind; 2 = icon; 3 = kind
      },
      -- colorize using Treesitter '@' highlight groups ("@function", etc).
      symbol_hl          = function(s) return "@" .. s:lower() end,
      symbol_fmt         = function(s, opts) return "[" .. s .. "]" end,
      fzf_opts           = {
        ["--tiebreak"] = "begin",
        ["--info"]     = "default",
      },
      -- TODO: code actions, LSP finder, references, definitions, declarations, typedefs, implementations, document symbols, workspace symbols, incoming/outgoing calls, and more
    },
    diagnostics = {
      prompt         = 'Diagnostics❯ ',
      cwd_only       = true,
      diag_icons     = true,
      diag_source    = true, -- display diag source (e.g. [pycodestyle])
      icon_padding   = '',
      multiline      = true, -- concatenate multi-line diags into a single line. Set to `false` to display first line only
      severity_limit = 3,    -- 1 = hint; 2 = info; 3 = warn; 4 = error
    },
    -- TODO: complete_path, complete_file
  }

  require('fzf-lua').setup(vim.tbl_deep_extend('force', config, providers_config))

  -- vim.ui.select
  require('fzf-lua').register_ui_select()
end

local utils = require("utils")

M.test = function()
  require('fzf-lua').fzf_exec(function(fzf_cb)
    coroutine.wrap(function()
      -- See libuv
      -- http://docs.libuv.org/en/v1.x/
      -- :help lua-loop
      -- :h luvref :h lua-loop
      local co = coroutine.running()
      for _, b in ipairs(vim.api.nvim_list_bufs()) do
        vim.schedule(function()
          local name = vim.api.nvim_buf_get_name(b)
          name = #name > 0 and name or "[No Name]"
          fzf_cb(b .. ":" .. name, function() coroutine.resume(co) end)
        end)
        coroutine.yield()
      end
      fzf_cb()
    end)()
  end, {
    prompt = 'Test❯ ',
    preview = "echo {}",
    actions = {

    }
  })
end

M.undo_tree = function()
  local undolist = utils.get_undolist()

  -- Tweaked from
  -- https://github.com/debugloop/telescope-undo.nvim/tree/main
  require('fzf-lua').fzf_exec(function(fzf_cb)
    coroutine.wrap(function()
      local co = coroutine.running()
      -- TODO: can block UI if `utils.get_undolist` is expensive
      vim.schedule(function()
        for i, undo in ipairs(undolist) do
          fzf_cb(string.format("[%d] seq %d (%s)", i, undo.seq, undo.time),
            function() coroutine.resume(co) end)
        end
      end)
      coroutine.yield()
      fzf_cb()
    end)()
  end, {
    prompt = 'UndoTree❯ ',
    preview = require 'fzf-lua'.shell.raw_preview_action_cmd(function(items) -- arg: selected items
      local undo = undolist[tonumber(items[1]:match("%[(.-)%]"))]
      local delta_opts = ""
      return string.format([[echo "%s" | delta "%s" %s]], undo.diff, undo.time, delta_opts)
    end),
    actions = {
      ['alt-x'] = {
        fn = function(selected)
          for _, f in ipairs(selected) do
            print("deleting:", f)
          end
        end,
        reload = true,
      }
    }
  })
end

return M
