-- :help <option> to get info (or :h)

vim.cmd[[set clipboard+=unnamedplus]]  -- Use system clipboard

vim.opt.number = true
vim.opt.cursorline = false  -- Highlight current line
vim.opt.signcolumn = "auto"
vim.opt.wrap = false

-- :help fo-table
-- vim.cmd[[set formatoptions-=o]]  -- Disable auto comment in normal mode
-- vim.cmd[[set formatoptions-=r]]  -- Disable auto comment in insert mode
-- vim.cmd[[set formatoptions-=c]]  -- Disable auto wrap comment

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.smarttab = true
vim.opt.showtabline = 0

vim.opt.smartcase = true
vim.opt.ignorecase = true
vim.opt.hlsearch = true  -- Highlight all matches. Pair with keymap :noh to clear highlights

vim.cmd[[set backupdir=~/.cache/nvim/backup]]
vim.cmd[[set directory=~/.cache/nvim/swap]]
vim.cmd[[set undodir=~/.cache/nvim/undo]]

vim.cmd[[filetype on]]
vim.cmd[[filetype plugin off]]
-- vim.cmd[[filetype indent on]]

require('keymaps')
require('theme').setup()

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  use {
    'ibhagwan/fzf-lua',
    branch = "main",
    config = function()
      require('_fzflua')
    end
  }

  use {
    'github/copilot.vim'
  }

  use {
    'nvim-lualine/lualine.nvim',
    config = function()
      require("_lualine")
    end
  }


  use {  -- Show colors for color values e.g. hex
    'norcalli/nvim-colorizer.lua',
    config = function()
      require('_colorizer')
    end
  }

  use {
    'voldikss/vim-floaterm',
    config = function()
      vim.g.floaterm_width = 0.9
      vim.g.floaterm_height = 0.9
    end
  }

  use {
    'ptzz/lf.vim',
    requires = {
      'voldikss/vim-floaterm'
    },
  }

  use {
    'neovim/nvim-lspconfig',
    config = function()
      require('_lspconfig')
    end
  }

  use {
  	'windwp/nvim-autopairs',
    config = function()
      require('_autopairs')
    end
  }

  use {  -- Hop
    'folke/flash.nvim',
    config = function()
      require('_flash')
    end
  }

  use {  -- Configure lua-language-server for neovim config
    'folke/neodev.nvim',
  }

  use {  -- Git status in sign column and git hunk preview/navigation and line blame
    'lewis6991/gitsigns.nvim',
    config = function()
      require('_gitsigns')
    end
  }
end)
