require('kommentary.config').configure_language("default", {
  prefer_single_line_comments = true,
  use_consistent_indentation = true,
  ignore_whitespace = true,
})

require('kommentary.config').configure_language({
  "fish",
  "conf",
  "python",
  "yaml",
  "gitignore",
  "kivy",
  "terraform",
  "sshconfig",
  "sh",
  "cmake"
}, {
  single_line_comment_string = "#",
})

require('kommentary.config').configure_language("markdown", {
  prefer_single_line_comments = false,
  multi_line_comment_strings = {"<!--", "-->"}
})

require('kommentary.config').configure_language({
  'vim',
  "typescriptreact"
}, {
  single_line_comment_string = 'auto',
  multi_line_comment_strings = 'auto',
  hook_function = function()
    require('ts_context_commentstring.internal').update_commentstring()
  end,
})

vim.g.kommentary_create_default_mappings = false

vim.api.nvim_set_keymap("n", "<Space>.", "<Plug>kommentary_line_increase", {})
vim.api.nvim_set_keymap("n", "<Space>,", "<Plug>kommentary_line_decrease", {})
vim.api.nvim_set_keymap("v", "<Space>.", "<Plug>kommentary_visual_increase", {})
vim.api.nvim_set_keymap("v", "<Space>,", "<Plug>kommentary_visual_decrease", {})

