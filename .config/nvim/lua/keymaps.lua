local utils = require("utils")
local jumplist = require("jumplist")

local vim_keymap = vim.api.nvim_set_keymap
local opts = { silent = false, noremap = true }
local opts_can_remap = { silent = false, noremap = false }
local opts_expr = { silent = false, expr = true, noremap = true }

local lua_keymap = function(mode, lhs, rhs, opts)
  if rhs ~= nil then vim.keymap.set(mode, lhs, rhs, opts) end
end

-- Pageup/down
vim_keymap("n", "<PageUp>", "<C-u><C-u>", opts)
vim_keymap("n", "<PageDown>", "<C-d><C-d>", opts)
vim_keymap("v", "<PageUp>", "<C-u><C-u>", opts)
vim_keymap("v", "<PageDown>", "<C-d><C-d>", opts)
vim_keymap("i", "<PageUp>", "<C-o><C-u><C-o><C-u>", opts) -- Execute <C-u> twice in normal mode
vim_keymap("i", "<PageDown>", "<C-o><C-d><C-o><C-d>", opts)

-- Find and replace (local)
vim_keymap("n", "rw", "*N:%s///g<left><left>", opts) -- Select next occurrence of word under cursor then go back to current instance
vim_keymap("n", "rr", ":%s//g<left><left>", opts)
vim_keymap("v", "rr", ":s//g<left><left>", opts)
vim_keymap("v", "r.", ":&gc<CR>", opts) -- Reset flags & add flags
vim_keymap("v", "ry", [["ry]], opts) -- Yank it into register "r" for later use with "rp"
local function rp_rhs(whole_file) -- Use register "r" as the replacement rather than the subject
  return function()
    local content = vim.fn.getreg("r")
    local length = #content
    return (
      (whole_file and ":%s" or ":s")
      .. [[//<C-r>r/gc<left><left><left>]]
      .. string.rep("<left>", length)
      .. "<left>"
    )
  end
end
lua_keymap("n", "rp", rp_rhs(true), opts_expr)
lua_keymap("v", "rp", rp_rhs(false), opts_expr)
vim_keymap("v", "ra", [["ry:%s/<C-r>r//gc<left><left><left>]], opts) -- Paste selection into register "y" and paste it into command line with <C-r>
vim_keymap("v", "ri", [["rygv*N:s/<C-r>r//g<left><left>]], opts) -- "ra" but backward direction only. Because ":s///c" doesn't support backward direction, rely on user pressing "N" and "r."
vim_keymap("v", "rk", [["ry:.,$s/<C-r>r//gc<left><left><left>]], opts) -- "ra" but forward direction only

-- Find and replace (global)

-- Move by word
vim_keymap("n", "<C-Left>", "b", opts)
vim_keymap("n", "<C-S-Left>", "B", opts)
vim_keymap("n", "<C-Right>", "w", opts)
vim_keymap("n", "<C-S-Right>", "W", opts)

-- Delete word
vim_keymap("i", "<C-BS>", "<C-W>", opts)
vim_keymap("i", "<C-BS>", "<C-W>", opts)

-- Move/swap line/selection up/down
local auto_indent = false
vim_keymap(
  "n",
  "<C-up>",
  "<cmd>m .-2<CR>" .. (auto_indent and "==" or ""),
  opts
)
vim_keymap(
  "n",
  "<C-down>",
  "<cmd>m .+1<CR>" .. (auto_indent and "==" or ""),
  opts
)
vim_keymap("v", "<C-up>", ":m .-2<CR>gv" .. (auto_indent and "=gv" or ""), opts)
vim_keymap(
  "v",
  "<C-down>",
  ":m '>+1<CR>gv" .. (auto_indent and "=gv" or ""),
  opts
)

-- Delete line
vim_keymap("n", "<M-y>", "dd", opts_can_remap)
vim_keymap("i", "<M-y>", "<C-o><M-y>", opts_can_remap)
vim_keymap("v", "<M-y>", ":d<CR>", opts)

-- Duplicate line/selection
vim_keymap("n", "<M-g>", "<cmd>t .<CR>", opts)
vim_keymap("i", "<M-g>", "<C-o><M-g>", opts_can_remap)
vim_keymap("v", "<M-g>", ":t '><CR>", opts)

-- Matching pair
vim_keymap("n", "m", "%", opts)
vim_keymap("v", "m", "%", opts)

-- Macro
local macro_keymaps = false
if macro_keymaps then
  vim_keymap("n", ",", "@", opts) -- replay macro x
  vim_keymap("n", "<", "Q", opts) -- replay last macro
end

-- Clear search highlights
vim_keymap("n", "<Space>/", "<cmd>noh<CR>", opts)

-- Redo
vim_keymap("n", "U", "<C-R>", opts)

-- New line
vim_keymap("n", "o", "o<Esc>", opts)
vim_keymap("n", "O", "O<Esc>", opts)

-- Fold
vim_keymap("n", "zl", "zo", opts)
vim_keymap("n", "zj", "zc", opts)
vim_keymap("n", "zp", "za", opts)

-- Insert/append swap
vim_keymap("n", "i", "a", opts)
vim_keymap("n", "a", "i", opts)
vim_keymap("n", "I", "A", opts)
vim_keymap("n", "A", "I", opts)
vim_keymap("v", "I", "A", opts)
vim_keymap("v", "A", "I", opts)

-- Home
vim_keymap("n", "<Home>", "^", opts)
vim_keymap("v", "<Home>", "^", opts)
vim_keymap("i", "<Home>", "<C-o>^", opts) -- Execute ^ in normal mode

-- Indent
vim_keymap("n", "<Tab>", ">>", opts)
vim_keymap("n", "<S-Tab>", "<<", opts)
vim_keymap("v", "<Tab>", ">gv", opts) -- keep selection after
vim_keymap("v", "<S-Tab>", "<gv", opts)

-- Yank
vim_keymap("v", "y", "ygv<Esc>", opts) -- Stay at cursor after yank

-- Paste
vim_keymap("v", "p", '"pdP', opts) -- Don't keep the overwritten text in register "+". Instead, keep it in "p"

-- Fold
vim_keymap("n", "z.", "zo", opts)
vim_keymap("n", "z,", "zc", opts)
vim_keymap("n", "z>", "zr", opts)
vim_keymap("n", "z<", "zm", opts)

-- Screen movement
vim_keymap("n", "<S-Up>", "5<C-Y>", opts)
vim_keymap("v", "<S-Up>", "5<C-Y>", opts)
vim_keymap("i", "<S-Up>", "<C-o>5<C-Y>", opts)
vim_keymap("n", "<S-Down>", "5<C-E>", opts)
vim_keymap("v", "<S-Down>", "5<C-E>", opts)
vim_keymap("i", "<S-Down>", "<C-o>5<C-E>", opts)
vim_keymap("n", "<S-Left>", "2<ScrollWheelLeft>", opts)
vim_keymap("v", "<S-Left>", "2<ScrollWheelLeft>", opts)
vim_keymap("i", "<S-Left>", "<C-o>2<ScrollWheelLeft>", opts)
vim_keymap("n", "<S-Right>", "2<ScrollWheelRight>", opts)
vim_keymap("v", "<S-Right>", "2<ScrollWheelRight>", opts)
vim_keymap("i", "<S-Right>", "<C-o>2<ScrollWheelRight>", opts)

-- Window (pane)
vim_keymap("n", "wi", "<cmd>wincmd k<CR>", opts)
vim_keymap("n", "wk", "<cmd>wincmd j<CR>", opts)
vim_keymap("n", "wj", "<cmd>wincmd h<CR>", opts)
vim_keymap("n", "wl", "<cmd>wincmd l<CR>", opts)
vim_keymap("n", "<C-e>", "<cmd>wincmd k<CR>", opts)
vim_keymap("n", "<C-d>", "<cmd>wincmd j<CR>", opts)
vim_keymap("n", "<C-s>", "<cmd>wincmd h<CR>", opts)
vim_keymap("n", "<C-f>", "<cmd>wincmd l<CR>", opts)

vim_keymap("n", "<C-S-->", "10<C-w>-", opts) -- Decrease height
vim_keymap("n", "<C-S-=>", "10<C-w>+", opts) -- Increase height
vim_keymap("n", "<C-S-.>", "20<C-w>>", opts) -- Increase width
vim_keymap("n", "<C-S-,>", "20<C-w><", opts) -- Decrease width

vim_keymap("n", "ww", "<cmd>clo<CR>", opts)

vim_keymap("n", "wd", "<cmd>split<CR>", opts)
vim_keymap("n", "wf", "<cmd>vsplit<CR>", opts)
vim_keymap("n", "we", "<cmd>split<CR>", opts)
vim_keymap("n", "ws", "<cmd>vsplit<CR>", opts)

vim_keymap("n", "wt", "<cmd>wincmd T<CR>", opts) -- Move to new tab

vim_keymap("n", "wz", "<C-W>_<C-W>|", opts) -- Maximise both horizontally and vertically
vim_keymap("n", "wx", "<C-W>=", opts)

-- Tab
vim_keymap("n", "tj", "<cmd>tabp<CR>", opts)
vim_keymap("n", "tl", "<cmd>tabn<CR>", opts)
vim_keymap("n", "tt", "<cmd>tabnew<CR>", opts)
local close_tab_and_left = function()
  local is_only_tab = vim.fn.tabpagenr("$") == 1
  if is_only_tab then
    vim.cmd([[tabnew]])
    vim.cmd([[tabprevious]])
  end

  vim.cmd([[tabclose]])

  local is_last_tab = vim.fn.tabpagenr("$")
    == vim.api.nvim_tabpage_get_number(0)
  if not is_last_tab and vim.fn.tabpagenr() > 1 then
    vim.cmd([[tabprevious]])
  end
end
lua_keymap("n", "tw", close_tab_and_left, {})
vim_keymap("n", "<C-j>", "<cmd>tabp<CR>", opts)
vim_keymap("n", "<C-l>", "<cmd>tabn<CR>", opts)

vim_keymap("n", "tu", "<cmd>tabm -1<CR>", opts)
vim_keymap("n", "to", "<cmd>tabm +1<CR>", opts)
vim_keymap("n", "<C-S-j>", "<cmd>tabm -1<CR>", opts)
vim_keymap("n", "<C-S-l>", "<cmd>tabm +1<CR>", opts)

-- Delete & cut
vim_keymap("n", "d", '"dd', opts) -- Put in d register, in case if needed
vim_keymap("v", "d", '"dd', opts)
vim_keymap("n", "x", "d", opts)
vim_keymap("v", "x", "d", opts)
vim_keymap("n", "xx", "dd", opts)
vim_keymap("n", "X", "D", opts)

-- Change (add to register 'd')
vim_keymap("n", "c", '"dc', opts)
vim_keymap("n", "C", '"dC', opts)
vim_keymap("v", "c", '"dc', opts)
vim_keymap("v", "C", '"dC', opts)

-- Jump (jumplist)
lua_keymap("n", "<C-u>", jumplist.jump_back, {})
lua_keymap("n", "<C-o>", jumplist.jump_forward, {})

-- Fzf/FzfLua

lua_keymap("n", "<f1>", require("fzf-lua").builtin, {})

lua_keymap("n", "<f3><f3>", require("fzf.files").files, {})
lua_keymap("n", "<f3><f4>", function()
  require("fzf.git").git_submodules(
    function(submodule_path)
      require("fzf.files").files({
        git_dir = submodule_path,
      })
    end
  )
end, {})

lua_keymap("n", "<f3><f2>", require("fzf.misc").buffers, {})
lua_keymap("n", "<f3><f1>", require("fzf.misc").tabs, {})

lua_keymap("n", "<f5><f4>", require("fzf.grep").grep_file, {})
lua_keymap("n", "<f5><f5>", require("fzf.grep").grep, {})
lua_keymap(
  "v",
  "<f5><f4>",
  function()
    require("fzf.grep").grep_file({
      initial_query = utils.get_visual_selection(),
    })
  end,
  {}
)
lua_keymap(
  "v",
  "<f5><f5>",
  function()
    require("fzf.grep").grep({
      initial_query = utils.get_visual_selection(),
    })
  end,
  {}
)

lua_keymap("n", "<f11><f5>", require("fzf.git").git_commits, {})
lua_keymap("n", "<f10><f5>", function()
  require("fzf.git").git_submodules(
    function(submodule_path)
      require("fzf.git").git_commits({
        git_dir = submodule_path,
      })
    end
  )
end, {})
lua_keymap(
  "n",
  "<f11><f4>",
  function()
    require("fzf.git").git_commits({ filepaths = vim.fn.expand("%:p") })
  end,
  {}
)
lua_keymap("n", "<f10><f4>", function()
  require("fzf.git").git_submodules(
    function(submodule_path)
      require("fzf.git").git_commits({
        git_dir = submodule_path,
        filepaths = vim.fn.expand("%"),
      })
    end
  )
end, {})
lua_keymap("n", "<f11><f3>", require("fzf.git").git_status, {})
lua_keymap("n", "<f10><f4>", function()
  require("fzf.git").git_submodules(
    function(submodule_path)
      require("fzf.git").git_status({
        git_dir = submodule_path,
      })
    end
  )
end, {})
lua_keymap("n", "<f11><f11>", nil, {})

lua_keymap("n", "li", require("fzf.lsp").lsp_definitions, {})
lua_keymap("n", "lr", require("fzf.lsp").lsp_references, {})
lua_keymap("n", "<f4><f4>", require("fzf.lsp").lsp_document_symbols, {})
lua_keymap("n", "<f4><f5>", require("fzf.lsp").lsp_workspace_symbols, {})
lua_keymap(
  "n",
  "ld",
  function()
    require("fzf.diagnostics").diagnostics({
      current_buffer_only = true,
    })
  end,
  {}
)
lua_keymap("n", "lD", require("fzf.diagnostics").diagnostics, {})
lua_keymap("n", "la", nil, {})

lua_keymap("n", "<space>u", require("fzf.undo").undos, {})
lua_keymap("n", "<space>m", require("fzf.notification").notifications, {})
lua_keymap("n", "<space>j", require("fzf.jump").jumps, {})

-- LSP
vim_keymap("n", "lu", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
vim_keymap("n", "lj", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
vim_keymap("n", "lI", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
vim_keymap("i", "<C-p>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
vim_keymap("n", "le", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
vim_keymap("n", "lR", "<cmd>LspRestart<CR>", opts)
vim_keymap("n", "<space>l", "<cmd>LspInfo<CR>", opts)

local conform_over_lsp_format = true

if conform_over_lsp_format then
  lua_keymap("n", "ll", function()
    local success = require("conform").format()
    if success then
      return vim.info(
        "Formatted with",
        require("conform").list_formatters()[1].name
      )
    else
      vim.info("No available formatters")
    end
  end, {})
else
  lua_keymap("n", "ll", function()
    vim.lsp.buf.format()
    vim.info("Formatted")
  end, {})
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
    prompt = "Select format providers:",
    format_item = function(provider_name) return provider_name end,
  }, function(provider_name)
    vim.lsp.buf.format({
      filter = function(client) return client.name == provider_name end,
    })
  end)
end

local conform_pick_formatter = function()
  local formatters = require("conform").list_formatters()
  formatters = utils.filter(
    formatters,
    function(_, formatter) return formatter.available end
  )
  vim.ui.select(
    formatters,
    {
      prompt = "Select formatter:",
      format_item = function(formatter) return formatter.name end,
    },
    function(formatter)
      require("conform").format({ formatters = formatter.name })
    end
  )
end

if conform_over_lsp_format then
  lua_keymap("n", "lL", conform_pick_formatter, {})
else
  lua_keymap("n", "lL", lsp_pick_formatter, {})
end

-- Comment
vim_keymap("n", "<C-/>", "<Plug>(comment_toggle_linewise_current)", opts)
vim_keymap("v", "<C-/>", "<Plug>(comment_toggle_linewise_visual)gv", opts) -- Re-select the last block
local comment_api = require("Comment.api")
if not vim.tbl_isempty(comment_api) then
  lua_keymap("i", "<C-/>", comment_api.toggle.linewise.current, {})
end

-- GitSigns
vim_keymap("n", "su", "<cmd>Gitsigns preview_hunk_inline<CR>", opts)
vim_keymap("n", "si", "<cmd>Gitsigns prev_hunk<CR>", opts)
vim_keymap("n", "sk", "<cmd>Gitsigns next_hunk<CR>", opts)
vim_keymap("n", "sb", "<cmd>Gitsigns blame_line<CR>", opts)
vim_keymap("n", "sj", "<cmd>Gitsigns stage_hunk<CR>", opts)
vim_keymap("n", "sl", "<cmd>Gitsigns undo_stage_hunk<CR>", opts)
vim_keymap("n", "s;", "<cmd>Gitsigns reset_hunk<CR>", opts)

-- :qa, :q!, :wq
vim_keymap("n", "<space>q", ":q<cr>", opts)
vim_keymap("n", "<space>w", ":w<cr>", opts)
vim_keymap("n", "<space><BS>", ":q!<cr>", opts)
vim_keymap("n", "<space>s", ":w!<cr>", opts)
vim_keymap("n", "<space>a", ":qa<cr>", opts)
vim_keymap("n", "<space>e", ":e<cr>", opts)
vim_keymap("n", "<space><delete>", ":qa!<cr>", opts)

-- Command line window
vim_keymap("n", "<space>;", "q:", opts)

-- Session restore
lua_keymap("n", "<Space>r", function()
  require("persist").load_session()
  vim.info("Reloaded session")
end, {})

-- Colorizer
lua_keymap("n", "<leader>c", function()
  vim.cmd([[ColorizerToggle]])
  vim.info("Colorizer toggled")
end, {})
lua_keymap("n", "<leader>C", function()
  vim.cmd([[ColorizerReloadAllBuffers]])
  vim.info("Colorizer reloaded")
end, {})

-- Nvim Cmp
lua_keymap("i", "<M-r>", function()
  local cmp = require("cmp")

  if cmp.visible() then cmp.confirm({ select = true }) end
end, {})

-- Copilot
lua_keymap("n", "<leader>a", "<cmd>Copilot enable<CR>", {})
lua_keymap("i", "<M-a>", require("copilot.suggestion").accept, {})
lua_keymap("i", "<M-w>", require("copilot.suggestion").accept_line, {})
lua_keymap("i", "<M-d>", require("copilot.suggestion").next, {})
lua_keymap("i", "<M-e>", require("copilot.suggestion").prev, {})
lua_keymap("i", "<M-q>", require("copilot.panel").open, {})
lua_keymap("n", "<M-e>", require("copilot.panel").jump_prev, {})
lua_keymap("n", "<M-d>", require("copilot.panel").jump_next, {})
lua_keymap("n", "<M-a>", require("copilot.panel").accept, {})

-- File managers
lua_keymap("n", "<f2><f2>", require("lf").lf, {})
lua_keymap("n", "<f2><f3>", function()
  require("lf").lf({
    path = vim.fn.expand("%:p"), -- Relative to ~ doesn't work
  })
end, {})

-- Copy path
lua_keymap("n", "<leader>g", function()
  local path = vim.fn.expand("%:~")
  vim.fn.setreg("+", path)
  vim.info("Copied", path)
end, {})
