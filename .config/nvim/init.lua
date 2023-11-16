-- :help <option> to get info (or :h)

vim.cmd [[set clipboard+=unnamedplus]] -- Use system clipboard

vim.opt.number = true
vim.opt.cursorline = false -- Highlight current line
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
vim.opt.hlsearch = true -- Highlight all matches. Pair with keymap :noh to clear highlights

vim.cmd [[set backupdir=~/.cache/nvim/backup]]
vim.cmd [[set directory=~/.cache/nvim/swap]]
vim.cmd [[set undodir=~/.cache/nvim/undo]]

vim.cmd [[filetype on]]
vim.cmd [[filetype plugin off]]
-- vim.cmd[[filetype indent on]]

require('keymaps')
require('theme').setup()

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

require("lazy").setup({
  {
    'ibhagwan/fzf-lua',
    branch = "main",
    config = function()
      require('_fzflua')
    end
  },
  {
    'github/copilot.vim',
  },
  {
    'nvim-lualine/lualine.nvim',
    config = function()
      require("_lualine")
    end
  },
  {
    -- Show colors for color values e.g. hex
    'norcalli/nvim-colorizer.lua',
    config = function()
      require('_colorizer')
    end
  },
  {
    -- Term within neovim
    'voldikss/vim-floaterm',
    config = function()
      vim.g.floaterm_width = 0.9
      vim.g.floaterm_height = 0.9
    end
  },
  {
    -- Lf integration
    'ptzz/lf.vim',
    requires = {
      'voldikss/vim-floaterm'
    },
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'folke/neoconf.nvim',
      'hrsh7th/cmp-nvim-lsp'
    },
    config = function()
      require('_lspconfig')
    end
  },
  {
    -- Autoclosing brackets
    'windwp/nvim-autopairs',
    config = function()
      require('_autopairs')
    end
  },
  {
    -- Hop. Hijack search and f/t
    'folke/flash.nvim',
    config = function()
      require('_flash')
    end
  },
  {
    -- Configure lua-language-server for neovim config
    'folke/neodev.nvim',
    config = function()
      require("neodev").setup({})
    end
  },
  {
    -- Git status in sign column and git hunk preview/navigation and line blame
    'lewis6991/gitsigns.nvim',
    config = function()
      require('_gitsigns')
    end
  },
  {
    enabled = false,
    'nvim-tree/nvim-tree.lua',
    config = function()
      require('_nvimtree')
    end
  },
  {
    -- Indentation markers
    'lukas-reineke/indent-blankline.nvim',
    config = function()
      require("ibl").setup()
    end
  },
  {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup({
        mappings = false
      })
    end
  },
  {
    -- Project specific settings incl. LSP (w/ vscode interop)
    'folke/neoconf.nvim',
    config = function()
      require('_neoconf')
    end
  },
  {
    -- Highlight occurences of word current cursor
    'RRethy/vim-illuminate',
    config = function()
      require('illuminate').configure({})
    end
  },
  {
    -- Formatters interface that calculates minimal diff
    'stevearc/conform.nvim',
    config = function()
      require('_conform')
    end
  },
  {
    -- Linters interface that reports to vim.diagnostic, unlike ALE
    'mfussenegger/nvim-lint',
    config = function()
      require('_nvimlint')
    end
  },
  {
    -- Completion
    'hrsh7th/nvim-cmp',
    config = function()
      require('_nvimcmp')
    end,
    dependencies = {
      'hrsh7th/cmp-nvim-lsp', -- nvim-cmp source for built-in language server client
      'hrsh7th/cmp-path',     -- nvim-cmp source for filesystem paths
      'hrsh7th/cmp-cmdline',  -- nvim-cmp source for vim command line
      'hrsh7th/cmp-buffer',   -- nvim-cmp source for buffer words
      'petertriho/cmp-git',   -- nvim-cmp source for git (commits, issues, mentions, etc.)
      'onsails/lspkind.nvim', -- add vscode-codicons to completion entries (function, class, etc.)
      'L3MON4D3/LuaSnip',     -- Snippet. For inserting text into editor
    }
  },
  {
    -- Scrollbar (show signs for git conflicts, diagnostics, search, etc.)
    'dstein64/nvim-scrollview',
    config = function()
      require('scrollview').setup({})
    end
  }
})
