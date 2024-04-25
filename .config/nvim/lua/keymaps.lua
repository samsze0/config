local utils = require("utils")
local jumplist = require("jumplist")
local conform = require("conform")

local M = {}

---@alias VimMode "n" | "v" | "i"

---@param mode VimMode | VimMode[]
---@param lhs string
---@param rhs string | function
---@param opts? { silent?: boolean, noremap?: boolean, expr?: boolean }
local function create_keymap_lua(mode, lhs, rhs, opts)
  return vim.keymap.set(mode, lhs, rhs, opts or {})
end
M.create_keymap_lua = create_keymap_lua

---@param mode VimMode | VimMode[]
---@param lhs string
---@param rhs string
---@param opts? { silent?: boolean, noremap?: boolean, expr?: boolean }
local function create_keymap_vim(mode, lhs, rhs, opts)
  opts = utils.opts_extend({
    silent = false,
    noremap = true,
    expr = false,
  }, opts)

  if type(mode) == "table" then
    for _, m in ipairs(mode) do
      create_keymap_vim(m, lhs, rhs, opts)
    end
  else
    return vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
  end
end
M.create_keymap_vim = create_keymap_vim

---@param name string
---@param command string | function
---@param opts? { }
local function create_command_vim(name, command, opts)
  opts = utils.opts_extend({}, opts)

  return vim.api.nvim_create_user_command(name, command, opts)
end
M.create_command_vim = create_command_vim

-- Pageup/down
create_keymap_vim("n", "<PageUp>", "<C-u><C-u>")
create_keymap_vim("n", "<PageDown>", "<C-d><C-d>")
create_keymap_vim("v", "<PageUp>", "<C-u><C-u>")
create_keymap_vim("v", "<PageDown>", "<C-d><C-d>")
create_keymap_vim("i", "<PageUp>", "<C-o><C-u><C-o><C-u>") -- Execute <C-u> twice in normal mode
create_keymap_vim("i", "<PageDown>", "<C-o><C-d><C-o><C-d>")

-- Find and replace (local)
-- TODO: lua plugin?
create_keymap_vim("n", "rw", "*N:%s///g<left><left>") -- Select next occurrence of word under cursor then go back to current instance
create_keymap_vim("n", "rr", ":%s//g<left><left>")
create_keymap_vim("v", "rr", ":s//g<left><left>")
create_keymap_vim("v", "r.", ":&gc<CR>") -- Reset flags & add flags
create_keymap_vim("v", "ry", [["ry]]) -- Yank it into register "r" for later use with "rp"
local function rp_rhs(whole_file) -- Use register "r" as the replacement rather than the subject
  return function()
    local content = vim.fn.getreg("r")
    local length = #content
    return (
      (whole_file and ":%s" or ":s")
      .. [[//<C-r>r/gc<left><left><left>]]
      .. ("<left>"):rep(length)
      .. "<left>"
    )
  end
end
create_keymap_lua("n", "rp", rp_rhs(true), { expr = true })
create_keymap_lua("v", "rp", rp_rhs(false), { expr = true })
create_keymap_vim("v", "ra", [["ry:%s/<C-r>r//gc<left><left><left>]]) -- Paste selection into register "y" and paste it into command line with <C-r>
create_keymap_vim("v", "ri", [["rygv*N:s/<C-r>r//g<left><left>]]) -- "ra" but backward direction only. Because ":s///c" doesn't support backward direction, rely on user pressing "N" and "r."
create_keymap_vim("v", "rk", [["ry:.,$s/<C-r>r//gc<left><left><left>]]) -- "ra" but forward direction only

-- Diff
create_keymap_lua("n", "sj", function()
  local diff_buffers = vim.t.diff_buffers ---@diagnostic disable-line: undefined-field
  if not diff_buffers then vim.error("Not in diff mode") end
  utils.switch(vim.api.nvim_get_current_buf(), {
    [diff_buffers[2]] = function()
      vim.cmd(([[diffget %s]]):format(diff_buffers[1]))
    end,
    [diff_buffers[3]] = function()
      vim.cmd(([[diffput %s]]):format(diff_buffers[2]))
    end,
  }, nil)
end)
create_keymap_lua("n", "sl", function()
  local diff_buffers = vim.t.diff_buffers ---@diagnostic disable-line: undefined-field
  if not diff_buffers then vim.error("Not in diff mode") end
  utils.switch(vim.api.nvim_get_current_buf(), {
    [diff_buffers[2]] = function()
      vim.cmd(([[diffget %s]]):format(diff_buffers[3]))
    end,
    [diff_buffers[1]] = function()
      vim.cmd(([[diffput %s]]):format(diff_buffers[2]))
    end,
  }, nil)
end)

-- Move by word
create_keymap_vim("n", "<C-Left>", "b")
create_keymap_vim("n", "<C-S-Left>", "B")
create_keymap_vim("n", "<C-Right>", "w")
create_keymap_vim("n", "<C-S-Right>", "W")

-- Delete word
create_keymap_vim("i", "<C-BS>", "<C-W>")

-- Move/swap line/selection up/down
local auto_indent = false
create_keymap_vim(
  "n",
  "<C-up>",
  "<cmd>m .-2<CR>" .. (auto_indent and "==" or "")
)
create_keymap_vim(
  "n",
  "<C-down>",
  "<cmd>m .+1<CR>" .. (auto_indent and "==" or "")
)
create_keymap_vim(
  "v",
  "<C-up>",
  ":m .-2<CR>gv" .. (auto_indent and "=gv" or "")
)
create_keymap_vim(
  "v",
  "<C-down>",
  ":m '>+1<CR>gv" .. (auto_indent and "=gv" or "")
)

-- Delete line
create_keymap_vim("n", "<M-y>", "dd", { noremap = false })
create_keymap_vim("i", "<M-y>", "<C-o><M-y>", { noremap = false })
create_keymap_vim("v", "<M-y>", ":d<CR>")

-- Duplicate line/selection
create_keymap_vim("n", "<M-g>", "<cmd>t .<CR>")
create_keymap_vim("i", "<M-g>", "<C-o><M-g>", { noremap = false })
create_keymap_vim("v", "<M-g>", ":t '><CR>")

-- Matching pair
create_keymap_vim("n", "m", "%")
create_keymap_vim("v", "m", "%")

-- Macro
local macro_keymaps = false
if macro_keymaps then
  create_keymap_vim("n", ",", "@") -- replay macro x
  create_keymap_vim("n", "<", "Q") -- replay last macro
end

-- Clear search highlights
create_keymap_vim("n", "<Space>/", "<cmd>noh<CR>")

-- Redo
create_keymap_vim("n", "U", "<C-R>")

-- New line
create_keymap_vim("n", "o", "o<Esc>")
create_keymap_vim("n", "O", "O<Esc>")

-- Fold
create_keymap_vim("n", "zl", "zo")
create_keymap_vim("n", "zj", "zc")
create_keymap_vim("n", "zp", "za")

-- Insert/append swap
create_keymap_vim("n", "i", "a")
create_keymap_vim("n", "a", "i")
create_keymap_vim("n", "I", "A")
create_keymap_vim("n", "A", "I")
create_keymap_vim("v", "I", "A")
create_keymap_vim("v", "A", "I")

-- Home
create_keymap_vim("n", "<Home>", "^")
create_keymap_vim("v", "<Home>", "^")
create_keymap_vim("i", "<Home>", "<C-o>^") -- Execute ^ in normal mode

-- Indent
create_keymap_vim("n", "<Tab>", ">>")
create_keymap_vim("n", "<S-Tab>", "<<")
create_keymap_vim("v", "<Tab>", ">gv") -- keep selection after
create_keymap_vim("v", "<S-Tab>", "<gv")

-- Yank
create_keymap_vim("v", "y", "ygv<Esc>") -- Stay at cursor after yank

-- Paste
create_keymap_vim("v", "p", '"pdP') -- Don't keep the overwritten text in register "+". Instead, keep it in "p"

-- Fold
create_keymap_vim("n", "z.", "zo")
create_keymap_vim("n", "z,", "zc")
create_keymap_vim("n", "z>", "zr")
create_keymap_vim("n", "z<", "zm")

-- Screen movement
create_keymap_vim("n", "<S-Up>", "5<C-Y>")
create_keymap_vim("v", "<S-Up>", "5<C-Y>")
create_keymap_vim("i", "<S-Up>", "<C-o>5<C-Y>")
create_keymap_vim("n", "<S-Down>", "5<C-E>")
create_keymap_vim("v", "<S-Down>", "5<C-E>")
create_keymap_vim("i", "<S-Down>", "<C-o>5<C-E>")
create_keymap_vim("n", "<S-Left>", "2<ScrollWheelLeft>")
create_keymap_vim("v", "<S-Left>", "2<ScrollWheelLeft>")
create_keymap_vim("i", "<S-Left>", "<C-o>2<ScrollWheelLeft>")
create_keymap_vim("n", "<S-Right>", "2<ScrollWheelRight>")
create_keymap_vim("v", "<S-Right>", "2<ScrollWheelRight>")
create_keymap_vim("i", "<S-Right>", "<C-o>2<ScrollWheelRight>")

-- Window (pane)
create_keymap_vim("n", "wi", "<cmd>wincmd k<CR>")
create_keymap_vim("n", "wk", "<cmd>wincmd j<CR>")
create_keymap_vim("n", "wj", "<cmd>wincmd h<CR>")
create_keymap_vim("n", "wl", "<cmd>wincmd l<CR>")
create_keymap_vim("n", "<C-e>", "<cmd>wincmd k<CR>")
create_keymap_vim("n", "<C-d>", "<cmd>wincmd j<CR>")
create_keymap_vim("n", "<C-s>", "<cmd>wincmd h<CR>")
create_keymap_vim("n", "<C-f>", "<cmd>wincmd l<CR>")

-- TODO: more intuitive control with lua
create_keymap_vim("n", "<C-S-->", "10<C-w>-") -- Decrease height
create_keymap_vim("n", "<C-S-=>", "10<C-w>+") -- Increase height
create_keymap_vim("n", "<C-S-.>", "20<C-w>>") -- Increase width
create_keymap_vim("n", "<C-S-,>", "20<C-w><") -- Decrease width

create_keymap_vim("n", "ww", "<cmd>clo<CR>")

create_keymap_vim("n", "wd", "<cmd>split<CR>")
create_keymap_vim("n", "wf", "<cmd>vsplit<CR>")
create_keymap_vim("n", "we", "<cmd>split<CR>")
create_keymap_vim("n", "ws", "<cmd>vsplit<CR>")

create_keymap_vim("n", "wt", "<cmd>wincmd T<CR>") -- Move to new tab

-- TODO: remove
create_keymap_vim("n", "wz", "<C-W>_<C-W>|") -- Maximise both horizontally and vertically
create_keymap_vim("n", "wx", "<C-W>=")

-- Tab
create_keymap_vim("n", "tj", "<cmd>tabp<CR>")
create_keymap_vim("n", "tl", "<cmd>tabn<CR>")
create_keymap_vim("n", "tt", "<cmd>tabnew<CR>")
local close_tab = function()
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
create_keymap_lua("n", "tw", close_tab)
create_keymap_vim("n", "tq", "<cmd>tabonly<CR>")
create_keymap_vim("n", "<C-j>", "<cmd>tabp<CR>")
create_keymap_vim("n", "<C-l>", "<cmd>tabn<CR>")

create_keymap_vim("n", "tu", "<cmd>tabm -1<CR>")
create_keymap_vim("n", "to", "<cmd>tabm +1<CR>")
create_keymap_vim("n", "<C-S-j>", "<cmd>tabm -1<CR>")
create_keymap_vim("n", "<C-S-l>", "<cmd>tabm +1<CR>")

-- Delete & cut
create_keymap_vim("n", "d", '"dd') -- Put in d register, in case if needed
create_keymap_vim("v", "d", '"dd')
create_keymap_vim("n", "x", "d")
create_keymap_vim("v", "x", "d")
create_keymap_vim("n", "xx", "dd")
create_keymap_vim("n", "X", "D")

-- Change (add to register 'd')
create_keymap_vim("n", "c", '"dc')
create_keymap_vim("n", "C", '"dC')
create_keymap_vim("v", "c", '"dc')
create_keymap_vim("v", "C", '"dC')

-- Jump (jumplist)
create_keymap_lua("n", "<C-u>", jumplist.jump_back)
create_keymap_lua("n", "<C-o>", jumplist.jump_forward)

-- Fzf/FzfLua

create_keymap_lua("n", "<f1>", require("fzf-lua").builtin)

create_keymap_lua(
  "n",
  "<f3><f3>",
  function() require("fzf.files")():start() end
)

create_keymap_lua(
  "n",
  "<f3><f2>",
  function() require("fzf.buffers")():start() end
)
create_keymap_lua("n", "<f3><f1>", function() require("fzf.tabs")():start() end)

create_keymap_lua(
  "n",
  "<f5><f4>",
  function() require("fzf.grep.file")():start() end
)
create_keymap_lua(
  "n",
  "<f5><f5>",
  function() require("fzf.grep.workspace")():start() end
)
create_keymap_lua(
  "v",
  "<f5><f4>",
  function()
    require("fzf.grep.file")({
      initial_query = utils.get_visual_selection(),
    }):start()
  end
)
create_keymap_lua(
  "v",
  "<f5><f5>",
  function()
    require("fzf.grep.workspace")({
      initial_query = utils.get_visual_selection(),
    }):start()
  end
)

create_keymap_lua(
  "n",
  "<f11><f6>",
  function() require("fzf.git.stash")():start() end
)
create_keymap_lua(
  "n",
  "<f11><f5>",
  function() require("fzf.git.commits")():start() end
)
create_keymap_lua(
  "n",
  "<f11><f4>",
  function()
    require("fzf.git.commits")({
      filepaths = vim.fn.expand("%"),
    }):start()
  end
)
create_keymap_lua(
  "n",
  "<f11><f3>",
  function() require("fzf.git.status")():start() end
)
create_keymap_lua(
  "n",
  "<f11><f2>",
  function() require("fzf.git.branch")():start() end
)
create_keymap_lua(
  "n",
  "<f11><f1>",
  function() require("fzf.git.submodules")():start() end
)
create_keymap_lua(
  "n",
  "<f11><f11>",
  function() require("fzf.git.reflog")():start() end
)

create_keymap_lua(
  "n",
  "li",
  function() require("fzf.lsp.definitions")():start() end
)
create_keymap_lua(
  "n",
  "lr",
  function() require("fzf.lsp.references")():start() end
)
create_keymap_lua(
  "n",
  "<f4><f4>",
  function() require("fzf.lsp.document_symbols")():start() end
)
create_keymap_lua(
  "n",
  "<f4><f5>",
  function() require("fzf.lsp.workspace_symbols")():start() end
)
create_keymap_lua(
  "n",
  "ld",
  function()
    require("fzf.diagnostics")({
      current_buffer_only = true,
      severity = {
        min = vim.diagnostic.severity.HINT,
      },
    }):start()
  end
)
create_keymap_lua(
  "n",
  "lD",
  function() require("fzf.diagnostics")():start() end
)

create_keymap_lua("n", "<space>u", function() require("fzf.undo")():start() end)
create_keymap_lua(
  "n",
  "<space>m",
  function() require("fzf.notification")():start() end
)
create_keymap_lua("n", "<space>j", function() require("fzf.jump")():start() end)

create_keymap_lua(
  "n",
  "<f9><f1>",
  function() require("fzf.docker.images")():start() end
)
create_keymap_lua(
  "n",
  "<f9><f2>",
  function() require("fzf.docker.containers")():start() end
)

-- LSP
create_keymap_vim("n", "lu", "<cmd>lua vim.lsp.buf.hover()<CR>")
create_keymap_vim("n", "lj", "<cmd>lua vim.diagnostic.open_float()<CR>")
create_keymap_vim("n", "lI", "<cmd>lua vim.lsp.buf.definition()<CR>")
create_keymap_vim("i", "<C-p>", "<cmd>lua vim.lsp.buf.signature_help()<CR>")
create_keymap_vim("n", "le", "<cmd>lua vim.lsp.buf.rename()<CR>")
create_keymap_vim("n", "lR", "<cmd>LspRestart<CR>")
create_keymap_vim("n", "<space>l", "<cmd>LspInfo<CR>")

local conform_over_lsp_format = true

if conform_over_lsp_format then
  create_keymap_lua("n", "ll", function()
    local success = conform.format()
    if success then
      return vim.info("Formatted with", conform.list_formatters()[1].name)
    else
      vim.lsp.buf.format()
      vim.info("Formatted with LSP formatter")
    end
  end)
else
  create_keymap_lua("n", "ll", function()
    vim.lsp.buf.format()
    vim.info("Formatted")
  end)
end

local lsp_pick_formatter = function()
  local clients = vim.lsp.get_active_clients({
    bufnr = 0, -- current buffer
  })

  local formatters = utils.filter(
    clients,
    function(i, e) return e.server_capabilities.documentFormattingProvider end
  )

  vim.ui.select(formatters, {
    prompt = "Select format providers:",
    format_item = function(formatter) return formatter.name end,
  }, function(formatter)
    vim.lsp.buf.format({
      filter = function(client) return client.name == formatter.name end,
    })
  end)
end

local conform_pick_formatter = function()
  local formatters = conform.list_formatters()
  formatters = utils.filter(
    formatters,
    function(_, formatter) return formatter.available end
  )
  vim.ui.select(formatters, {
    prompt = "Select formatter:",
    format_item = function(formatter) return formatter.name end,
  }, function(formatter) conform.format({ formatters = formatter.name }) end)
end

if conform_over_lsp_format then
  create_keymap_lua("n", "lL", conform_pick_formatter)
else
  create_keymap_lua("n", "lL", lsp_pick_formatter)
end

-- Comment
create_keymap_vim("n", "<C-/>", "<Plug>(comment_toggle_linewise_current)")
create_keymap_vim("v", "<C-/>", "<Plug>(comment_toggle_linewise_visual)gv") -- Re-select the last block
local comment_api = require("Comment.api")
if not vim.tbl_isempty(comment_api) then
  create_keymap_lua("i", "<C-/>", comment_api.toggle.linewise.current)
end

-- GitSigns
create_keymap_vim("n", "su", "<cmd>Gitsigns preview_hunk_inline<CR>")
create_keymap_lua("n", "si", function()
  local buffers = vim.t.diff_buffers ---@diagnostic disable-line: undefined-field
  if not buffers then
    vim.cmd([[Gitsigns prev_hunk]])
  else
    vim.cmd("normal! [c") -- Goto previous diff
  end
end)
create_keymap_lua("n", "sk", function()
  local buffers = vim.t.diff_buffers ---@diagnostic disable-line: undefined-field
  if not buffers then
    vim.cmd([[Gitsigns next_hunk]])
  else
    vim.cmd("normal! ]c") -- Goto next diff
  end
end)
create_keymap_vim("n", "sb", "<cmd>Gitsigns blame_line<CR>")
if false then
  create_keymap_vim("n", "sj", "<cmd>Gitsigns stage_hunk<CR>")
  create_keymap_vim("n", "sl", "<cmd>Gitsigns undo_stage_hunk<CR>")
end
create_keymap_vim("n", "s;", "<cmd>Gitsigns reset_hunk<CR>")

-- :qa, :q!, :wq
create_keymap_vim("n", "<space>q", ":q<cr>")
create_keymap_vim("n", "<space>w", ":w<cr>")
create_keymap_vim("n", "<space><BS>", ":q!<cr>")
create_keymap_vim("n", "<space>s", ":w!<cr>")
create_keymap_vim("n", "<space>a", ":qa<cr>")
create_keymap_vim("n", "<space>e", ":e<cr>")
create_keymap_vim("n", "<space><delete>", ":qa!<cr>")

-- Command line window
create_keymap_vim("n", "<space>;", "q:")

-- Session restore
create_keymap_lua("n", "<Space>r", function()
  require("persist").load_session()
  vim.info("Reloaded session")
end)

-- Colorizer
create_keymap_lua("n", "<leader>c", function()
  vim.cmd([[ColorizerToggle]])
  vim.info("Colorizer toggled")
end)
create_keymap_lua("n", "<leader>C", function()
  vim.cmd([[ColorizerReloadAllBuffers]])
  vim.info("Colorizer reloaded")
end)

-- Nvim Cmp
create_keymap_lua("i", "<M-r>", function()
  local cmp = require("cmp")

  if cmp.visible() then cmp.confirm({ select = true }) end
end)

-- Copilot
if not vim.g.vi_mode then
  create_keymap_lua("n", "<leader>a", "<cmd>Copilot enable<CR>")
  create_keymap_lua("i", "<M-a>", require("copilot.suggestion").accept)
  create_keymap_lua("i", "<M-w>", require("copilot.suggestion").accept_line)
  create_keymap_lua("i", "<M-d>", require("copilot.suggestion").next)
  create_keymap_lua("i", "<M-e>", require("copilot.suggestion").prev)
  create_keymap_lua("i", "<M-q>", require("copilot.panel").open)
  create_keymap_lua("n", "<M-e>", require("copilot.panel").jump_prev)
  create_keymap_lua("n", "<M-d>", require("copilot.panel").jump_next)
  create_keymap_lua("n", "<M-a>", require("copilot.panel").accept)
end

-- File managers
create_keymap_lua("n", "<f2><f2>", require("lf").lf)
create_keymap_lua("n", "<f2><f3>", function()
  require("lf").lf({
    path = vim.fn.expand("%:p"), -- Relative to ~ doesn't work
  })
end)

-- Copy path
create_keymap_lua("n", "<leader>g", function()
  local path = vim.fn.expand("%:~")
  vim.fn.setreg("+", path)
  vim.info("Copied", path)
end)
create_command_vim("CopyRelativePath", function()
  local path = vim.fn.expand("%:~")
  vim.fn.setreg("+", path)
  vim.info("Copied", path)
end)

-- Misc
create_command_vim(
  "LogCurrentBuf",
  function() vim.info(vim.api.nvim_get_current_buf()) end
)

return M
