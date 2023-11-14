local keymap = vim.api.nvim_set_keymap
local opts = {silent = true, noremap = true}

-- Pageup/down
keymap("n", "<PageUp>", "<C-u><C-u>", opts)
keymap("n", "<PageDown>", "<C-d><C-d>", opts)
keymap("v", "<PageUp>", "<C-u><C-u>", opts)
keymap("v", "<PageDown>", "<C-d><C-d>", opts)
keymap("i", "<PageUp>", "<C-o><C-u><C-o><C-u>", opts)  -- Execute <C-u> twice in normal mode
keymap("i", "<PageDown>", "<C-o><C-d><C-o><C-d>", opts)

-- Matching pair
keymap("n", "m", "%", opts)
keymap("v", "m", "%", opts)

-- Macro
keymap("n", ".", "@", opts)  -- replay macro x
keymap("n", ">", "Q", opts)  -- replay last macro

-- Clear search highlights
keymap("n", "<Space>/", "<cmd>noh<CR>", opts)

-- Replay edit
keymap("n", ".", ".", opts)

-- Redo
keymap("n", "U", "<C-R>", opts)

-- New line
keymap("n", "o", "o<Esc>", opts)
keymap("n", "O", "O<Esc>", opts)

-- Insert/append swap
keymap("n", "i", "a", opts)
keymap("n", "a", "i", opts)
keymap("v", "I", "A", opts)
keymap("v", "A", "I", opts)

-- Home
keymap("n", "<Home>", "^", opts)
keymap("v", "<Home>", "^", opts)
keymap("i", "<Home>", "<C-o>^", opts)  -- Execute ^ in normal mode

-- Indent
keymap("n", "<Tab>", ">>", opts)
keymap("n", "<S-Tab>", "<<", opts)
keymap("v", "<Tab>", ">gv", opts)  -- keep selection after
keymap("v", "<S-Tab>", "<gv", opts)

-- Yank - stay at cursor after
keymap("v", "y", "ygv<Esc>", opts)

-- Fold
keymap("n", "z.", "zo", opts)
keymap("n", "z,", "zc", opts)
keymap("n", "z>", "zr", opts)
keymap("n", "z<", "zm", opts)

-- Screen movement
keymap("n", "<S-Up>", "<C-Y>", opts)
keymap("v", "<S-Up>", "<C-Y>", opts)
keymap("i", "<S-Up>", "<C-o><C-Y>", opts)
keymap("n", "<S-Down>", "<C-E>", opts)
keymap("v", "<S-Down>", "<C-E>", opts)
keymap("i", "<S-Down>", "<C-o><C-E>", opts)
keymap("n", "<S-Left>", "<ScrollWheelLeft>", opts)
keymap("v", "<S-Left>", "<ScrollWheelLeft>", opts)
keymap("i", "<S-Left>", "<ScrollWheelLeft>", opts)
keymap("n", "<S-Right>", "<ScrollWheelRight>", opts)
keymap("v", "<S-Right>", "<ScrollWheelRight>", opts)
keymap("i", "<S-Right>", "<ScrollWheelRight>", opts)

-- Window (pane)
keymap("n", "wi", "<cmd>wincmd k<CR>", opts)
keymap("n", "wk", "<cmd>wincmd j<CR>", opts)
keymap("n", "wj", "<cmd>wincmd h<CR>", opts)
keymap("n", "wl", "<cmd>wincmd l<CR>", opts)

keymap("n", "wx", "<cmd>clo<CR>", opts)

keymap("n", "wd", "<cmd>split<CR><cmd>wincmd j<CR>", opts)  -- Switch to bottom window after creating it
keymap("n", "wf", "<cmd>vsplit<CR><cmd>wincmd l<CR>", opts)
keymap("n", "we", "<cmd>split<CR>", opts)
keymap("n", "ws", "<cmd>vsplit<CR>", opts)

-- Tab
keymap("n", "tj", "<cmd>tabp<CR>", opts)
keymap("n", "tl", "<cmd>tabn<CR>", opts)
keymap("n", "tt", "<cmd>tabnew<CR>", opts)
keymap("n", "tw", "<cmd>tabclose<CR>", opts)

-- Auto closing pair
-- Ref: https://github.com/m4xshen/autoclose.nvim/blob/main/lua/autoclose.lua
-- keymap("i", "\"", "\"\"<left>", opts)
-- keymap("i", "'", "''<left>", opts)
-- keymap("i", "(", "()<left>", opts)
-- keymap("i", "[", "[]<left>", opts)
-- keymap("i", "{", "{}<left>", opts)
-- keymap("i", "<", "<><left>", opts)

-- Delete & cut
-- Ref: https://github.com/gbprod/cutlass.nvim/blob/main/lua/cutlass.lua
keymap("n", "d", "\"_d", opts)
keymap("v", "d", "\"_d", opts)
keymap("n", "x", "d", opts)
keymap("v", "x", "d", opts)
keymap("n", "xx", "dd", opts)
keymap("n", "X", "D", opts)
