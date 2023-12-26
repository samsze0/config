-- :help <option> to get info (or :h)

vim.cmd([[set clipboard+=unnamedplus]]) -- Use system clipboard

vim.opt.number = true
vim.opt.cursorline = false -- Highlight current line
vim.opt.signcolumn = "auto"
vim.opt.signcolumn = "yes:1" -- Maximum 1 signs, fixed
vim.opt.wrap = false

-- New window spawn on right or bottom
vim.opt.splitright = true
vim.opt.splitbelow = true
-- Make help window open as right split
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = vim.api.nvim_create_augroup("help_window", { clear = true }),
  pattern = { "*.txt" },
  callback = function()
    if vim.o.filetype == "help" then vim.cmd.wincmd("L") end
  end,
})

-- Mouse
vim.opt.mousescroll = "ver:10"

-- :help fo-table
vim.cmd([[set formatoptions-=o]]) -- Disable auto comment in normal mode
vim.cmd([[set formatoptions-=r]]) -- Disable auto comment in insert mode
vim.cmd([[set formatoptions-=c]]) -- Disable auto wrap comment

-- Format
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.smarttab = true
vim.opt.showtabline = 0
vim.cmd([[filetype on]])
vim.cmd([[filetype plugin off]])

-- Search
vim.opt.smartcase = true
vim.opt.ignorecase = true
vim.opt.hlsearch = true -- Highlight all matches. Pair with keymap :noh to clear highlights

vim.opt.fillchars:append({ diff = "╱" })

vim.opt.pumblend = 0 -- Transparency for popup-menu; 0 = opaque; 100 = transparent

-- Lazy.nvim bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local config = require("config")

require("theme").setup({}) -- Setup once because some plugins might read existing highlight groups values

require("lazy").setup({
  {
    "ibhagwan/fzf-lua",
    config = function() require("config.fzflua").setup() end,
  },
  {
    "github/copilot.vim",
    enabled = config.copilot_plugin == "vim" and not vim.g.vi_mode,
    config = function()
      local run_setup_on_startup = false

      if run_setup_on_startup then
        vim.api.nvim_create_autocmd("VimEnter", {
          callback = function() vim.cmd("Copilot setup") end,
        })
      end
    end,
  },
  {
    "zbirenbaum/copilot.lua",
    enabled = config.copilot_plugin == "lua" and not vim.g.vi_mode,
    config = function() require("config.copilotlua") end,
  },
  {
    -- Show colors for color values e.g. hex
    "norcalli/nvim-colorizer.lua",
    config = function() require("config.colorizer") end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function() require("config.lspconfig") end,
  },
  {
    -- Hop. Hijack search and f/t
    "folke/flash.nvim",
    config = function() require("config.flash") end,
  },
  {
    -- Configure lua-language-server for neovim config by modifying .luarc.json and lsp-config and add type annotations
    -- for builtin
    "folke/neodev.nvim",
    enabled = config.nvim_dev_plugin == "neodev",
  },
  {
    -- Git status in sign column and git hunk preview/navigation and line blame
    "lewis6991/gitsigns.nvim",
    config = function() require("config.gitsigns") end,
  },
  {
    -- Indentation markers
    "lukas-reineke/indent-blankline.nvim",
    enabled = config.indent_guide_plugin,
    config = function()
      require("ibl").setup({
        indent = { char = "▏" },
        scope = {
          highlight = require("theme").rainbow_hl_groups,
          show_start = false, -- underline on scope start
          show_end = false, -- underline on scope end
          include = {
            node_type = { ["*"] = { "*" } },
          },
          exclude = {
            language = {},
            node_type = {},
          },
        },
      })
    end,
  },
  {
    -- Brackets colorizer
    "HiPhish/rainbow-delimiters.nvim",
    enabled = config.bracket_colorizer_plugin,
    config = function()
      require("theme").setup({})
      vim.g.rainbow_delimiters =
        { highlight = require("theme").rainbow_hl_groups }
    end,
  },
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup({
        mappings = false,
      })
    end,
  },
  {
    -- Formatters interface that calculates minimal diff
    "stevearc/conform.nvim",
    config = function() require("config.conform") end,
  },
  {
    -- Linters interface that reports to vim.diagnostic, unlike ALE
    "mfussenegger/nvim-lint",
    config = function() require("config.nvimlint") end,
  },
  {
    -- Completion
    "hrsh7th/nvim-cmp",
    config = function() require("config.nvimcmp") end,
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", -- nvim-cmp source for built-in language server client
      "hrsh7th/cmp-path", -- nvim-cmp source for filesystem paths
      "hrsh7th/cmp-cmdline", -- nvim-cmp source for vim command line
      "hrsh7th/cmp-buffer", -- nvim-cmp source for buffer words
      "petertriho/cmp-git", -- nvim-cmp source for git (commits, issues, mentions, etc.)
      "onsails/lspkind.nvim", -- add vscode-codicons to completion entries (function, class, etc.)
      "L3MON4D3/LuaSnip", -- Snippet. For inserting text into editor
    },
  },
  {
    -- Scrollbar (+ show signs for git conflicts, diagnostics, search, etc.)
    "dstein64/nvim-scrollview",
    config = function()
      require("scrollview").setup({
        floating_windows = true,
      })
    end,
  },
  {
    "sindrets/diffview.nvim",
    enabled = config.diffview_plugin,
    config = function() require("config.diffview") end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    config = function() require("treesitter") end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    enabled = config.treesitter_textobjects_plugin == "default",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    config = function() require("config.treesitter-textobjects") end,
  },
  {
    "mfussenegger/nvim-dap",
    enabled = config.dap_plugins,
    config = function() end,
  },
  {
    "nvim-treesitter/playground",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
  },
  { -- Required by fzf & lf
    "MunifTanjim/nui.nvim",
  },
})

require("jumplist").setup()
require("keymaps").setup()
require("winbar").setup() -- i.e. breadcrumbs
require("commands")
require("theme").setup(config.theme_opts)
if config.tabline_plugin == "custom" then
  -- :h tabbline
  -- :h tabbar
  require("tabline").setup({})
  vim.opt.showtabline = 2 -- 2 = always ; 1 = at least 2 tabs ; 0 = never
end
if config.statusline_plugin == "custom" then
  -- :h statusline
  require("statusline").setup({})
  vim.opt.laststatus = 2 -- 3 = global; 2 = always ; 1 = at least 2 windows ; 0 = never
end
if config.notify_backend == "custom" then require("notify") end
require("lf")
if config.persist_plugin == "custom" then require("persist").setup() end
require("fzf").setup()

if vim.g.neovide then require("config.neovide") end
