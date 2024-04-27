vim.cmd([[set clipboard+=unnamedplus]])

vim.opt.number = true
vim.opt.cursorline = false
vim.opt.signcolumn = "auto"
vim.opt.signcolumn = "yes:1"
vim.opt.wrap = true

vim.opt.splitright = true
vim.opt.splitbelow = true

-- Make help window open as right split instead of bottom split
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = vim.api.nvim_create_augroup(
    "help_window_open_as_right_split",
    { clear = true }
  ),
  pattern = { "*.txt" },
  callback = function()
    if vim.o.filetype == "help" then vim.cmd.wincmd("L") end
  end,
})

-- Markdown
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  group = vim.api.nvim_create_augroup("markdown_settings", { clear = true }),
  pattern = { "*.md" },
  callback = function(ctx) vim.opt.wrap = true end,
})

vim.opt.mousescroll = "ver:10" -- Multiplier

-- TODO: respect .editorconfig
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.smarttab = true
vim.opt.showtabline = 0
vim.cmd([[filetype on]])
vim.cmd([[filetype plugin off]])

vim.cmd([[set formatoptions-=o]]) -- Disable auto comment in normal mode
vim.cmd([[set formatoptions-=r]]) -- Disable auto comment in insert mode
vim.cmd([[set formatoptions-=c]]) -- Disable auto wrap comment

-- Search
vim.opt.smartcase = true
vim.opt.ignorecase = true
vim.opt.hlsearch = true -- Highlight all matches. Use :noh to clear highlights

vim.opt.conceallevel = 0

vim.opt.fillchars:append({ diff = "╱" })

vim.opt.pumblend = 0 -- Popup-menu transparency

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

-- Setup once in-advance because some plugins might read existing highlight groups values
require("theme").setup()

require("lazy").setup({
  {
    "ibhagwan/fzf-lua",
    config = function() require("config.fzflua").setup() end,
  },
  {
    "zbirenbaum/copilot.lua",
    enabled = not vim.g.vi_mode,
    config = function() require("config.copilotlua") end,
  },
  {
    "norcalli/nvim-colorizer.lua",
    config = function() require("config.colorizer") end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "b0o/schemastore.nvim",
    },
    config = function() require("config.lspconfig") end,
  },
  {
    -- Setup neovim plugin/script dev env by configuring lua-language-server with lsp-config
    -- Also add type annotations to vim/neovim built-in functions and APIs
    "folke/neodev.nvim",
  },
  {
    -- Git status in sign column, git hunk preview/navigation, and line blame
    "lewis6991/gitsigns.nvim",
    config = function() require("config.gitsigns") end,
  },
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup({ ---@diagnostic disable-line: missing-fields
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
    -- Linters interface that reports to vim.diagnostic
    "mfussenegger/nvim-lint",
    config = function() require("config.nvimlint") end,
  },
  {
    "hrsh7th/nvim-cmp",
    config = function() require("config.nvimcmp") end,
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", -- source for lsp
      "hrsh7th/cmp-path", -- source for filesystem paths
      "hrsh7th/cmp-cmdline", -- source for vim command line
      "hrsh7th/cmp-buffer", -- source for buffer words
      "petertriho/cmp-git", -- source for git
      "onsails/lspkind.nvim", -- add vscode-codicons to popup menu
      "L3MON4D3/LuaSnip", -- snippet
    },
  },
  {
    "dstein64/nvim-scrollview",
    config = function()
      require("scrollview").setup({
        floating_windows = true,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    config = function() require("treesitter") end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    enabled = false,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
  },
  {
    "mfussenegger/nvim-dap",
    enabled = false, -- TODO
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
  {
    "vhyrro/luarocks.nvim",
    priority = 1000,
    opts = {
      rocks = {},
    },
  },
})

require("noti")
require("jumplist").setup()
require("keymaps")
require("winbar").setup()
require("theme").setup()
require("statusline").setup()
require("tabline").setup()
require("persist").setup()
require("terminal-filetype").setup()

if vim.g.neovide then require("config.neovide") end
