require("flash").setup {
  labels = "asdfghjklqwertyuiopzxcvbnm",
  search = {
    multi_window = false,
    forward = true,
    wrap = false,   -- Also search the other direction by wrapping
    ---@type Flash.Pattern.Mode
    mode = "exact", -- fuzzy? custom function? regular search?
    incremental = false,
    ---@type (string|fun(win:window))[]
    exclude = {
      "notify",
      "cmp_menu",
      "noice",
      "flash_prompt",
      function(win)
        return not vim.api.nvim_win_get_config(win).focusable
      end,
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
    format = function(opts)
      return { { opts.match.label, opts.hl_group } }
    end,
  },
  highlight = {
    backdrop = false,
    matches = true,
  },
  ---@type fun(match:Flash.Match, state:Flash.State)|nil
  action = nil, -- action to perform when picking a label
  -- Set config to a function to dynamically change the config
  config = nil, ---@type fun(opts:Flash.Config)|nil
  -- You can override the default options for a specific mode.
  -- Use it with `require("flash").jump({mode = "forward"})`
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
      enabled = true,
      jump_labels = false,
      multi_line = true,
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
}
