vim.g.colors_name = 'im-pinkneo'
-- Color {{{
  vim.opt.background = "dark"
  vim.opt.termguicolors = true
  require('colors/setup').setup(require('colors/' .. vim.g.colors_name))
-- }}}

-- Filetype {{{
  vim.cmd[[filetype on]]
  -- vim.cmd[[filetype indent on]]
  vim.cmd[[filetype plugin off]]
-- }}}

-- Clipboard {{{
  vim.cmd[[set clipboard+=unnamedplus]]
-- }}}

-- Mouse {{{
  vim.opt.mouse = "a"
-- }}}

--- Format, Line, Tab, Indent {{{
  vim.opt.number = true
  vim.opt.cursorline = true
  vim.opt.signcolumn = "auto"
  vim.opt.wrap = true
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
-- }}}

-- Search
-- {{{
  vim.opt.smartcase = true
  vim.opt.ignorecase = true
  vim.opt.hlsearch = false
-- }}}

-- Backup, undo, swap
-- {{{
  vim.cmd[[set backupdir=~/.cache/nvim/backup]]
  vim.cmd[[set directory=~/.cache/nvim/swap]]
  vim.cmd[[set undodir=~/.cache/nvim/undo]]
--- }}}

require('packer').startup(function()
  -- Packer {{{
    use {
      'wbthomason/packer.nvim',
      config = function()
        require('_packer')
      end
    }
  -- }}}

  -- Essentials {{{
    -- Cutlass (separate cut and delete)
    use {
      'gbprod/cutlass.nvim',
      config = function()
        require('_cutlass')
      end
    }

    -- Hop
    use {
      'phaazon/hop.nvim',
      config = function()
        require('_hop')
      end
    }

    -- Colorizer
    use {
      'norcalli/nvim-colorizer.lua',
      config = function()
        require('_colorizer')
      end
    }

    -- Autosave
    use {
      'Pocco81/AutoSave.nvim',
      config = function()
        require('_autosave')
      end
    }

    -- Indent-blankline
    use {
      'lukas-reineke/indent-blankline.nvim',
      config = function()
        require('_indentblankline')
      end
    }

    -- Kommentary
    use {
      'b3nj5m1n/kommentary',
      config = function()
        require('_kommentary')
      end
    }

    -- Mini (surround & indent text object)
    use {
      'echasnovski/mini.nvim',
      config = function()
        require('_mini')
      end
    }
  -- }}}

  -- Autocompletion {{{
    -- Luasnip
    use {
      'L3MON4D3/LuaSnip',
      config = function()
        require('_luasnip')
      end
    }

    -- Nvim-cmp
    use {
      'hrsh7th/nvim-cmp',
      requires = {
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-cmdline',
        'L3MON4D3/LuaSnip'
      },
      config = function()
        require('_nvimcmp')
      end
    }
  -- }}}

  -- Syntax {{{
    -- Treesitter
    use {
      'nvim-treesitter/nvim-treesitter',
      run = ':TSUpdate',
      config = function()
        require('_treesitter')
      end
    }

    -- Comment-string
    use {
      'JoosepAlviste/nvim-ts-context-commentstring',
      requires = {'nvim-treesitter/nvim-treesitter'}
    }
  -- }}}

  -- UI {{{
    -- Fzf-lua
    use {
      'ibhagwan/fzf-lua',
      branch = "main",
      config = function()
        require('_fzflua')
      end
    }

    -- Nvim-tree
    use {
      'kyazdani42/nvim-tree.lua',
      config = function()
        require('_nvimtree')
      end
    }

    -- Lualine
    use {
      'nvim-lualine/lualine.nvim',
      config = function()
        require('_lualine')
      end
    }
  -- }}}

  -- Lsp {{{
    -- Lspconfig
    use {
      'neovim/nvim-lspconfig',
      config = function()
        require('_lspconfig')
      end
    }

    -- Dap
    use {
      'mfussenegger/nvim-dap',
      requires = {'neovim/nvim-lspconfig'},
      config = function()
        require('_dap')
      end
    }

    -- Dap-virtual-text
    use {
      'theHamsta/nvim-dap-virtual-text',
      requires = {
        'neovim/nvim-lspconfig',
        'mfussenegger/nvim-dap'
      },
      config = function()
        require('_dapvirtualtext')
      end
    }

    -- Lua-dev
    use {
      'folke/lua-dev.nvim',
    }
  --- }}}

  -- Optional {{{
    -- Toggleterm
    use {
      'akinsho/toggleterm.nvim',
      tag = 'v1.*',
      config = function()
        require('_toggleterm')
      end
    }

     -- MarkdownPreview
    use {
      'iamcco/markdown-preview.nvim',
      run = 'cd app && yarn install',
    }

    -- Distant (remote)
    use {
      'chipsenkbeil/distant.nvim'
    }

    -- Firenvim (embed into browser)
    use {
      'glacambre/firenvim',
      run = function() vim.fn['firenvim#install'](0) end
    }
  -- }}}
end)

require('keymaps')
