local keymap = vim.api.nvim_set_keymap
local opts = { silent = true, noremap = true }
local noremap_opts = { silent = true, noremap = false }

-- Pageup/down
keymap("n", "<PageUp>", "<C-u><C-u>", opts)
keymap("n", "<PageDown>", "<C-d><C-d>", opts)
keymap("v", "<PageUp>", "<C-u><C-u>", opts)
keymap("v", "<PageDown>", "<C-d><C-d>", opts)
keymap("i", "<PageUp>", "<C-o><C-u><C-o><C-u>", opts) -- Execute <C-u> twice in normal mode
keymap("i", "<PageDown>", "<C-o><C-d><C-o><C-d>", opts)

-- Delete word
keymap("n", "ke", "<cmd>m .-2<CR>", opts)

-- Caution: marks in visual mode are only set after leaving visual mode
-- `<cmd>` will execute a command without leaving visual mode while
-- `:` leaves visual mode and enters command mode before processing the command.
-- https://www.reddit.com/r/neovim/comments/y2h8ps/i_have_a_mapping_for_normal_how_to_make_an/

-- Move/swap line/selection up/down
-- keymap("n", "ke", "<cmd>m .-2<CR>==", opts) -- Auto indent line afterwards
keymap("n", "ke", "<cmd>m .-2<CR>", opts)
-- keymap("n", "ke", "dd2<Up>\"dp==", noremap_opts)
keymap("n", "kd", "<cmd>m .+1<CR>", opts)
keymap("v", "ke", ":m .-2<CR>gv", opts)
-- keymap("v", "ke", ":m .-2<CR>gv=gv", opts)     -- Auto indent selection then re-select selection
keymap("v", "kd", ":m '>+1<CR>gv", opts)

-- Delete line
keymap("n", "my", "dd", noremap_opts)
keymap("i", "<C-y>", "<C-o>dd", noremap_opts)
keymap("v", "my", ":d<CR>", opts)

-- Duplicate line/selection
keymap("n", "md", "<cmd>t .<CR>", opts)
keymap("v", "md", ":t '><CR>", opts)

-- Matching pair
keymap("n", "mm", "%", opts)
keymap("v", "mm", "%", opts)

-- Macro
keymap("n", ",", "@", opts) -- replay macro x
keymap("n", "<", "Q", opts) -- replay last macro

-- Clear search highlights
keymap("n", "<Space>/", "<cmd>noh<CR>", opts)

-- Replay edit
-- keymap("n", ".", ".", opts)

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
keymap("i", "<Home>", "<C-o>^", opts) -- Execute ^ in normal mode

-- Indent
keymap("n", "<Tab>", ">>", opts)
keymap("n", "<S-Tab>", "<<", opts)
keymap("v", "<Tab>", ">gv", opts) -- keep selection after
keymap("v", "<S-Tab>", "<gv", opts)

-- Yank - stay at cursor after
keymap("v", "y", "ygv<Esc>", opts)

-- Fold
keymap("n", "z.", "zo", opts)
keymap("n", "z,", "zc", opts)
keymap("n", "z>", "zr", opts)
keymap("n", "z<", "zm", opts)

-- Screen movement
keymap("n", "<S-Up>", "5<C-Y>", opts)
keymap("v", "<S-Up>", "5<C-Y>", opts)
keymap("i", "<S-Up>", "5<C-o><C-Y>", opts)
keymap("n", "<S-Down>", "5<C-E>", opts)
keymap("v", "<S-Down>", "5<C-E>", opts)
keymap("i", "<S-Down>", "5<C-o><C-E>", opts)
keymap("n", "<S-Left>", "2<ScrollWheelLeft>", opts)
keymap("v", "<S-Left>", "2<ScrollWheelLeft>", opts)
keymap("i", "<S-Left>", "2<ScrollWheelLeft>", opts)
keymap("n", "<S-Right>", "2<ScrollWheelRight>", opts)
keymap("v", "<S-Right>", "2<ScrollWheelRight>", opts)
keymap("i", "<S-Right>", "2<ScrollWheelRight>", opts)

-- Window (pane)
keymap("n", "wi", "<cmd>wincmd k<CR>", opts)
keymap("n", "wk", "<cmd>wincmd j<CR>", opts)
keymap("n", "wj", "<cmd>wincmd h<CR>", opts)
keymap("n", "wl", "<cmd>wincmd l<CR>", opts)

keymap("n", "ww", "<cmd>clo<CR>", opts)

keymap("n", "wd", "<cmd>split<CR><cmd>wincmd j<CR>", opts) -- Switch to bottom window after creating it
keymap("n", "wf", "<cmd>vsplit<CR><cmd>wincmd l<CR>", opts)
keymap("n", "we", "<cmd>split<CR>", opts)
keymap("n", "ws", "<cmd>vsplit<CR>", opts)

keymap("n", "wt", "<cmd>wincmd T<CR>", opts) -- Move to new tab

-- Tab
keymap("n", "tj", "<cmd>tabp<CR>", opts)
keymap("n", "tl", "<cmd>tabn<CR>", opts)
keymap("n", "tt", "<cmd>tabnew<CR>", opts)
keymap("n", "tw", "<cmd>tabclose<CR>", opts)

-- Delete & cut
-- Ref: https://github.com/gbprod/cutlass.nvim/blob/main/lua/cutlass.lua
keymap("n", "d", "\"dd", opts) -- Put in d register, in case if needed
keymap("v", "d", "\"dd", opts)
keymap("n", "x", "d", opts)
keymap("v", "x", "d", opts)
keymap("n", "xx", "dd", opts)
keymap("n", "X", "D", opts)

-- Jump (jumplist)
keymap("n", "<C-u>", "<C-o>", opts)
keymap("n", "<C-o>", "<C-i>", opts)

-- FzfLua
-- https://github.com/ibhagwan/fzf-lua#commands
keymap("n", "<f1>", "<cmd>FzfLua<cr>", opts)
keymap("n", "<f3><f3>", "<cmd>FzfLua files<cr>", opts)
keymap("n", "<f3><f2>", "<cmd>FzfLua buffers<cr>", opts)
keymap("n", "<f3><f1>", "<cmd>FzfLua tabs<cr>", opts)
keymap("n", "<f5>", "<cmd>FzfLua live_grep<cr>", opts)         -- Ripgrep whole project
keymap("n", "<f11><f5>", "<cmd>FzfLua git_commits<cr>", opts)  -- Project commit history
keymap("n", "<f11><f4>", "<cmd>FzfLua git_bcommits<cr>", opts) -- File (i.e. buffer) commit history
keymap("n", "<f11><f3>", "<cmd>FzfLua git_status<cr>", opts)
keymap("n", "<f12>", "<cmd>FloatermToggle<cr>", opts)
keymap("t", "<f12>", "<cmd>FloatermToggle<cr>", opts)

-- Diffview
keymap("n", "<f11><f1>", "<cmd>DiffviewOpen<cr>", opts)
keymap("n", "<f11><f2>", "<cmd>DiffviewFileHistory %<cr>", opts) -- See current file git history
keymap("v", "<f11><f2>", ":DiffviewFileHistory %<cr>", opts)     -- See current selection git history

-- NvimTree
keymap("n", "<f2><f1>", "<cmd>NvimTreeFindFile<cr>", opts)

-- FzfLua + LSP
keymap("n", "li", "<cmd>FzfLua lsp_definitions<CR>", opts)
keymap("n", "lr", "<cmd>FzfLua lsp_references<CR>", opts)
keymap("n", "<f4><f4>", "<cmd>FzfLua lsp_document_symbols<CR>", opts)
keymap("n", "<f4><f5>", "<cmd>FzfLua lsp_live_workspace_symbols<CR>", opts)
keymap("n", "ld", "<cmd>FzfLua lsp_document_diagnostics<CR>", opts) -- Show list of problems
keymap("n", "lD", "<cmd>FzfLua lsp_workspace_diagnostics<CR>", opts)

-- lf.vim
keymap("n", "<f2><f2>", "<cmd>LfWorkingDirectory<cr>", opts)
keymap("n", "<f2><f3>", "<cmd>LfCurrentFile<cr>", opts)

-- LSP
keymap("n", "lu", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
keymap("n", "lU", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
keymap("n", "lI", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
keymap("i", "<C-p>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
keymap("n", "le", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
keymap("n", "la", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
keymap("n", "lR", "<cmd>LspRestart<CR>", opts)

-- Comment.nvim
keymap("n", "<C-/>", "<Plug>(comment_toggle_linewise_current)", opts)
keymap("v", "<C-/>", "<Plug>(comment_toggle_linewise_visual)gv", opts) -- Re-select the last block

-- GitSigns
keymap("n", "su", "<cmd>Gitsigns preview_hunk_inline<CR>", opts)
keymap("n", "si", "<cmd>Gitsigns prev_hunk<CR>", opts)
keymap("n", "sk", "<cmd>Gitsigns next_hunk<CR>", opts)
keymap("n", "sb", "<cmd>Gitsigns blame_line<CR>", opts)
keymap("n", "sj", "<cmd>Gitsigns stage_hunk<CR>", opts)
keymap("n", "sl", "<cmd>Gitsigns undo_stage_hunk<CR>", opts)
keymap("n", "s;", "<cmd>Gitsigns reset_hunk<CR>", opts)

-- :qa, :q!, :wq
keymap("n", "<space>q", ":q<cr>", opts)
keymap("n", "<space>w", ":wq<cr>", opts)
keymap("n", "<space>Q", ":q!<cr>", opts)
keymap("n", "<space>s", ":w<cr>", opts)

-- persistence.nvim
-- restore the session for the current directory
keymap("n", "<Space>R", [[<cmd>lua require("persistence").load()<cr>]], opts)
