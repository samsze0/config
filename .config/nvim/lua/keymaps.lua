local M = {}

local config = require("config")
local utils = require("utils")
local jumplist = require("jumplist")
local safe_require = function(module)
  return utils.safe_require(module, {
    notify = false,
    log_level = vim.log.levels.ERROR,
  })
end

local vim_keymap = vim.api.nvim_set_keymap
local opts = { silent = false, noremap = true }
local opts_can_remap = { silent = false, noremap = false }
local opts_expr = { silent = false, expr = true, noremap = true }

local lua_keymap = function(mode, lhs, rhs, opts)
  if rhs ~= nil then vim.keymap.set(mode, lhs, rhs, opts) end
end

M.setup = function()
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
      return (
        (whole_file and ":%s" or ":s")
        .. [[//<C-r>r/gc<left><left><left>]]
        .. string.rep("<left>", utils.get_register_length("r"))
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
  vim_keymap(
    "v",
    "<C-up>",
    ":m .-2<CR>gv" .. (auto_indent and "=gv" or ""),
    opts
  )
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

  local maximize_plugin = config.maximize_plugin

  if maximize_plugin then
    lua_keymap("n", "wz", safe_require("maximize").toggle, {})
  else
    vim_keymap("n", "wz", "<C-W>_<C-W>|", opts) -- Maximise both horizontally and vertically
    vim_keymap("n", "wx", "<C-W>=", opts)
  end

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
  local fuzzy_finder_keymaps = {
    [{ mode = "n", lhs = "<f1>" }] = {
      fzflua = safe_require("fzf-lua").builtin,
      fzf = nil,
    },
    [{ mode = "n", lhs = "<f3><f3>" }] = {
      fzflua = safe_require("fzf-lua").git_files,
      fzf = function() require("fzf").files({ nvim_preview = true }) end,
    },
    [{ mode = "n", lhs = "<f3><f4>" }] = {
      fzflua = nil,
      fzf = function()
        require("fzf").git_submodules(
          function(submodule_path)
            require("fzf").files({
              nvim_preview = true,
              git_dir = submodule_path,
            })
          end
        )
      end,
    },
    [{ mode = "n", lhs = "<f3><f5>" }] = {
      fzflua = safe_require("fzf-lua").files,
      fzf = nil,
    },
    [{ mode = "n", lhs = "<f3><f2>" }] = {
      fzflua = safe_require("fzf-lua").buffers,
      fzf = require("fzf").buffers,
    },
    [{ mode = "n", lhs = "<f3><f1>" }] = {
      fzflua = safe_require("fzf-lua").tabs,
      fzf = require("fzf").tabs,
    },
    [{ mode = "n", lhs = "<f5><f4>" }] = {
      fzflua = safe_require("fzf-lua").blines,
      fzf = require("fzf").grep_file,
    },
    [{ mode = "n", lhs = "<f5><f5>" }] = {
      fzflua = safe_require("fzf-lua").live_grep,
      fzf = require("fzf").grep,
    },
    [{ mode = "v", lhs = "<f5><f4>" }] = {
      fzflua = nil,
      fzf = function()
        require("fzf").grep_file({
          initial_query = utils.get_visual_selection(),
        })
      end,
    },
    [{ mode = "v", lhs = "<f5><f5>" }] = {
      fzflua = nil,
      fzf = function()
        require("fzf").grep({
          initial_query = utils.get_visual_selection(),
        })
      end,
    },
    [{ mode = "n", lhs = "<f11><f5>" }] = {
      fzflua = safe_require("fzf-lua").git_commits,
      fzf = require("fzf").git_commits,
    },
    [{ mode = "n", lhs = "<f10><f5>" }] = {
      fzflua = nil,
      fzf = function()
        require("fzf").git_submodules(
          function(submodule_path)
            require("fzf").git_commits({
              git_dir = submodule_path,
            })
          end
        )
      end,
    },
    [{ mode = "n", lhs = "<f11><f4>" }] = {
      fzflua = safe_require("fzf-lua").git_bcommits,
      fzf = function()
        require("fzf").git_commits({ filepaths = vim.fn.expand("%:p") })
      end,
    },
    [{ mode = "n", lhs = "<f10><f4>" }] = {
      fzflua = nil,
      fzf = function()
        require("fzf").git_submodules(
          function(submodule_path)
            require("fzf").git_commits({
              git_dir = submodule_path,
              filepaths = vim.fn.expand("%"),
            })
          end
        )
      end,
    },
    [{ mode = "n", lhs = "<f11><f3>" }] = {
      fzflua = safe_require("fzf-lua").git_status,
      fzf = require("fzf").git_status,
    },
    [{ mode = "n", lhs = "<f10><f4>" }] = {
      fzflua = nil,
      fzf = function()
        require("fzf").git_submodules(
          function(submodule_path)
            require("fzf").git_status({
              git_dir = submodule_path,
            })
          end
        )
      end,
    },
    [{ mode = "n", lhs = "li" }] = {
      fzflua = safe_require("fzf-lua").lsp_definitions,
      fzf = require("fzf").lsp_definitions,
    },
    [{ mode = "n", lhs = "lr" }] = {
      fzflua = safe_require("fzf-lua").lsp_references,
      fzf = require("fzf").lsp_references,
    },
    [{ mode = "n", lhs = "<f4><f4>" }] = {
      fzflua = safe_require("fzf-lua").lsp_document_symbols,
      fzf = require("fzf").lsp_document_symbols,
    },
    [{ mode = "n", lhs = "<f4><f5>" }] = {
      fzflua = safe_require("fzf-lua").lsp_workspace_symbols,
      fzf = require("fzf").lsp_workspace_symbols,
    },
    [{ mode = "n", lhs = "ld" }] = {
      fzflua = safe_require("fzf-lua").lsp_document_diagnostics,
      fzf = function()
        require("fzf").diagnostics({
          current_buffer_only = true,
        })
      end,
    },
    [{ mode = "n", lhs = "lD" }] = {
      fzflua = safe_require("fzf-lua").lsp_workspace_diagnostics,
      fzf = require("fzf").diagnostics,
    },
    [{ mode = "n", lhs = "la" }] = {
      fzflua = safe_require("fzf-lua").lsp_code_actions,
      fzf = nil,
    },
    [{ mode = "n", lhs = "<space>u" }] = {
      fzflua = safe_require("config.fzflua-custom").undo_tree,
      fzf = require("fzf").undos,
    },
    [{ mode = "n", lhs = "<space>m" }] = {
      fzflua = safe_require("config.fzflua-custom").notifications,
      fzf = require("fzf").notifications,
    },
    [{ mode = "n", lhs = "<f11><f11>" }] = {
      fzflua = safe_require("config.fzflua-custom").git_reflog,
      fzf = nil,
    },
    [{ mode = "n", lhs = "<space>j" }] = {
      fzflua = safe_require("config.fzflua-custom").jumps,
      fzf = require("fzf").jumps,
    },
  }

  for k, v in pairs(fuzzy_finder_keymaps) do
    if v.fzf ~= nil then
      lua_keymap(k.mode, k.lhs, v.fzf, {})
    elseif v.fzflua ~= nil then
      lua_keymap(k.mode, k.lhs, v.fzflua, {})
    end
  end

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
    lua_keymap(
      "n",
      "ll",
      utils.run_and_notify(safe_require("conform").format, function(success)
        if success then
          return string.format(
            "Formatted with %s",
            safe_require("conform").list_formatters()[1].name
          ) -- TODO: look for first available formatter
        else
          return "No available formatters"
        end
      end),
      {}
    )
  else
    lua_keymap(
      "n",
      "ll",
      utils.run_and_notify(vim.lsp.buf.format, "Formatted"),
      {}
    )
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
    local formatters = safe_require("conform").list_formatters()
    formatters = utils.filter(
      formatters,
      function(formatter) return formatter.available end
    )
    vim.ui.select(
      formatters,
      {
        prompt = "Select formatter:",
        format_item = function(formatter) return formatter.name end,
      },
      function(formatter)
        safe_require("conform").format({ formatters = formatter.name })
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
  local comment_api = safe_require("Comment.api")
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
  if config.persist_plugin == "custom" then
    lua_keymap(
      "n",
      "<Space>r",
      utils.run_and_notify(require("persist").load_session, "Reloaded session"),
      {}
    )
  end

  -- Colorizer
  lua_keymap(
    "n",
    "<leader>c",
    utils.run_and_notify(
      function() vim.cmd([[ColorizerToggle]]) end,
      "Colorizer toggled"
    ),
    {}
  )
  lua_keymap(
    "n",
    "<leader>C",
    utils.run_and_notify(
      function() vim.cmd([[ColorizerReloadAllBuffers]]) end,
      "Colorizer reloaded"
    ),
    {}
  )

  -- Nvim Cmp
  lua_keymap("i", "<M-r>", function()
    local cmp = require("cmp")

    if cmp.visible() then cmp.confirm({ select = true }) end
  end, {})

  -- Copilot
  if config.copilot_plugin == "vim" then
    vim_keymap("n", "<leader>a", "<cmd>Copilot setup<CR>", opts)
  elseif config.copilot_plugin == "lua" then
    lua_keymap("n", "<leader>a", "<cmd>Copilot enable<CR>", {})
    lua_keymap("i", "<M-a>", safe_require("copilot.suggestion").accept, {})
    lua_keymap("i", "<M-w>", safe_require("copilot.suggestion").accept_line, {})
    lua_keymap("i", "<M-d>", safe_require("copilot.suggestion").next, {})
    lua_keymap("i", "<M-e>", safe_require("copilot.suggestion").prev, {})
    lua_keymap("i", "<M-q>", safe_require("copilot.panel").open, {})
    lua_keymap("n", "<M-e>", safe_require("copilot.panel").jump_prev, {})
    lua_keymap("n", "<M-d>", safe_require("copilot.panel").jump_next, {})
    lua_keymap("n", "<M-a>", safe_require("copilot.panel").accept, {})
  end

  -- Diffview
  if config.diffview_plugin then
    vim_keymap("n", "<f11><f1>", "<cmd>DiffviewOpen<cr>", opts)
    vim_keymap("n", "<f11><f2>", "<cmd>DiffviewFileHistory %<cr>", opts) -- See current file git history
    vim_keymap("v", "<f11><f2>", ":DiffviewFileHistory %<cr>", opts) -- See current selection git history
  end

  -- File managers
  lua_keymap("n", "<f2><f2>", require("lf").lf, {})
  lua_keymap(
    "n",
    "<f2><f3>",
    function() require("lf").lf({ path = vim.fn.expand("%:p:h") }) end,
    {}
  )
end

return M
