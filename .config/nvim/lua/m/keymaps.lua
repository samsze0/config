local M = {}

local config = require('m.config')
local utils = require('m.utils')
local safe_require = function(module)
  return utils.safe_require(module, {
    notify = false,
    log_level = vim.log.levels.ERROR,
  })
end

M.setup = function()
  local keymap = vim.api.nvim_set_keymap
  local opts = { silent = true, noremap = true }
  local opts_can_remap = { silent = true, noremap = false }
  local opts_expr = { silent = true, expr = true, noremap = true }

  -- Pageup/down
  keymap("n", "<PageUp>", "<C-u><C-u>", opts)
  keymap("n", "<PageDown>", "<C-d><C-d>", opts)
  keymap("v", "<PageUp>", "<C-u><C-u>", opts)
  keymap("v", "<PageDown>", "<C-d><C-d>", opts)
  keymap("i", "<PageUp>", "<C-o><C-u><C-o><C-u>", opts) -- Execute <C-u> twice in normal mode
  keymap("i", "<PageDown>", "<C-o><C-d><C-o><C-d>", opts)

  -- Find and replace (local)
  keymap("n", "rw", "*N:%s///g<left><left>", opts) -- Select next occurrence of word under cursor then go back to current instance
  keymap("n", "rr", ":%s//g<left><left>", opts)
  keymap("v", "rr", ":s//g<left><left>", opts)
  keymap("n", "r.", ":&c<cr>", opts) -- Multiple "c" flags are acceptable
  keymap("v", "ry", [["ry]], opts)   -- Yank it into register "r" for later use with "rp"
  local function rp_rhs(whole_file)  -- Use register "r" as the replacement rather than the subject
    return function()
      return ((whole_file and ":%s" or ":s") .. [[//<C-r>r/gc<left><left><left>]] ..
        string.rep("<left>", utils.get_register_length("r")) ..
        "<left>")
    end
  end
  vim.keymap.set("n", "rp", rp_rhs(true), opts_expr)
  vim.keymap.set("v", "rp", rp_rhs(false), opts_expr)
  keymap("v", "ra", [["ry:%s/<C-r>r//gc<left><left><left>]], opts)   -- Paste selection into register "y" and paste it into command line with <C-r>
  keymap("v", "ri", [["rygv*N:s/<C-r>r//g<left><left>]], opts)       -- "ra" but backward direction only. Because ":s///c" doesn't support backward direction, rely on user pressing "N" and "r."
  keymap("v", "rk", [["ry:.,$s/<C-r>r//gc<left><left><left>]], opts) -- "ra" but forward direction only

  -- Find and replace (global)

  -- Move by word
  keymap("n", "<C-Left>", "B", opts)
  keymap("n", "<C-Right>", "W", opts)

  -- Delete word
  keymap("i", "<C-BS>", "<C-W>", opts)
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
  local macro_keymaps = false
  if macro_keymaps then
    keymap("n", ",", "@", opts) -- replay macro x
    keymap("n", "<", "Q", opts) -- replay last macro
  end

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

  -- Yank
  keymap("v", "y", "ygv<Esc>", opts) -- Stay at cursor after yank

  -- Paste
  keymap("v", "p", '"pdP', opts) -- Don't keep the overwritten text in register "+". Instead, keep it in "p"

  -- Fold
  keymap("n", "z.", "zo", opts)
  keymap("n", "z,", "zc", opts)
  keymap("n", "z>", "zr", opts)
  keymap("n", "z<", "zm", opts)

  -- Screen movement
  keymap("n", "<S-Up>", "5<C-Y>", opts)
  keymap("v", "<S-Up>", "5<C-Y>", opts)
  keymap("i", "<S-Up>", "<C-o>5<C-Y>", opts)
  keymap("n", "<S-Down>", "5<C-E>", opts)
  keymap("v", "<S-Down>", "5<C-E>", opts)
  keymap("i", "<S-Down>", "<C-o>5<C-E>", opts)
  keymap("n", "<S-Left>", "2<ScrollWheelLeft>", opts)
  keymap("v", "<S-Left>", "2<ScrollWheelLeft>", opts)
  keymap("i", "<S-Left>", "<C-o>2<ScrollWheelLeft>", opts)
  keymap("n", "<S-Right>", "2<ScrollWheelRight>", opts)
  keymap("v", "<S-Right>", "2<ScrollWheelRight>", opts)
  keymap("i", "<S-Right>", "<C-o>2<ScrollWheelRight>", opts)

  -- Window (pane)
  keymap("n", "wi", "<cmd>wincmd k<CR>", opts)
  keymap("n", "wk", "<cmd>wincmd j<CR>", opts)
  keymap("n", "wj", "<cmd>wincmd h<CR>", opts)
  keymap("n", "wl", "<cmd>wincmd l<CR>", opts)
  keymap("n", "<C-e>", "<cmd>wincmd k<CR>", opts)
  keymap("n", "<C-d>", "<cmd>wincmd j<CR>", opts)
  keymap("n", "<C-s>", "<cmd>wincmd h<CR>", opts)
  keymap("n", "<C-f>", "<cmd>wincmd l<CR>", opts)

  keymap("n", "<C-S-->", "10<C-w>-", opts) -- Decrease height
  keymap("n", "<C-S-=>", "10<C-w>+", opts) -- Increase height
  keymap("n", "<C-S-.>", "20<C-w>>", opts) -- Increase width
  keymap("n", "<C-S-,>", "20<C-w><", opts) -- Decrease width

  keymap("n", "ww", "<cmd>clo<CR>", opts)

  keymap("n", "wd", "<cmd>split<CR><cmd>wincmd j<CR>", opts) -- Switch to bottom window after creating it
  keymap("n", "wf", "<cmd>vsplit<CR><cmd>wincmd l<CR>", opts)
  keymap("n", "we", "<cmd>split<CR>", opts)
  keymap("n", "ws", "<cmd>vsplit<CR>", opts)

  keymap("n", "wt", "<cmd>wincmd T<CR>", opts) -- Move to new tab

  local maximize_plugin = config.maximize_plugin

  if maximize_plugin then
    vim.keymap.set("n", 'wz', safe_require('maximize').toggle, {})
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
  keymap("n", "d", '"dd', opts) -- Put in d register, in case if needed
  keymap("v", "d", '"dd', opts)
  keymap("n", "x", "d", opts)
  keymap("v", "x", "d", opts)
  keymap("n", "xx", "dd", opts)
  keymap("n", "X", "D", opts)

  -- Change (add to register 'd')
  keymap('n', 'c', '"dc', opts)
  keymap('n', 'C', '"dC', opts)
  keymap('v', 'c', '"dc', opts)
  keymap('v', 'C', '"dC', opts)

  -- Jump (jumplist)
  keymap("n", "<C-u>", "<C-o>", opts)
  keymap("n", "<C-o>", "<C-i>", opts)

  -- Telescope / FzfLua
  local fuzzy_finder_keymaps = {
    [{ mode = "n", lhs = "<f1>" }] = {
      telescope = safe_require("telescope.builtin").builtin,
      fzflua = safe_require('fzf-lua').builtin,
    },
    [{ mode = "n", lhs = "<f3><f3>" }] = {
      telescope = safe_require("telescope.builtin").find_files,
      fzflua = safe_require('fzf-lua').files,
    },
    [{ mode = "n", lhs = "<f3><f2>" }] = {
      telescope = safe_require("telescope.builtin").buffers,
      fzflua = safe_require('fzf-lua').buffers,
    },
    [{ mode = "n", lhs = "<f3><f1>" }] = {
      telescope = nil,
      fzflua = safe_require('fzf-lua').tabs,
    },
    [{ mode = "n", lhs = "<f5><f5>" }] = {
      telescope = safe_require("telescope.builtin").live_grep,
      fzflua = safe_require('fzf-lua').live_grep,
    },
    [{ mode = "n", lhs = "<f11><f5>" }] = {
      telescope = safe_require("telescope.builtin").git_commits,
      fzflua = safe_require('fzf-lua').git_commits,
    },
    [{ mode = "n", lhs = "<f11><f4>" }] = {
      telescope = safe_require("telescope.builtin").git_bcommits,
      fzflua = safe_require('fzf-lua').git_bcommits,
    },
    [{ mode = "n", lhs = "<f11><f3>" }] = {
      telescope = safe_require("telescope.builtin").git_status,
      fzflua = safe_require('fzf-lua').git_status,
    },
    [{ mode = "n", lhs = "li" }] = {
      telescope = safe_require("telescope.builtin").lsp_definitions,
      fzflua = safe_require('fzf-lua').lsp_definitions,
    },
    [{ mode = "n", lhs = "lr" }] = {
      telescope = safe_require("telescope.builtin").lsp_references,
      fzflua = safe_require('fzf-lua').lsp_references,
    },
    [{ mode = "n", lhs = "<f4><f4>" }] = {
      telescope = safe_require("telescope.builtin").lsp_document_symbols,
      fzflua = safe_require('fzf-lua').lsp_document_symbols,
    },
    [{ mode = "n", lhs = "<f4><f5>" }] = {
      telescope = safe_require("telescope.builtin").lsp_workspace_symbols,
      fzflua = safe_require('fzf-lua').lsp_workspace_symbols,
    },
    [{ mode = "n", lhs = "ld" }] = {
      telescope = safe_require("telescope.builtin").lsp_document_diagnostics,
      fzflua = safe_require('fzf-lua').lsp_document_diagnostics,
    },
    [{ mode = "n", lhs = "lD" }] = {
      telescope = safe_require("telescope.builtin").lsp_workspace_diagnostics,
      fzflua = safe_require('fzf-lua').lsp_workspace_diagnostics,
    },
    [{ mode = "n", lhs = "la" }] = {
      telescope = nil,
      fzflua = safe_require('fzf-lua').lsp_code_actions
    },
    [{ mode = "n", lhs = "<f5><f4>" }] = {
      telescope = nil,
      fzflua = safe_require('fzf-lua').blines
    },
    [{ mode = "n", lhs = "<space>u" }] = {
      telescope = nil,
      fzflua = safe_require('m.fzflua').undo_tree
    },
    [{ mode = "n", lhs = "<space>m" }] = {
      telescope = nil,
      fzflua = safe_require('m.fzflua').notifications
    },
  }

  for k, v in pairs(fuzzy_finder_keymaps) do
    if v.telescope ~= nil then
      vim.keymap.set(k.mode, k.lhs, v.telescope, {})
    end
    if v.fzflua ~= nil then
      vim.keymap.set(k.mode, k.lhs, v.fzflua, {})
    end
  end

  -- LSP
  keymap("n", "lu", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
  keymap("n", "lj", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
  keymap("n", "lI", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
  keymap("i", "<C-p>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
  keymap("n", "le", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
  keymap("n", "lR", "<cmd>LspRestart<CR>", opts)

  vim.keymap.set("n", "ll", utils.run_and_notify(vim.lsp.buf.format, "Formatted"), {})

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

  local lsp_pick_formatter = function()
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
  vim.keymap.set("n", "lL", lsp_pick_formatter, {})

  -- Terminal
  if config.terminal_plugin == "floaterm" then
    keymap("n", "<f12>", "<cmd>FloatermToggle<CR>", opts)
    keymap("t", "<f12>", "<cmd>FloatermToggle<CR>", opts)
  end

  -- Comment
  keymap("n", "<C-/>", "<Plug>(comment_toggle_linewise_current)", opts)
  keymap("v", "<C-/>", "<Plug>(comment_toggle_linewise_visual)gv", opts) -- Re-select the last block
  vim.keymap.set("i", "<C-/>", require("Comment.api").toggle.linewise.current, {})

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
  keymap("n", "<space>e", ":e<cr>", opts)
  keymap("n", "<space><delete>", ":qa!<cr>", opts)

  -- Command line window
  keymap("n", "<space>;", "q:", opts)

  -- Session restore
  vim.keymap.set("n", "<Space>r", require("persistence").load, {})

  -- Colorizer
  vim.keymap.set("n", "<leader>c", utils.run_and_notify(function()
    vim.cmd [[ColorizerToggle]]
  end, "Colorizer toggled"), {})
  vim.keymap.set("n", "<leader>C", utils.run_and_notify(function()
    vim.cmd [[ColorizerReloadAllBuffers]]
  end, "Colorizer reloaded"), {})

  -- Nvim Cmp
  vim.keymap.set("i", "<M-r>", function()
    local cmp = require("cmp")

    if cmp.visible() then
      cmp.confirm({ select = true })
    end
  end, {})

  -- Copilot
  if config.copilot_plugin == "vim" then
    keymap("n", "<leader>p", "<cmd>Copilot setup<CR>", opts)
  elseif config.copilot_plugin == "lua" then
    vim.keymap.set("i", "<M-a>", safe_require("copilot.suggestion").accept, {})
    vim.keymap.set("i", "<M-w>", safe_require("copilot.suggestion").accept_line, {})
    vim.keymap.set("i", "<M-d>", safe_require("copilot.suggestion").next, {})
    vim.keymap.set("i", "<M-e>", safe_require("copilot.suggestion").prev, {})
  end

  if config.ssr_plugin then
    vim.keymap.set({ "n", "v" }, "<leader>f", safe_require("ssr").open, {})
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

return M
