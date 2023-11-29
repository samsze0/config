require("flash").setup({
  labels = "asdfjghklqwertyuiopzxcvbnm",
  search = {
    multi_window = false,
    forward = true,
    wrap = true, -- Also search the other direction by wrapping
    ---@type Flash.Pattern.Mode
    -- Each mode will take ignorecase and smartcase into account.
    -- * exact: exact match
    -- * search: regular search
    -- * fuzzy: fuzzy search
    -- * fun(str): custom function that returns a pattern
    mode = "exact", -- fuzzy? custom function? regular search?
    incremental = false,
    ---@type (string|fun(win:window))[]
    exclude = {
      "notify",
      "cmp_menu",
      "noice",
      "flash_prompt",
      function(win) return not vim.api.nvim_win_get_config(win).focusable end,
    },
    max_length = false, ---@type number|false
  },
  jump = {
    pos = "start", ---@type "start" | "end" | "range"
    history = false,
    register = false,
    nohlsearch = false,
    autojump = false,
    inclusive = nil, ---@type boolean?
    offset = nil, ---@type number
  },
  label = {
    uppercase = true,
    exclude = "",
    current = true, -- Add label for first match
    -- show the label after the match
    after = true, ---@type boolean|number[]
    -- show the label before the match
    before = false, ---@type boolean|number[]
    style = "overlay", ---@type "eol" | "overlay" | "right_align" | "inline"
    -- flash tries to re-use labels that were already assigned to a position,
    -- when typing more characters. By default only lower-case labels are re-used.
    reuse = "lowercase", ---@type "lowercase" | "all" | "none"
    min_pattern_length = 0,
    rainbow = {
      enabled = false,
    },
    ---@class Flash.Format
    ---@field state Flash.State
    ---@field match Flash.Match
    ---@field hl_group string
    ---@field after boolean
    ---@type fun(opts:Flash.Format): string[][]
    format = function(opts) return { { opts.match.label, opts.hl_group } } end,
  },
  highlight = {
    backdrop = false,
    matches = true,
  },
  ---@type fun(match:Flash.Match, state:Flash.State)|nil
  action = nil, -- action to perform when picking a label
  -- When `true`, flash will try to continue the last search
  continue = false,
  -- Set config to a function to dynamically change the config
  config = nil, ---@type fun(opts:Flash.Config)|nil
  -- Overriding default with specific modes
  ---@type table<string, Flash.Config>
  modes = {
    -- `/` or `?`
    search = {
      enabled = true,
      jump = { history = true, register = true, nohlsearch = true },
      search = {},
    },
    -- `f`, `F`, `t`, `T`, `;` and `,` motions
    char = {
      enabled = false,
      jump_labels = false,
      multi_line = true,
      label = { exclude = "hjkliardc" },
      keys = { "f", "F", "t", "T" },
      search = { wrap = false },
      jump = { register = false },
    },
    treesitter = {
      enabled = false,
    },
    treesitter_search = {
      enabled = false,
    },
  },
  prompt = {
    enabled = false,
  },
})
