local M = {}

M.setup = function()
  local keymap = vim.api.nvim_set_keymap
  local opts = { silent = true, noremap = true }
  local opts_can_remap = { silent = true, noremap = false }

  local config = require('config')

  -- Pageup/down
  keymap("n", "<PageUp>", "<C-u><C-u>", opts)
  keymap("n", "<PageDown>", "<C-d><C-d>", opts)
  keymap("v", "<PageUp>", "<C-u><C-u>", opts)
  keymap("v", "<PageDown>", "<C-d><C-d>", opts)
  keymap("i", "<PageUp>", "<C-o><C-u><C-o><C-u>", opts) -- Execute <C-u> twice in normal mode
  keymap("i", "<PageDown>", "<C-o><C-d><C-o><C-d>", opts)

  -- Delete word
  keymap("i", "<C-BS>", "<C-W>", opts)

  -- Move/swap line/selection up/down
  local auto_indent = false
  keymap("n", "<C-up>", "<cmd>m .-2<CR>" .. (auto_indent and "==" or ""), opts)
  keymap("n", "<C-down>", "<cmd>m .+1<CR>" .. (auto_indent and "==" or ""), opts)
  keymap("v", "<C-up>", ":m .-2<CR>gv" .. (auto_indent and "=gv" or ""), opts)
  keymap("v", "<C-down>", ":m '>+1<CR>gv" .. (auto_indent and "=gv" or ""), opts)

  -- Delete line
  keymap("n", "<M-y>", "dd", opts_can_remap)
  keymap("i", "<M-y>", "<C-o><M-y>", opts_can_remap)
  keymap("v", "<M-y>", ":d<CR>", opts)

  -- Duplicate line/selection
  keymap("n", "<M-g>", "<cmd>t .<CR>", opts)
  keymap("i", "<M-g>", "<C-o><M-g>", opts_can_remap)
  keymap("v", "<M-g>", ":t '><CR>", opts)

  -- Matching pair
  keymap("n", "m", "%", opts)
  keymap("v", "m", "%", opts)

  -- Macro
  keymap("n", ",", "@", opts) -- replay macro x
  keymap("n", "<", "Q", opts) -- replay last macro

  -- Clear search highlights
  keymap("n", "<Space>/", "<cmd>noh<CR>", opts)

  -- Redo
  keymap("n", "U", "<C-R>", opts)

  -- New line
  keymap("n", "o", "o<Esc>", opts)
  keymap("n", "O", "O<Esc>", opts)

  -- Fold
  keymap("n", "zl", "zo", opts)
  keymap("n", "zj", "zc", opts)
  keymap("n", "zp", "za", opts)

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
  keymap("n", "<C-e>", "<cmd>wincmd k<CR>", opts)
  keymap("n", "<C-d>", "<cmd>wincmd j<CR>", opts)
  keymap("n", "<C-s>", "<cmd>wincmd h<CR>", opts)
  keymap("n", "<C-f>", "<cmd>wincmd l<CR>", opts)

  keymap("n", "ww", "<cmd>clo<CR>", opts)

  keymap("n", "wd", "<cmd>split<CR><cmd>wincmd j<CR>", opts) -- Switch to bottom window after creating it
  keymap("n", "wf", "<cmd>vsplit<CR><cmd>wincmd l<CR>", opts)
  keymap("n", "we", "<cmd>split<CR>", opts)
  keymap("n", "ws", "<cmd>vsplit<CR>", opts)

  keymap("n", "wt", "<cmd>wincmd T<CR>", opts) -- Move to new tab

  local maximize_plugin = require('config').maximize_plugin

  if maximize_plugin then
    keymap("n", 'wz', "<Cmd>lua require('maximize').toggle()<CR>", opts)
  else
    keymap("n", 'wz', "<C-W>_<C-W>|", opts) -- Maximise both horizontally and vertically
    keymap("n", 'wx', "<C-W>=", opts)
  end

  -- Tab
  keymap("n", "tj", "<cmd>tabp<CR>", opts)
  keymap("n", "tl", "<cmd>tabn<CR>", opts)
  keymap("n", "tt", "<cmd>tabnew<CR>", opts)
  keymap("n", "tw", "<cmd>tabclose<CR>", opts)
  keymap("n", "<C-j>", "<cmd>tabp<CR>", opts)
  keymap("n", "<C-l>", "<cmd>tabn<CR>", opts)

  keymap("n", "tu", "<cmd>tabm -1<CR>", opts)
  keymap("n", "to", "<cmd>tabm +1<CR>", opts)
  keymap("n", "<C-S-j>", "<cmd>tabm -1<CR>", opts)
  keymap("n", "<C-S-l>", "<cmd>tabm +1<CR>", opts)

  -- Delete & cut
  -- Ref: https://github.com/gbprod/cutlass.nvim/blob/main/lua/cutlass.lua
  keymap("n", "d", '"dd', opts) -- Put in d register, in case if needed
  keymap("v", "d", '"dd', opts)
  keymap("n", "x", "d", opts)
  keymap("v", "x", "d", opts)
  keymap("n", "xx", "dd", opts)
  keymap("n", "X", "D", opts)

  -- Change (add to register 'c')
  keymap('n', 'c', '"cc', opts)
  keymap('n', 'C', '"cC', opts)
  keymap('v', 'c', '"cc', opts)
  keymap('v', 'C', '"cC', opts)

  -- Jump (jumplist)
  keymap("n", "<C-u>", "<C-o>", opts)
  keymap("n", "<C-o>", "<C-i>", opts)

  -- Telescope / FzfLua
  keymap("n", "<f1>",
    "<cmd>" .. (config.telescope_over_fzflua and 'lua require("telescope.builtin").builtin()' or "FzfLua") .. "<cr>",
    opts)
  keymap("n", "<f3><f3>",
    "<cmd>" ..
    (config.telescope_over_fzflua and 'lua require("telescope.builtin").find_files()' or "FzfLua files") .. "<cr>",
    opts)
  keymap("n", "<f3><f2>",
    "<cmd>" ..
    (config.telescope_over_fzflua and 'lua require("telescope.builtin").buffers()' or "FzfLua buffers") .. "<cr>",
    opts)
  keymap("n", "<f3><f1>", -- TODO
    "<cmd>" .. (config.telescope_over_fzflua and 'lua require("telescope.builtin").' or "FzfLua tabs") .. "<cr>", opts)
  keymap("n", "<f5>",
    "<cmd>" ..
    (config.telescope_over_fzflua and 'lua require("telescope.builtin").live_grep()' or "FzfLua live_grep") .. "<cr>",
    opts) -- Ripgrep whole project
  keymap("n", "<f11><f5>",
    "<cmd>" ..
    (config.telescope_over_fzflua and 'lua require("telescope.builtin").git_commits()' or "FzfLua git_commits") .. "<cr>",
    opts) -- Project commit history
  keymap("n", "<f11><f4>",
    "<cmd>" ..
    (config.telescope_over_fzflua and 'lua require("telescope.builtin").git_bcommits()' or "FzfLua git_bcommits") ..
    "<cr>",
    opts) -- File (i.e. buffer) commit history
  keymap("n", "<f11><f3>",
    "<cmd>" ..
    (config.telescope_over_fzflua and 'lua require("telescope.builtin").git_status()' or "FzfLua git_status") .. "<cr>",
    opts)

  -- Telescope / FzfLua - LSP
  keymap("n", "li",
    "<cmd>" ..
    (config.telescope_over_fzflua and 'lua require("telescope.builtin").lsp_definitions()' or "FzfLua lsp_definitions") ..
    "<cr>",
    opts)
  keymap("n", "lr",
    "<cmd>" ..
    (config.telescope_over_fzflua and 'lua require("telescope.builtin").lsp_references()' or "FzfLua lsp_references") ..
    "<cr>",
    opts)
  keymap("n", "<f4><f4>",
    "<cmd>" ..
    (config.telescope_over_fzflua and 'lua require("telescope.builtin").lsp_document_symbols()' or "FzfLua lsp_document_symbols") ..
    "<cr>", opts)
  keymap("n", "<f4><f5>",
    "<cmd>" ..
    (config.telescope_over_fzflua and 'lua require("telescope.builtin").lsp_workspace_symbols()' or "FzfLua lsp_live_workspace_symbols") ..
    "<cr>",
    opts)
  keymap("n", "ld",
    "<cmd>" ..
    (config.telescope_over_fzflua and 'lua require("telescope.builtin").diagnostics({ bufnr = 0 })' or "FzfLua lsp_document_diagnostics") ..
    "<cr>", opts) -- Show list of problems
  keymap("n", "lD",
    "<cmd>" ..
    (config.telescope_over_fzflua and 'lua require("telescope.builtin")..diagnostics({ bufnr = nil })' or "FzfLua lsp_workspace_diagnostics") ..
    "<cr>",
    opts)
  keymap("n", "la", -- TODO
    "<cmd>" ..
    (config.telescope_over_fzflua and 'lua require("telescope.builtin").' or "FzfLua lsp_code_actions") .. "<cr>",
    opts)

  -- LSP
  keymap("n", "lu", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
  keymap("n", "lj", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
  keymap("n", "lI", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
  keymap("i", "<C-p>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
  keymap("n", "le", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
  keymap("n", "lR", "<cmd>LspRestart<CR>", opts)

  local function lsp_format_and_notify()
    vim.lsp.buf.format()
    vim.notify("Formatted")
  end
  vim.keymap.set("n", "ll", lsp_format_and_notify, {})

  local overwrite_formatter_on_lsp_attach = false

  if overwrite_formatter_on_lsp_attach then
    vim.api.nvim_create_autocmd('LspAttach', {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client.server_capabilities.documentFormattingProvider then
          vim.keymap.set("n", "ll", vim.lsp.buf.format, { buffer = args.buf })
        end
      end,
    })
  end

  keymap("n", "lL", [[<cmd>lua require("keymaps").lsp_pick_formatter()<CR>]], opts)

  -- Terminal
  if config.terminal_plugin == "floaterm" then
    keymap("n", "<f12>", "<cmd>FloatermToggle<CR>", opts)
    keymap("t", "<f12>", "<cmd>FloatermToggle<CR>", opts)
  end

  -- Comment
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
  keymap("n", "<space>w", ":w<cr>", opts)
  keymap("n", "<space><BS>", ":q!<cr>", opts)
  keymap("n", "<space>s", ":w!<cr>", opts)
  keymap("n", "<space>a", ":qa<cr>", opts)
  keymap("n", "<space><delete>", ":qa!<cr>", opts)

  -- Command line window
  keymap("n", "<space>;", "q:", opts)

  -- Session restore
  keymap("n", "<Space>r", [[<cmd>lua require("persistence").load()<cr>]], opts)

  -- Colorizer
  local function colorizer_toggle_and_notify()
    vim.cmd [[ColorizerToggle]]
    vim.notify("Colorizer toggled")
  end
  vim.keymap.set("n", "<leader>r", colorizer_toggle_and_notify, {})
  local function colorizer_reload_and_notify()
    vim.cmd [[ColorizerReloadAllBuffers]]
    vim.notify("Colorizer reloaded")
  end
  vim.keymap.set("n", "<leader>R", colorizer_reload_and_notify, {})

  -- Nvim Cmp
  vim.keymap.set("i", "<M-w>", function()
    local cmp = require("cmp")

    if cmp.visible() then
      cmp.confirm({ select = true })
    end
  end, {})

  -- Copilot
  if config.copilot_plugin == "vim" then
    keymap("n", "<leader>p", "<cmd>Copilot setup<CR>", opts)
  elseif config.copilot_plugin == "lua" then
    vim.keymap.set("i", "<M-a>", require("copilot.suggestion").accept, {})
    vim.keymap.set("i", "<M-d>", require("copilot.suggestion").next, {})
    vim.keymap.set("i", "<M-e>", require("copilot.suggestion").prev, {})
  end

  if config.ssr_plugin then
    vim.keymap.set({ "n", "v" }, "<leader>f", function() require("ssr").open() end)
  end

  -- Diffview
  keymap("n", "<f11><f1>", "<cmd>DiffviewOpen<cr>", opts)
  keymap("n", "<f11><f2>", "<cmd>DiffviewFileHistory %<cr>", opts) -- See current file git history
  keymap("v", "<f11><f2>", ":DiffviewFileHistory %<cr>", opts)     -- See current selection git history

  -- File tree
  if config.filetree_plugin == "nvimtree" then
    keymap("n", "<f2><f1>", "<cmd>NvimTreeFindFile<cr>", opts)
  end

  -- File managers
  if config.lf_plugin == "vim" then
    keymap("n", "<f2><f2>", "<cmd>LfWorkingDirectory<cr>", opts)
    keymap("n", "<f2><f3>", "<cmd>LfCurrentFile<cr>", opts)
  end
end

M.lsp_pick_formatter = function()
  local clients = vim.lsp.get_active_clients({
    bufnr = 0, -- current buffer
  })

  local format_providers = {}
  for _, c in ipairs(clients) do
    if c.server_capabilities.documentFormattingProvider then
      table.insert(format_providers, c.name)
    end
  end

  vim.ui.select(format_providers, {
    prompt = 'Select format providers:',
    format_item = function(provider_name)
      return provider_name
    end,
  }, function(provider_name)
    vim.lsp.buf.format({
      filter = function(client) return client.name == provider_name end
    })
  end)
end

return M
