local version = vim.version()
if version.major ~= 0 or version.minor ~= 10 then
  error("Neovim version 0.10 is required")
end

vim.cmd([[set clipboard+=unnamedplus]])

vim.opt.number = true
vim.opt.cursorline = false
vim.opt.signcolumn = "auto"
vim.opt.signcolumn = "yes:1"
vim.opt.wrap = true

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.mousescroll = "ver:1" -- Multiplier

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.smarttab = true
vim.opt.showtabline = 0

vim.cmd([[filetype on]])
vim.cmd([[filetype plugin on]])

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

---@type LazySpec
local utils_nvim_lazy_spec = {
  "samsze0/utils.nvim",
  priority = 100,
  dir = os.getenv("NVIM_UTILS_NVIM_PATH"), ---@diagnostic disable-line: assign-type-mismatch
  config = function()
    -- Load theme once before loading other plugins (to prevent theme flickering)
    require("utils").setup({})
    require("theme").setup({})
    require("keymaps").setup({})
  end,
}

require("lazy").setup({
  {
    "ibhagwan/fzf-lua",
    config = function() require("config.fzflua").setup() end,
    commit = "d368f76b37448d31918c81f020b0c725781c8354",
  },
  {
    "zbirenbaum/copilot.lua",
    enabled = not vim.g.vi_mode,
    config = function() require("config.copilotlua") end,
    commit = "f7612f5af4a7d7615babf43ab1e67a2d790c13a6",
  },
  {
    "norcalli/nvim-colorizer.lua",
    config = function() require("config.colorizer") end,
    commit = "a065833f35a3a7cc3ef137ac88b5381da2ba302e",
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "b0o/schemastore.nvim",
    },
    config = function() require("config.lspconfig") end,
    tag = "v0.1.8",
  },
  {
    -- Setup neovim plugin/script dev env by configuring lua-language-server with lsp-config
    -- Also add type annotations to vim/neovim built-in functions and APIs
    "folke/neodev.nvim",
    tag = "v3.0.0",
  },
  {
    -- Git status in sign column, git hunk preview/navigation, and line blame
    "lewis6991/gitsigns.nvim",
    config = function() require("config.gitsigns") end,
    tag = "v0.8.1",
  },
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup({ ---@diagnostic disable-line: missing-fields
        mappings = false,
      })
    end,
    tag = "v0.8.0",
  },
  {
    -- Formatters interface that calculates minimal diff
    "stevearc/conform.nvim",
    config = function() require("config.conform") end,
    tag = "v5.8.0",
  },
  {
    -- Linters interface that reports to vim.diagnostic
    "mfussenegger/nvim-lint",
    config = function() require("config.nvimlint") end,
    commit = "1a3a8d047bc01f1760ae4a0f5e80f111ea222e67",
  },
  {
    "hrsh7th/nvim-cmp",
    config = function() require("config.nvimcmp") end,
    dependencies = {
      -- TODO: fix versions for completion sources
      "hrsh7th/cmp-nvim-lsp", -- source for lsp
      "hrsh7th/cmp-path", -- source for filesystem paths
      "hrsh7th/cmp-cmdline", -- source for vim command line
      "hrsh7th/cmp-buffer", -- source for buffer words
      "petertriho/cmp-git", -- source for git
      "onsails/lspkind.nvim", -- add vscode-codicons to popup menu
      "L3MON4D3/LuaSnip", -- snippet
    },
    commit = "5260e5e8ecadaf13e6b82cf867a909f54e15fd07",
  },
  {
    "dstein64/nvim-scrollview",
    config = function()
      require("scrollview").setup({
        floating_windows = true,
      })
    end,
    commit = "9257c3f3ebf7608a8711caf44f878d87cd40395d",
  },
  {
    "nvim-treesitter/nvim-treesitter",
    config = function() require("treesitter") end,
    commit = "v0.9.1",
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    enabled = false,
  },
  {
    "mfussenegger/nvim-dap",
    config = function() end,
    enabled = false,
  },
  {
    "nvim-treesitter/playground",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    enabled = false,
  },
  { -- Required by fzf & lf
    "MunifTanjim/nui.nvim",
    tag = "0.3.0",
  },
  utils_nvim_lazy_spec,
  {
    "samsze0/jumplist.nvim",
    dir = os.getenv("NVIM_JUMPLIST_NVIM_PATH"),
    config = function() require("jumplist").setup({}) end,
  },
  {
    "samsze0/terminal-filetype.nvim",
    dir = os.getenv("NVIM_TERMINAL_FILETYPE_NVIM_PATH"),
    config = function() require("terminal-filetype").setup({}) end,
  },
  {
    "samsze0/notifier.nvim",
    dir = os.getenv("NVIM_NOTIFIER_NVIM_PATH"),
    config = function() require("notifier").setup({}) end,
    dependencies = {
      utils_nvim_lazy_spec,
    },
  },
  {
    "samsze0/fzf.nvim",
    dir = os.getenv("NVIM_FZF_NVIM_PATH"),
    config = function() require("fzf").setup({}) end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      utils_nvim_lazy_spec,
      "samsze0/jumplist.nvim",
      "samsze0/terminal-filetype.nvim",
      "samsze0/notifier.nvim",
    },
  },
  {
    "samsze0/websocket.nvim",
    dir = os.getenv("NVIM_WEBSOCKET_NVIM_PATH"),
    config = function() require("websocket").setup({}) end,
    dependencies = {
      utils_nvim_lazy_spec,
    },
  },
})

if vim.g.neovide then require("config.neovide") end
