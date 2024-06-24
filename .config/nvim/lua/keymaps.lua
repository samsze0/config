local lang_utils = require("utils.lang")
local tbl_utils = require("utils.table")
local keymap_utils = require("utils.keymap")
local command_utils = require("utils.command")
local editor_utils = require("utils.editor")

local safe_require = lang_utils.safe_require
local nullish = lang_utils.nullish

local jumplist = require("jumplist")
local lf = require("lf")
local persist = require("persist")
local YaziBasicInstance = require("yazi.instance").BasicInstance

---@module 'conform'
local conform = safe_require("conform")

---@module 'copilot.suggestion'
local copilot_suggestion = safe_require("copilot.suggestion")

---@module 'copilot.panel'
local copilot_panel = safe_require("copilot.panel")

---@module 'copilot'
local copilot = safe_require("copilot")

---@module 'cmp'
local cmp = safe_require("cmp")

---@module 'fzf-lua'
local fzf_lua = safe_require("fzf-lua")

---@param opts? {  }
local setup = function(opts)
  -- Pageup/down
  keymap_utils.create("n", "<PageUp>", "<C-u><C-u>")
  keymap_utils.create("n", "<PageDown>", "<C-d><C-d>")
  keymap_utils.create("v", "<PageUp>", "<C-u><C-u>")
  keymap_utils.create("v", "<PageDown>", "<C-d><C-d>")
  keymap_utils.create("i", "<PageUp>", "<C-o><C-u><C-o><C-u>") -- Execute <C-u> twice in normal mode
  keymap_utils.create("i", "<PageDown>", "<C-o><C-d><C-o><C-d>")

  -- Find and replace (local)
  keymap_utils.create("n", "rw", "*N:%s///g<left><left>") -- Select next occurrence of word under cursor then go back to current instance
  keymap_utils.create("n", "rr", ":%s//g<left><left>")
  keymap_utils.create("v", "rr", ":s//g<left><left>")
  keymap_utils.create("v", "r.", ":&gc<CR>") -- Reset flags & add flags
  keymap_utils.create("v", "ry", [["ry]]) -- Yank it into register "r" for later use with "rp"
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
  keymap_utils.create("n", "rp", rp_rhs(true), { expr = true })
  keymap_utils.create("v", "rp", rp_rhs(false), { expr = true })
  keymap_utils.create("v", "ra", [["ry:%s/<C-r>r//gc<left><left><left>]]) -- Paste selection into register "y" and paste it into command line with <C-r>
  keymap_utils.create("v", "ri", [["rygv*N:s/<C-r>r//g<left><left>]]) -- "ra" but backward direction only. Because ":s///c" doesn't support backward direction, rely on user pressing "N" and "r."
  keymap_utils.create("v", "rk", [["ry:.,$s/<C-r>r//gc<left><left><left>]]) -- "ra" but forward direction only

  -- Diff
  keymap_utils.create("n", "sj", function()
    local diff_buffers = vim.t.diff_buffers ---@diagnostic disable-line: undefined-field
    if not diff_buffers then
      vim.cmd([[Gitsigns stage_hunk]])
      return
    end

    lang_utils.switch(vim.api.nvim_get_current_buf(), {
      [diff_buffers[2]] = function()
        vim.cmd(([[diffget %s]]):format(diff_buffers[1]))
      end,
      [diff_buffers[3]] = function()
        vim.cmd(([[diffput %s]]):format(diff_buffers[2]))
      end,
    })
  end)
  keymap_utils.create("n", "sl", function()
    local diff_buffers = vim.t.diff_buffers ---@diagnostic disable-line: undefined-field
    if not diff_buffers then
      vim.cmd([[Gitsigns undo_stage_hunk]])
      return
    end

    lang_utils.switch(vim.api.nvim_get_current_buf(), {
      [diff_buffers[2]] = function()
        vim.cmd(([[diffget %s]]):format(diff_buffers[3]))
      end,
      [diff_buffers[1]] = function()
        vim.cmd(([[diffput %s]]):format(diff_buffers[2]))
      end,
    })
  end)

  -- Move by word
  keymap_utils.create("n", "<C-Left>", "b")
  keymap_utils.create("n", "<C-S-Left>", "B")
  keymap_utils.create("n", "<C-Right>", "w")
  keymap_utils.create("n", "<C-S-Right>", "W")

  -- Delete word
  keymap_utils.create("i", "<C-BS>", "<C-W>")

  -- Move/swap line/selection up/down
  local auto_indent = false
  keymap_utils.create(
    "n",
    "<C-up>",
    "<cmd>m .-2<CR>" .. (auto_indent and "==" or "")
  )
  keymap_utils.create(
    "n",
    "<C-down>",
    "<cmd>m .+1<CR>" .. (auto_indent and "==" or "")
  )
  keymap_utils.create(
    "v",
    "<C-up>",
    ":m .-2<CR>gv" .. (auto_indent and "=gv" or "")
  )
  keymap_utils.create(
    "v",
    "<C-down>",
    ":m '>+1<CR>gv" .. (auto_indent and "=gv" or "")
  )

  -- Delete line
  keymap_utils.create("n", "<M-y>", "dd", { noremap = false })
  keymap_utils.create("i", "<M-y>", "<C-o><M-y>", { noremap = false })
  keymap_utils.create("v", "<M-y>", ":d<CR>")

  -- Duplicate line/selection
  keymap_utils.create("n", "<M-g>", "<cmd>t .<CR>")
  keymap_utils.create("i", "<M-g>", "<C-o><M-g>", { noremap = false })
  keymap_utils.create("v", "<M-g>", ":t '><CR>")

  -- Matching pair
  keymap_utils.create("n", "m", "%")
  keymap_utils.create("v", "m", "%")

  -- Macro
  local macro_keymaps = false
  if macro_keymaps then
    keymap_utils.create("n", ",", "@") -- replay macro x
    keymap_utils.create("n", "<", "Q") -- replay last macro
  end

  -- Clear search highlights
  keymap_utils.create("n", "<Space>/", "<cmd>noh<CR>")

  -- Redo
  keymap_utils.create("n", "U", "<C-R>")

  -- New line
  keymap_utils.create("n", "o", "o<Esc>")
  keymap_utils.create("n", "O", "O<Esc>")

  -- Fold
  keymap_utils.create("n", "zl", "zo")
  keymap_utils.create("n", "zj", "zc")
  keymap_utils.create("n", "zp", "za")

  -- Insert/append swap
  keymap_utils.create("n", "i", "a")
  keymap_utils.create("n", "a", "i")
  keymap_utils.create("n", "I", "A")
  keymap_utils.create("n", "A", "I")
  keymap_utils.create("v", "I", "A")
  keymap_utils.create("v", "A", "I")

  -- Home
  keymap_utils.create("n", "<Home>", "^")
  keymap_utils.create("v", "<Home>", "^")
  keymap_utils.create("i", "<Home>", "<C-o>^") -- Execute ^ in normal mode

  -- Indent
  keymap_utils.create("n", "<Tab>", ">>")
  keymap_utils.create("n", "<S-Tab>", "<<")
  keymap_utils.create("v", "<Tab>", ">gv") -- keep selection after
  keymap_utils.create("v", "<S-Tab>", "<gv")

  -- Yank
  keymap_utils.create("v", "y", "ygv<Esc>") -- Stay at cursor after yank

  -- Paste
  keymap_utils.create("v", "p", '"pdP') -- Don't keep the overwritten text in register "+". Instead, keep it in "p"

  -- Fold
  keymap_utils.create("n", "z.", "zo")
  keymap_utils.create("n", "z,", "zc")
  keymap_utils.create("n", "z>", "zr")
  keymap_utils.create("n", "z<", "zm")

  -- Screen movement
  keymap_utils.create("n", "<S-Up>", "5<C-Y>")
  keymap_utils.create("v", "<S-Up>", "5<C-Y>")
  keymap_utils.create("i", "<S-Up>", "<C-o>5<C-Y>")
  keymap_utils.create("n", "<S-Down>", "5<C-E>")
  keymap_utils.create("v", "<S-Down>", "5<C-E>")
  keymap_utils.create("i", "<S-Down>", "<C-o>5<C-E>")
  keymap_utils.create("n", "<S-Left>", "2<ScrollWheelLeft>")
  keymap_utils.create("v", "<S-Left>", "2<ScrollWheelLeft>")
  keymap_utils.create("i", "<S-Left>", "<C-o>2<ScrollWheelLeft>")
  keymap_utils.create("n", "<S-Right>", "2<ScrollWheelRight>")
  keymap_utils.create("v", "<S-Right>", "2<ScrollWheelRight>")
  keymap_utils.create("i", "<S-Right>", "<C-o>2<ScrollWheelRight>")

  -- Window (pane)
  keymap_utils.create("n", "wi", "<cmd>wincmd k<CR>")
  keymap_utils.create("n", "wk", "<cmd>wincmd j<CR>")
  keymap_utils.create("n", "wj", "<cmd>wincmd h<CR>")
  keymap_utils.create("n", "wl", "<cmd>wincmd l<CR>")
  keymap_utils.create("n", "<C-e>", "<cmd>wincmd k<CR>")
  keymap_utils.create("n", "<C-d>", "<cmd>wincmd j<CR>")
  keymap_utils.create("n", "<C-s>", "<cmd>wincmd h<CR>")
  keymap_utils.create("n", "<C-f>", "<cmd>wincmd l<CR>")

  -- TODO: more intuitive control with lua
  keymap_utils.create("n", "<C-S-->", "10<C-w>-") -- Decrease height
  keymap_utils.create("n", "<C-S-=>", "10<C-w>+") -- Increase height
  keymap_utils.create("n", "<C-S-.>", "20<C-w>>") -- Increase width
  keymap_utils.create("n", "<C-S-,>", "20<C-w><") -- Decrease width

  keymap_utils.create("n", "ww", "<cmd>clo<CR>")

  keymap_utils.create("n", "wd", "<cmd>split<CR>")
  keymap_utils.create("n", "wf", "<cmd>vsplit<CR>")
  keymap_utils.create("n", "we", "<cmd>split<CR>")
  keymap_utils.create("n", "ws", "<cmd>vsplit<CR>")

  keymap_utils.create("n", "wt", "<cmd>wincmd T<CR>") -- Move to new tab

  -- TODO: remove
  keymap_utils.create("n", "wz", "<C-W>_<C-W>|") -- Maximise both horizontally and vertically
  keymap_utils.create("n", "wx", "<C-W>=")

  -- Tab
  keymap_utils.create("n", "tj", "<cmd>tabp<CR>")
  keymap_utils.create("n", "tl", "<cmd>tabn<CR>")
  keymap_utils.create("n", "tt", "<cmd>tabnew<CR>")
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
  keymap_utils.create("n", "tw", close_tab)
  keymap_utils.create("n", "tq", "<cmd>tabonly<CR>")
  keymap_utils.create("n", "<C-j>", "<cmd>tabp<CR>")
  keymap_utils.create("n", "<C-l>", "<cmd>tabn<CR>")

  keymap_utils.create("n", "tu", "<cmd>tabm -1<CR>")
  keymap_utils.create("n", "to", "<cmd>tabm +1<CR>")
  keymap_utils.create("n", "<C-S-j>", "<cmd>tabm -1<CR>")
  keymap_utils.create("n", "<C-S-l>", "<cmd>tabm +1<CR>")

  -- Delete & cut
  keymap_utils.create("n", "d", '"dd') -- Put in d register, in case if needed
  keymap_utils.create("v", "d", '"dd')
  keymap_utils.create("n", "x", "d")
  keymap_utils.create("v", "x", "d")
  keymap_utils.create("n", "xx", "dd")
  keymap_utils.create("n", "X", "D")

  -- Change (add to register 'd')
  keymap_utils.create("n", "c", '"dc')
  keymap_utils.create("n", "C", '"dC')
  keymap_utils.create("v", "c", '"dc')
  keymap_utils.create("v", "C", '"dC')

  -- Jump (jumplist)
  keymap_utils.create("n", "<C-u>", jumplist.jump_back)
  keymap_utils.create("n", "<C-o>", jumplist.jump_forward)

  -- Fzf/FzfLua

  keymap_utils.create("n", "<f1>", nullish(fzf_lua).builtin)

  keymap_utils.create(
    "n",
    "<f3>",
    function() require("fzf.files")():start() end
  )

  keymap_utils.create(
    "n",
    "<f4><f2>",
    function() require("fzf.buffers")():start() end
  )
  keymap_utils.create(
    "n",
    "<f4><f1>",
    function() require("fzf.tabs")():start() end
  )

  keymap_utils.create(
    "n",
    "<f5><f3>",
    function() require("fzf.grep.file")():start() end
  )
  keymap_utils.create(
    "n",
    "<f5><f4>",
    function() require("fzf.grep.workspace")():start() end
  )
  keymap_utils.create(
    "v",
    "<f5><f3>",
    function()
      require("fzf.grep.file")({
        initial_query = table.concat(editor_utils.get_visual_selection(), "\n"),
      }):start()
    end
  )
  keymap_utils.create(
    "v",
    "<f5><f4>",
    function()
      require("fzf.grep.workspace")({
        initial_query = table.concat(editor_utils.get_visual_selection(), "\n"),
      }):start()
    end
  )

  keymap_utils.create(
    "n",
    "<f11><f6>",
    function() require("fzf.git.stash")():start() end
  )
  keymap_utils.create(
    "n",
    "<f11><f5>",
    function() require("fzf.git.commits")():start() end
  )
  keymap_utils.create(
    "n",
    "<f11><f4>",
    function()
      require("fzf.git.commits")({
        filepaths = vim.fn.expand("%"),
      }):start()
    end
  )
  keymap_utils.create(
    "n",
    "<f11><f3>",
    function() require("fzf.git.status")():start() end
  )
  keymap_utils.create(
    "n",
    "<f11><f2>",
    function() require("fzf.git.branch")():start() end
  )
  keymap_utils.create(
    "n",
    "<f11><f1>",
    function() require("fzf.git.submodules")():start() end
  )
  keymap_utils.create(
    "n",
    "<f11><f11>",
    function() require("fzf.git.reflog")():start() end
  )

  keymap_utils.create(
    "n",
    "li",
    function() require("fzf.lsp.definitions")():start() end
  )
  keymap_utils.create(
    "n",
    "lr",
    function() require("fzf.lsp.references")():start() end
  )
  keymap_utils.create(
    "n",
    "ls",
    function() require("fzf.lsp.document_symbols")():start() end
  )
  keymap_utils.create(
    "n",
    "lS",
    function() require("fzf.lsp.workspace_symbols")():start() end
  )
  keymap_utils.create(
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
  keymap_utils.create(
    "n",
    "lD",
    function() require("fzf.diagnostics")():start() end
  )

  keymap_utils.create(
    "n",
    "<space>u",
    function() require("fzf.undo")():start() end
  )
  keymap_utils.create(
    "n",
    "<space>m",
    function() require("fzf.notification")():start() end
  )
  keymap_utils.create(
    "n",
    "<space>j",
    function() require("fzf.jump")():start() end
  )

  keymap_utils.create(
    "n",
    "<f9><f1>",
    function() require("fzf.docker.images")():start() end
  )
  keymap_utils.create(
    "n",
    "<f9><f2>",
    function() require("fzf.docker.containers")():start() end
  )

  -- LSP
  keymap_utils.create("n", "lu", function() vim.lsp.buf.hover() end)
  keymap_utils.create("n", "lj", function() vim.diagnostic.open_float() end)
  keymap_utils.create("n", "lI", function() vim.lsp.buf.definition() end)
  keymap_utils.create("i", "<C-p>", function() vim.lsp.buf.signature_help() end)
  keymap_utils.create("n", "le", function() vim.lsp.buf.rename() end)
  keymap_utils.create("n", "lR", function()
    vim.info("Restarting LSP")
    vim.cmd("LspRestart")
  end)
  keymap_utils.create("n", "<space>l", function() vim.cmd("LspInfo") end)

  keymap_utils.create("n", "ll", function()
    if not conform then return vim.lsp.buf.format() end

    local success = conform.format()
    if success then
      return vim.info("Formatted with", conform.list_formatters()[1].name)
    else
      vim.lsp.buf.format()
      vim.info("Conform failed. Formatted with 'vim.lsp.buf.format()'")
    end
  end)

  local lsp_pick_formatter = function()
    ---@type vim.lsp.get_clients.Filter
    local filter = {
      bufnr = 0,
    }
    local clients = vim.lsp.get_clients(filter)

    local formatters = tbl_utils.filter(
      clients,
      function(i, e) return e.server_capabilities.documentFormattingProvider end
    )

    vim.ui.select(formatters, {
      prompt = "[LSP] Select formatter:",
      format_item = function(formatter) return formatter.name end,
    }, function(formatter)
      vim.lsp.buf.format({
        filter = function(client) return client.name == formatter.name end,
      })
    end)
  end

  local conform_pick_formatter = function()
    local formatters = conform.list_formatters()
    formatters = tbl_utils.filter(
      formatters,
      function(_, formatter) return formatter.available end
    )
    vim.ui.select(formatters, {
      prompt = "[Conform] Select formatter:",
      format_item = function(formatter) return formatter.name end,
    }, function(formatter) conform.format({ formatters = formatter.name }) end)
  end

  keymap_utils.create("n", "lL", function()
    if conform then
      conform_pick_formatter()
    else
      lsp_pick_formatter()
    end
  end)

  -- Comment
  keymap_utils.create("n", "<C-/>", "<Plug>(comment_toggle_linewise_current)")
  keymap_utils.create("v", "<C-/>", "<Plug>(comment_toggle_linewise_visual)gv") -- Re-select the last block
  local comment_api = require("Comment.api")
  if not vim.tbl_isempty(comment_api) then
    keymap_utils.create("i", "<C-/>", comment_api.toggle.linewise.current)
  end

  -- GitSigns
  keymap_utils.create("n", "su", "<cmd>Gitsigns preview_hunk_inline<CR>")
  keymap_utils.create("n", "si", function()
    local buffers = vim.t.diff_buffers ---@diagnostic disable-line: undefined-field
    if not buffers then
      vim.cmd([[Gitsigns prev_hunk]])
    else
      vim.cmd("normal! [c") -- Goto previous diff
    end
  end)
  keymap_utils.create("n", "sk", function()
    local buffers = vim.t.diff_buffers ---@diagnostic disable-line: undefined-field
    if not buffers then
      vim.cmd([[Gitsigns next_hunk]])
    else
      vim.cmd("normal! ]c") -- Goto next diff
    end
  end)
  keymap_utils.create("n", "sb", "<cmd>Gitsigns blame_line<CR>")
  keymap_utils.create("n", "s;", "<cmd>Gitsigns reset_hunk<CR>")

  -- :qa, :q!, :wq
  keymap_utils.create("n", "<space>q", ":q<cr>")
  keymap_utils.create("n", "<space>w", ":w<cr>")
  keymap_utils.create("n", "<space><BS>", ":q!<cr>")
  keymap_utils.create("n", "<space>s", ":w!<cr>")
  keymap_utils.create("n", "<space>a", ":qa<cr>")
  keymap_utils.create("n", "<space>e", ":e<cr>")
  keymap_utils.create("n", "<space><delete>", ":qa!<cr>")

  -- Command line window
  keymap_utils.create("n", "<space>;", "q:")

  -- Session restore
  keymap_utils.create("n", "<Space>r", function()
    persist.load_session()
    vim.info("Reloaded session")
  end)

  -- Colorizer
  keymap_utils.create("n", "<leader>c", function()
    vim.cmd([[ColorizerToggle]])
    vim.info("Colorizer toggled")
  end)
  keymap_utils.create("n", "<leader>C", function()
    vim.cmd([[ColorizerReloadAllBuffers]])
    vim.info("Colorizer reloaded")
  end)

  -- Nvim Cmp
  keymap_utils.create("i", "<M-r>", function()
    if not cmp then return end

    if cmp.visible() then cmp.confirm({ select = true }) end
  end)

  -- Copilot
  if not vim.g.vi_mode then
    keymap_utils.create("n", "<leader>a", function()
      if copilot then vim.cmd("Copilot enable") end
    end)
    keymap_utils.create("i", "<M-a>", nullish(copilot_suggestion).accept)
    keymap_utils.create("i", "<M-w>", nullish(copilot_suggestion).accept_line)
    keymap_utils.create("i", "<M-d>", nullish(copilot_suggestion).next)
    keymap_utils.create("i", "<M-e>", nullish(copilot_suggestion).prev)
    keymap_utils.create("i", "<M-q>", nullish(copilot_panel).open)
    keymap_utils.create("n", "<M-e>", nullish(copilot_panel).jump_prev)
    keymap_utils.create("n", "<M-d>", nullish(copilot_panel).jump_next)
    keymap_utils.create("n", "<M-a>", nullish(copilot_panel).accept)
  end

  -- File managers
  ---@type YaziBasicInstance | nil
  local yazi = nil
  keymap_utils.create("n", "<f2>", function()
    if not yazi then
      yazi = YaziBasicInstance.new()
      yazi.layout.main_popup:map("<f2>", "Hide", function() yazi:hide() end)
      yazi.layout.main_popup:map("<f3>", "Reveal current file", function()
        local path = yazi:prev_filepath()
        yazi:reveal(path)
      end)
      yazi:on_quit(function() yazi:hide() end)
      yazi:on_exited(function() yazi = nil end)
      yazi:start()
    else
      yazi:show_and_focus()
    end
  end, {})

  -- Copy path
  keymap_utils.create("n", "<leader>g", function()
    local path = vim.fn.expand("%:~")
    vim.fn.setreg("+", path)
    vim.info("Copied", path)
  end)
  command_utils.create("CopyRelativePath", function()
    local path = vim.fn.expand("%:~")
    vim.fn.setreg("+", path)
    vim.info("Copied", path)
  end)

  -- Misc
  command_utils.create(
    "LogCurrentBuf",
    function() vim.info(vim.api.nvim_get_current_buf()) end
  )
end

return {
  setup = setup,
}
