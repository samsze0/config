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
    done = " ",
  },
  view = {
    -- h diffview-config-view.x.layout
    default = {
      layout = "diff2_horizontal",
      winbar_info = false, -- See ':h diffview-config-view.x.winbar_info'
    },
    merge_tool = {
      layout = "diff3_horizontal",
      disable_diagnostics = true, -- Disable diagnostics for conflict buffers
    },
    file_history = {
      layout = "diff2_horizontal",
    },
  },
  file_panel = {
    listing_style = "tree",
    tree_options = {
      flatten_dirs = true,
      folder_statuses = "never",
    },
    win_config = {
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
      position = "bottom",
      height = 16,
      win_opts = {}
    },
  },
  commit_log_panel = {
    win_config = {
      win_opts = {},
    }
  },
  default_args = {
    DiffviewOpen = {},
    DiffviewFileHistory = {},
  },
  hooks = {}, -- See ':h diffview-config-hooks'
  keymaps = {
    disable_defaults = true,
    view = { -- Bindings that are active in the diff buffers
      { "n", "xl",  actions.select_next_entry, },
      { "n", "xj",  actions.select_prev_entry, },
      { "n", "xoo", actions.goto_file_edit, },
      { "n", "xow", actions.goto_file_split, },
      { "n", "xot", actions.goto_file_tab, },
      { "n", "xi",  actions.prev_conflict, },
      { "n", "xk",  actions.next_conflict, },
      { "n", "xo",  actions.conflict_choose("ours"), },
      { "n", "xu",  actions.conflict_choose("theirs"), },
      { "n", "xy",  actions.conflict_choose("base"), },
      { "n", "xp",  actions.conflict_choose("all"), },
      { "n", "xO",  actions.conflict_choose_all("ours"), },
      { "n", "xU",  actions.conflict_choose_all("theirs"), },
      { "n", "xY",  actions.conflict_choose_all("base"), },
      { "n", "xP",  actions.conflict_choose_all("all"), },
      { "n", "g?",  actions.help("file_panel"), },
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
      { { "n", "x" }, "2do", actions.diffget("ours") },
      { { "n", "x" }, "3do", actions.diffget("theirs"), },
      { "n",          "g?",  actions.help({ "view", "diff3" }), },
    },
    diff4 = {
      -- Mappings in 4-way diff layouts
      { { "n", "x" }, "1do", actions.diffget("base"), },
      { { "n", "x" }, "2do", actions.diffget("ours"), },
      { { "n", "x" }, "3do", actions.diffget("theirs"), },
      { "n",          "g?",  actions.help({ "view", "diff4" }), },
    },
    file_panel = {
      { "n", "<down>",        actions.next_entry, },
      { "n", "<up>",          actions.prev_entry, },
      { "n", "<2-LeftMouse>", actions.select_entry, },
      { "n", "<right>",       actions.select_entry, },
      { "n", "<cr>",          actions.select_entry, },
      { "n", "<tab>",         actions.select_entry, },
      { "n", "xs",            actions.toggle_stage_entry, },
      { "n", "xS",            actions.stage_all, },
      { "n", "xD",            actions.unstage_all, },
      { "n", "x<Delete>",     actions.restore_entry, },
      { "n", "xB",            actions.open_commit_log, },
      { "n", "<left>",        actions.close_fold, },
      { "n", "<s-up>",        actions.scroll_view(-0.25), }, -- Scroll the buffer(s)
      { "n", "<s-down>",      actions.scroll_view(0.25), },
      { "n", "xl",            actions.select_next_entry, },
      { "n", "xj",            actions.select_prev_entry, },
      { "n", "xoo",           actions.goto_file_edit, },
      { "n", "xow",           actions.goto_file_split, },
      { "n", "xot",           actions.goto_file_tab, },
      { "n", "i",             actions.listing_style, },
      { "n", "R",             actions.refresh_files, },
      { "n", "xi",            actions.prev_conflict, },
      { "n", "xk",            actions.next_conflict, },
      { "n", "xO",            actions.conflict_choose_all("ours"), },
      { "n", "xU",            actions.conflict_choose_all("theirs"), },
      { "n", "xY",            actions.conflict_choose_all("base"), },
      { "n", "xP",            actions.conflict_choose_all("all"), },
      { "n", "g?",            actions.help("file_panel"), },
    },
    file_history_panel = {
      { "n", "g!",            actions.options, },
      { "n", "y",             actions.copy_hash, },
      { "n", "xB",            actions.open_commit_log, },
      { "n", "<down>",        actions.next_entry, },
      { "n", "<up>",          actions.prev_entry, },
      { "n", "<cr>",          actions.select_entry, },
      { "n", "<tab>",         actions.select_entry, },
      { "n", "<2-LeftMouse>", actions.select_entry, },
      { "n", "<s-up>",        actions.scroll_view(-0.25), }, -- Scroll the buffer(s)
      { "n", "<s-down>",      actions.scroll_view(0.25), },
      { "n", "xl",            actions.select_next_entry, },
      { "n", "xj",            actions.select_prev_entry, },
      { "n", "xoo",           actions.goto_file_edit, },
      { "n", "xow",           actions.goto_file_split, },
      { "n", "xot",           actions.goto_file_tab, },
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
