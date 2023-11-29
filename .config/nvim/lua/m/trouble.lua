require("trouble").setup({
  position = "bottom",
  height = 10, -- when position == bottom
  width = 50, -- When position == left | right
  icons = false,
  mode = "workspace_diagnostics", -- "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
  severity = nil, -- nil (ALL) or vim.diagnostic.severity.ERROR | WARN | INFO | HINT
  fold_open = "",
  fold_closed = "",
  group = true, -- group results by file
  padding = true, -- add an extra new line on top of the list
  cycle_results = true,
  action_keys = {
    -- map to {} to remove a mapping
    close = "q",
    cancel = "<esc>",
    refresh = "r",
    jump = { "<cr>", "<tab>", "<2-leftmouse>" },
    open_split = { "w" },
    open_tab = { "t" },
    jump_close = { "o" }, -- Jump to and close
    toggle_mode = "i", -- Toggle between workspace and document
    switch_severity = "s",
    toggle_preview = "P", -- Toggle auto preview
    hover = "u",
    preview = "p",
    open_code_href = "c",
    close_folds = { "zJ", "zj" },
    open_folds = { "zL", "zl" },
    toggle_fold = { "zp" },
    previous = "<Up>",
    next = "<Down>",
    help = "?",
  },
  multiline = true,
  indent_lines = true, -- Indent guide below fold icon
  win_config = { border = "single" }, -- See |nvim_open_win()|
  auto_open = false,
  auto_close = false,
  auto_preview = true,
  auto_fold = false,
  auto_jump = { "lsp_definitions" },
  include_declaration = { "lsp_references", "lsp_implementations", "lsp_definitions" },
  signs = {
    error = "E",
    warning = "W",
    hint = "H",
    information = "I",
    other = "?",
  },
  use_diagnostic_signs = false, -- Use signs defined by LSP clients
})
