require'hop'.setup {
  keys = "abcdefghijklmnopqrstuvwxyz1234567890",
  jump_on_sole_occurrence = true
}

vim.api.nvim_set_keymap('v', 'f', "<cmd>HopChar1CurrentLineAC<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', 'F', "<cmd>HopChar1CurrentLineBC<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('', 'j', "<cmd>HopChar1<cr>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('', 'J', "<cmd>HopChar1<cr>", { noremap = true, silent = true })
