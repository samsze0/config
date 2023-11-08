vim.cmd[[set clipboard+=unnamedplus]]  -- Use system clipboard

vim.opt.number = true
-- vim.opt.cursorline = true
-- vim.opt.signcolumn = "auto"
vim.opt.wrap = true
vim.cmd[[set formatoptions-=o]]
vim.cmd[[set formatoptions-=r]]
vim.cmd[[set formatoptions-=c]]
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.autoindent = true
vim.opt.smarttab = true
vim.opt.showtabline=0

vim.opt.smartcase = true
vim.opt.ignorecase = true
vim.opt.hlsearch = false

vim.cmd[[set backupdir=~/.cache/nvim/backup]]
vim.cmd[[set directory=~/.cache/nvim/swap]]
vim.cmd[[set undodir=~/.cache/nvim/undo]]

vim.cmd[[filetype on]]
vim.cmd[[filetype plugin off]]

-- Matching pair
vim.api.nvim_set_keymap("n", "m", "%", {silent = true, noremap = true})
vim.api.nvim_set_keymap("v", "m", "%", {silent = true, noremap = true})

-- Macro
vim.api.nvim_set_keymap("n", ".", "@", {silent = true, noremap = true})  -- replay macro x
vim.api.nvim_set_keymap("n", ">", "Q", {silent = true, noremap = true})  -- replay last macro

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
vim.api.nvim_set_keymap("i", "<Home>", "<C-o>^", {silent = true, noremap = true})

-- Indent
vim.api.nvim_set_keymap("n", "<Tab>", ">>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("n", "<S-Tab>", "<<", {silent = true, noremap = true})
vim.api.nvim_set_keymap("v", "<Tab>", ">gv", {silent = true, noremap = true})  -- keep selection after
vim.api.nvim_set_keymap("v", "<S-Tab>", "<gv", {silent = true, noremap = true})

-- Yank - stay at cursor after
vim.api.nvim_set_keymap("v", "y", "ygv<Esc>", {silent = true, noremap = true})

-- Fold
-- vim.api.nvim_set_keymap("n", "z.", "zo", {silent = true, noremap = true})
-- vim.api.nvim_set_keymap("n", "z,", "zc", {silent = true, noremap = true})
-- vim.api.nvim_set_keymap("n", "z>", "zr", {silent = true, noremap = true})
-- vim.api.nvim_set_keymap("n", "z<", "zm", {silent = true, noremap = true})

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
vim.api.nvim_set_keymap("n", "ws", "<cmd>wincmd h<CR>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("n", "wf", "<cmd>wincmd l<CR>", {silent = true, noremap = true})

vim.api.nvim_set_keymap("n", "ww", "<cmd>clo<CR>", {silent = true, noremap = true})

vim.api.nvim_set_keymap("n", "wk", "<cmd>split<CR><cmd>wincmd j<CR>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("n", "wl", "<cmd>vsplit<CR><cmd>wincmd l<CR>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("n", "wi", "<cmd>split<CR>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("n", "wj", "<cmd>vsplit<CR>", {silent = true, noremap = true})

-- Tab
vim.api.nvim_set_keymap("n", "tj", "<cmd>tabp<CR>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("n", "tl", "<cmd>tabn<CR>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("n", "tt", "<cmd>tabnew<CR>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("n", "tw", "<cmd>tabclose<CR>", {silent = true, noremap = true})

-- vim.opt.background = "dark"
-- vim.opt.termguicolors = true

local colors = {
  white = "#CBD1DA",
  graylight = "#547d9c",
  graymedium = "#1E2D39",
  graydark = "#13191F",
  black = "#000000",

  red = "#FF5C89",
  blue = "#4C9BFF",
  yellow = "#FE946E",
}

-- Lualine
-- local lualine_theme = require('lualine.themes.ayu_dark')

-- lualine_theme.normal.a.bg = colors.blue
-- lualine_theme.insert.a.bg = colors.red
-- lualine_theme.visual.a.bg = colors.yellow

-- lualine_theme.visual.c = {}
-- lualine_theme.visual.c.fg = lualine_theme.visual.b.fg
-- lualine_theme.insert.c = {}
-- lualine_theme.insert.c.fg = lualine_theme.insert.b.fg
-- lualine_theme.normal.c.fg = lualine_theme.normal.b.fg

-- require('lualine').setup {
--   options = {
--     theme = lualine_theme,
--     component_separators = { left = ' ', right = ' ' },
--   },
--   sections = {
--     lualine_a = {'mode'},
--     lualine_b = {'branch', 'diff', 'diagnostics'},
--     lualine_c = {'filename', 'location', 'filetype'},
--     -- lualine_x = {"require('dap').status()"},
--     lualine_y = {'progress'},
--     lualine_z = {'tabs'}
--   },
-- }
