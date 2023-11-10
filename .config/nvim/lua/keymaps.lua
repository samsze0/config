-- Pageup/down
vim.api.nvim_set_keymap("n", "<PageUp>", "<C-u><C-u>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("n", "<PageDown>", "<C-d><C-d>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("v", "<PageUp>", "<C-u><C-u>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("v", "<PageDown>", "<C-d><C-d>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("i", "<PageUp>", "<C-o><C-u><C-o><C-u>", {silent = true, noremap = true})  -- Execute <C-u> twice in normal mode
vim.api.nvim_set_keymap("i", "<PageDown>", "<C-o><C-d><C-o><C-d>", {silent = true, noremap = true})

-- Matching pair
vim.api.nvim_set_keymap("n", "m", "%", {silent = true, noremap = true})
vim.api.nvim_set_keymap("v", "m", "%", {silent = true, noremap = true})

-- Macro
vim.api.nvim_set_keymap("n", ".", "@", {silent = true, noremap = true})  -- replay macro x
vim.api.nvim_set_keymap("n", ">", "Q", {silent = true, noremap = true})  -- replay last macro

-- Clear search highlights
vim.api.nvim_set_keymap("n", "<Space>/", "<cmd>noh<CR>", {silent = true, noremap = true})

-- Replay edit
vim.api.nvim_set_keymap("n", ",", ".", {silent = true, noremap = true})

-- Redo
vim.api.nvim_set_keymap("n", "U", "<C-R>", {silent = true, noremap = true})

-- New line
vim.api.nvim_set_keymap("n", "o", "o<Esc>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("n", "O", "O<Esc>", {silent = true, noremap = true})

-- Insert/append swap
vim.api.nvim_set_keymap("n", "i", "a", {silent = true, noremap = true})
vim.api.nvim_set_keymap("n", "a", "i", {silent = true, noremap = true})
vim.api.nvim_set_keymap("v", "I", "A", {silent = true, noremap = true})
vim.api.nvim_set_keymap("v", "A", "I", {silent = true, noremap = true})

-- Home
vim.api.nvim_set_keymap("n", "<Home>", "^", {silent = true, noremap = true})
vim.api.nvim_set_keymap("v", "<Home>", "^", {silent = true, noremap = true})
vim.api.nvim_set_keymap("i", "<Home>", "<C-o>^", {silent = true, noremap = true})  -- Execute ^ in normal mode

-- Indent
vim.api.nvim_set_keymap("n", "<Tab>", ">>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("n", "<S-Tab>", "<<", {silent = true, noremap = true})
vim.api.nvim_set_keymap("v", "<Tab>", ">gv", {silent = true, noremap = true})  -- keep selection after
vim.api.nvim_set_keymap("v", "<S-Tab>", "<gv", {silent = true, noremap = true})

-- Yank - stay at cursor after
vim.api.nvim_set_keymap("v", "y", "ygv<Esc>", {silent = true, noremap = true})

-- Fold
vim.api.nvim_set_keymap("n", "z.", "zo", {silent = true, noremap = true})
vim.api.nvim_set_keymap("n", "z,", "zc", {silent = true, noremap = true})
vim.api.nvim_set_keymap("n", "z>", "zr", {silent = true, noremap = true})
vim.api.nvim_set_keymap("n", "z<", "zm", {silent = true, noremap = true})

-- Screen movement
vim.api.nvim_set_keymap("n", "<S-Up>", "<C-Y>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("v", "<S-Up>", "<C-Y>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("i", "<S-Up>", "<C-o><C-Y>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("n", "<S-Down>", "<C-E>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("v", "<S-Down>", "<C-E>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("i", "<S-Down>", "<C-o><C-E>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("n", "<S-Left>", "<ScrollWheelLeft>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("v", "<S-Left>", "<ScrollWheelLeft>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("i", "<S-Left>", "<ScrollWheelLeft>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("n", "<S-Right>", "<ScrollWheelRight>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("v", "<S-Right>", "<ScrollWheelRight>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("i", "<S-Right>", "<ScrollWheelRight>", {silent = true, noremap = true})

-- Window (pane)
vim.api.nvim_set_keymap("n", "we", "<cmd>wincmd k<CR>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("n", "wd", "<cmd>wincmd j<CR>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("n", "ww", "<cmd>wincmd h<CR>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("n", "wf", "<cmd>wincmd l<CR>", {silent = true, noremap = true})

vim.api.nvim_set_keymap("n", "wx", "<cmd>clo<CR>", {silent = true, noremap = true})

vim.api.nvim_set_keymap("n", "wk", "<cmd>split<CR><cmd>wincmd j<CR>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("n", "wl", "<cmd>vsplit<CR><cmd>wincmd l<CR>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("n", "wi", "<cmd>split<CR>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("n", "wj", "<cmd>vsplit<CR>", {silent = true, noremap = true})

-- Tab
vim.api.nvim_set_keymap("n", "tj", "<cmd>tabp<CR>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("n", "tl", "<cmd>tabn<CR>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("n", "tt", "<cmd>tabnew<CR>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("n", "tw", "<cmd>tabclose<CR>", {silent = true, noremap = true})
