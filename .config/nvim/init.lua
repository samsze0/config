vim.cmd[[set clipboard+=unnamedplus]]  -- Use system clipboard

vim.opt.number = true
-- vim.opt.cursorline = true
-- vim.opt.signcolumn = "auto"
vim.opt.wrap = false
vim.cmd[[set formatoptions-=o]]
vim.cmd[[set formatoptions-=r]]
vim.cmd[[set formatoptions-=c]]
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.autoindent = true
vim.opt.smarttab = true
vim.opt.showtabline=0

vim.opt.smartcase = true
vim.opt.ignorecase = true
vim.opt.hlsearch = false

vim.cmd[[set backupdir=~/.cache/nvim/backup]]
vim.cmd[[set directory=~/.cache/nvim/swap]]
vim.cmd[[set undodir=~/.cache/nvim/undo]]

vim.cmd[[filetype on]]
vim.cmd[[filetype plugin off]]

require('keymaps')

vim.opt.background = "dark"
vim.opt.termguicolors = true

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  use {
    'RRethy/nvim-base16',
    config = function()
      require("_nvimbase16")
    end
  }

  use {
    'nvim-lualine/lualine.nvim',
    config = function()
      require("_lualine")
    end
  }

  use {
    'ibhagwan/fzf-lua',
    branch = "main",
    config = function()
      require('_fzflua')
    end
  }

  use {  -- Show colors for color values e.g. hex
    'norcalli/nvim-colorizer.lua',
    config = function()
      require('_colorizer')
    end
  }

  -- use {
  --   'nvim-treesitter/nvim-treesitter',
  --   run = ':TSUpdate',
  --   config = function()
  --     require('_treesitter')
  --   end
  -- }
end)
