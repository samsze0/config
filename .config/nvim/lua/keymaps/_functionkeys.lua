vim.api.nvim_set_keymap("n", "<f1>", "<cmd>FzfLua<cr>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<f2>", ":NvimTreeFocus<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<f3>", "<cmd>FzfLua files<cr>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<f4>", "<cmd>FzfLua blines<cr>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<f5>", "<cmd>FzfLua live_grep<cr>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<f10>", "<cmd>FzfLua git_bcommits<cr>", {noremap = true, silent = true})  -- File history
vim.api.nvim_set_keymap("n", "<f11>", "<cmd>FzfLua git_status<cr>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<f12>", "<cmd>ToggleTerm<cr>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("t", "<f12>", "<cmd>ToggleTerm<cr>", {noremap = true, silent = true})
