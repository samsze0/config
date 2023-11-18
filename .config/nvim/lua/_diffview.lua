-- Lua
local actions = require("diffview.actions")

require("diffview").setup({
  diff_binaries = false,    -- Show diffs for binaries
  enhanced_diff_hl = false, -- See ':h diffview-config-enhanced_diff_hl'
  git_cmd = { "git" },      -- The git executable followed by default args.
  hg_cmd = { "hg" },        -- The hg executable followed by default args.
  use_icons = false,        -- Requires nvim-web-devicons
  show_help_hints = true,   -- Show hints for how to open the help panel
  watch_index = true,       -- Update views and index buffers when the git index changes.
  icons = {
    -- Only applies when use_icons is true.
    folder_closed = "",
    folder_open = "",
  },
  signs = {
    fold_closed = " ",
    fold_open = " ",
    done = "✓ ",
  },
  view = {
    -- Configure the layout and behavior of different types of views.
    -- Available layouts:
    --  'diff1_plain'
    --    |'diff2_horizontal'
    --    |'diff2_vertical'
    --    |'diff3_horizontal'
    --    |'diff3_vertical'
    --    |'diff3_mixed'
    --    |'diff4_mixed'
    -- For more info, see ':h diffview-config-view.x.layout'.
    default = {
      -- Config for changed files, and staged files in diff views.
      layout = "diff2_horizontal",
      winbar_info = false, -- See ':h diffview-config-view.x.winbar_info'
    },
    merge_tool = {
      -- Config for conflicted files in diff views during a merge or rebase.
      layout = "diff3_horizontal",
      disable_diagnostics = true, -- Temporarily disable diagnostics for conflict buffers while in the view.
      winbar_info = true,         -- See ':h diffview-config-view.x.winbar_info'
    },
    file_history = {
      -- Config for changed files in file history views.
      layout = "diff2_horizontal",
      winbar_info = false, -- See ':h diffview-config-view.x.winbar_info'
    },
  },
  file_panel = {
    listing_style = "tree", -- One of 'list' or 'tree'
    tree_options = {
      -- Only applies when listing_style is 'tree'
      flatten_dirs = true,       -- Flatten dirs that only contain one single dir
      folder_statuses = "never", -- One of 'never', 'only_folded' or 'always'.
    },
    win_config = {
      -- See ':h diffview-config-win_config'
      type = "split",
      position = "left",
      width = 35,
      win_opts = {}
    },
  },
  file_history_panel = {
    log_options = {
      -- See ':h diffview-config-log_options'
      git = {
        single_file = {
          diff_merges = "combined",
        },
        multi_file = {
          diff_merges = "first-parent",
        },
      },
      hg = {
        single_file = {},
        multi_file = {},
      },
    },
    win_config = {
      -- See ':h diffview-config-win_config'
      position = "bottom",
      height = 16,
      win_opts = {}
    },
  },
  commit_log_panel = {
    win_config = { -- See ':h diffview-config-win_config'
      win_opts = {},
    }
  },
  default_args = {
    -- Default args prepended to the arg-list for the listed commands
    DiffviewOpen = {},
    DiffviewFileHistory = {},
  },
  hooks = {},                 -- See ':h diffview-config-hooks'
  keymaps = {
    disable_defaults = false, -- Disable the default keymaps
    view = {
      -- The `view` bindings are active in the diff buffers, only when the current
      -- tabpage is a Diffview.
      { "n", "xl",  actions.select_next_entry, },
      { "n", "xj",  actions.select_prev_entry, },
      -- { "n", "xoo",       actions.goto_file_edit, },
      { "n", "xow", actions.goto_file_split, },
      { "n", "xot", actions.goto_file_tab, },
      -- { "n", "<f2><f1>", actions.focus_files, },  -- focus on file tree
      -- { "n", "<leader>b",  actions.toggle_files,      },  -- toggle file tree visibility
      -- { "n", "g<C-x>",     actions.cycle_layout,      },
      { "n", "xi",  actions.prev_conflict, },
      { "n", "xk",  actions.next_conflict, },
      { "n", "xo",  actions.conflict_choose("ours"), },
      { "n", "xu",  actions.conflict_choose("theirs"), },
      { "n", "xy",  actions.conflict_choose("base"), },
      { "n", "xp",  actions.conflict_choose("all"), },
      -- { "n", "dx",         actions.conflict_choose("none"), },
      { "n", "xO",  actions.conflict_choose_all("ours"), },
      { "n", "xU",  actions.conflict_choose_all("theirs"), },
      { "n", "xY",  actions.conflict_choose_all("base"), },
      { "n", "xP",  actions.conflict_choose_all("all"), },
      { "n", "g?",  actions.help("file_panel"), },
      -- { "n", "dX", actions.conflict_choose_all("none"), },
    },
    diff1 = {
      -- Mappings in single window diff layouts
      { "n", "g?", actions.help({ "view", "diff1" }), },
    },
    diff2 = {
      -- Mappings in 2-way diff layouts
      { "n", "g?", actions.help({ "view", "diff2" }), },
    },
    diff3 = {
      -- Mappings in 3-way diff layouts
      -- { { "n", "x" }, "2do", actions.diffget("ours") },
      -- { { "n", "x" }, "3do", actions.diffget("theirs"), },
      { "n", "g?", actions.help({ "view", "diff3" }), },
    },
    diff4 = {
      -- Mappings in 4-way diff layouts
      -- { { "n", "x" }, "1do", actions.diffget("base"), },
      -- { { "n", "x" }, "2do", actions.diffget("ours"), },
      -- { { "n", "x" }, "3do", actions.diffget("theirs"), },
      { "n", "g?", actions.help({ "view", "diff4" }), },
    },
    file_panel = {
      { "n", "<down>",        actions.next_entry, },
      { "n", "<up>",          actions.prev_entry, },
      { "n", "<2-LeftMouse>", actions.select_entry, },
      { "n", "<right>",       actions.select_entry, },
      { "n", "xs",            actions.toggle_stage_entry, },
      { "n", "xS",            actions.stage_all, },
      { "n", "xD",            actions.unstage_all, },
      { "n", "x<Delete>",     actions.restore_entry, },
      { "n", "xB",            actions.open_commit_log, },
      { "n", "<left>",        actions.close_fold, },
      -- { "n", "zo",     actions.open_fold,       },
      -- { "n", "zc",     actions.close_fold,      },
      -- { "n", "za",     actions.toggle_fold,     },
      -- { "n", "zR",     actions.open_all_folds,  },
      -- { "n", "zM",     actions.close_all_folds, },
      -- { "n", "<s-up>",     actions.scroll_view(-0.25), },
      -- { "n", "<s-down>",   actions.scroll_view(0.25),  },
      { "n", "xl",            actions.select_next_entry, },
      { "n", "xj",            actions.select_prev_entry, },
      { "n", "xoo",           actions.goto_file_edit, },
      { "n", "xow",           actions.goto_file_split, },
      { "n", "xot",           actions.goto_file_tab, },
      { "n", "i",             actions.listing_style, },
      { "n", "R",             actions.refresh_files, },
      -- { "n", "<leader>e", actions.focus_files,        },
      -- { "n", "<leader>b", actions.toggle_files,       },
      -- { "n", "g<C-x>",    actions.cycle_layout,       },
      { "n", "xi",            actions.prev_conflict, },
      { "n", "xk",            actions.next_conflict, },
      { "n", "g?",            actions.help("file_panel"), },
      { "n", "xO",            actions.conflict_choose_all("ours"), },
      { "n", "xU",            actions.conflict_choose_all("theirs"), },
      { "n", "xY",            actions.conflict_choose_all("base"), },
      { "n", "xP",            actions.conflict_choose_all("all"), },
      -- { "n", "dX", actions.conflict_choose_all("none"), },
    },
    file_history_panel = {
      { "n", "g!",            actions.options, },
      -- { "n", "<C-A-d>", actions.open_in_diffview, },
      { "n", "y",             actions.copy_hash, },
      { "n", "xB",            actions.open_commit_log, },
      -- { "n", "zR",            actions.open_all_folds,             },
      -- { "n", "zM",            actions.close_all_folds,            },
      -- { "n", "<down>",        actions.next_entry,                 },
      -- { "n", "<up>",          actions.prev_entry,                 },
      { "n", "<cr>",          actions.select_entry, },
      { "n", "<tab>",         actions.select_entry, },
      -- { "n", "<right>",       actions.select_entry,               },
      { "n", "<2-LeftMouse>", actions.select_entry, },
      -- { "n", "<c-b>",         actions.scroll_view(-0.25),         },
      -- { "n", "<c-f>",         actions.scroll_view(0.25),          },
      { "n", "xl",            actions.select_next_entry, },
      { "n", "xj",            actions.select_prev_entry, },
      { "n", "xoo",           actions.goto_file_edit, },
      { "n", "xow",           actions.goto_file_split, },
      { "n", "xot",           actions.goto_file_tab, },
      -- { "n", "<f2><f1>",      actions.focus_files,                },
      -- { "n", "<leader>b",     actions.toggle_files,               },
      -- { "n", "g<C-x>",        actions.cycle_layout,               },
      { "n", "g?",            actions.help("file_history_panel"), },
    },
    option_panel = {
      { "n", "<tab>", actions.select_entry, },
      { "n", "<cr>",  actions.select_entry, },
      { "n", "q",     actions.close, },
      { "n", "<esc>", actions.close, },
      { "n", "g?",    actions.help("option_panel"), },
    },
    help_panel = {
      { "n", "q",     actions.close, },
      { "n", "<esc>", actions.close, },
    },
  },
})
