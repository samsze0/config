-- :help <option> to get info (or :h)

vim.cmd [[set clipboard+=unnamedplus]] -- Use system clipboard

vim.opt.number = true
vim.opt.cursorline = false   -- Highlight current line
vim.opt.signcolumn = "auto"
vim.opt.signcolumn = 'yes:1' -- Maximum 1 signs, fixed
vim.opt.wrap = false

-- Mouse
vim.opt.mousescroll = "ver:10"

-- :help fo-table
vim.cmd [[set formatoptions-=o]] -- Disable auto comment in normal mode
vim.cmd [[set formatoptions-=r]] -- Disable auto comment in insert mode
vim.cmd [[set formatoptions-=c]] -- Disable auto wrap comment

-- Format
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.smarttab = true
vim.opt.showtabline = 0
vim.cmd [[filetype on]]
vim.cmd [[filetype plugin off]]

-- Search
vim.opt.smartcase = true
vim.opt.ignorecase = true
vim.opt.hlsearch = true -- Highlight all matches. Pair with keymap :noh to clear highlights

-- Backup and swap
vim.cmd [[set backupdir=~/.cache/nvim/backup]]
vim.cmd [[set directory=~/.cache/nvim/swap]]
vim.cmd [[set undodir=~/.cache/nvim/undo]]

vim.opt.fillchars:append { diff = "╱" }

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

local config = require('config')

require('theme').setup({}) -- Setup once because some plugins might read existing highlight groups values

require("lazy").setup({
  {
    'nvim-telescope/telescope.nvim',
    enabled = config.telescope_over_fzflua,
    dependencies = {
      'nvim-lua/plenary.nvim'
    },
    config = function()
      require('_telescope')
    end
  },
  {
    -- TODO: open file when swap file exists throw cryptic error
    'ibhagwan/fzf-lua',
    enabled = not config.telescope_over_fzflua,
    config = function()
      require('_fzflua').setup()
    end,
  },
  {
    'github/copilot.vim',
    enabled = config.copilot_plugin == "vim",
    config = function()
      local run_setup_on_startup = false

      if run_setup_on_startup then
        vim.api.nvim_create_autocmd("VimEnter", {
          callback = function()
            vim.cmd("Copilot setup")
          end,
        })
      end
    end
  },
  {
    'zbirenbaum/copilot.lua',
    enabled = config.copilot_plugin == "lua",
    config = function()
      require('_copilotlua')
    end
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
    enabled = config.terminal_plugin == "floaterm" or config.lf_plugin == "vim",
    config = function()
      vim.g.floaterm_width = 0.9
      vim.g.floaterm_height = 0.9
    end,
  },
  {
    -- Lf integration
    'ptzz/lf.vim',
    enabled = config.lf_plugin == "vim",
    requires = {
      'voldikss/vim-floaterm'
    },
  },
  {
    'akinsho/toggleterm.nvim',
    enabled = config.terminal_plugin == "toggleterm",
    config = function()
      require('_toggleterm')
    end
  },
  {
    'lmburns/lf.nvim',
    enabled = config.lf_plugin == "nvim",
    requires = {
      'akinsho/toggleterm.nvim',
      config = function()
        require("toggleterm").setup()
      end
    },
    config = function()
      -- This feature will not work if the plugin is lazy-loaded
      vim.g.lf_netrw = 1

      require('lf').setup({
        escape_quit = false,
        border = "rounded",
      })

      vim.api.nvim_create_autocmd({ 'User' }, {
        pattern = "LfTermEnter",
        callback = function(a)
          vim.api.nvim_buf_set_keymap(a.buf, "t", "q", "q", { nowait = true })
        end,
      })
    end
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
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
    -- TODO: not working
    'folke/neodev.nvim',
    enabled = false,
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
    'nvim-tree/nvim-tree.lua',
    enabled = config.filetree_plugin == "nvimtree",
    config = function()
      require('_nvimtree')
    end
  },
  {
    -- Indentation markers
    'lukas-reineke/indent-blankline.nvim',
    config = function()
      require("ibl").setup({
        indent = { char = "▏" },
        scope = {
          highlight = require('theme').rainbow_hl_groups,
          show_start = false, -- underline on scope start
          show_end = false,   -- underline on scope end
          include = {
            node_type = { ["*"] = { "*" } }
          },
          exclude = {
            language = {},
            node_type = {},
          }
        }
      })
    end
  },
  {
    -- Brackets colorizer
    'HiPhish/rainbow-delimiters.nvim',
    config = function()
      vim.g.rainbow_delimiters = { highlight = require('theme').rainbow_hl_groups }
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
    enabled = true,
    priority = 100, -- Default priority is 50. Must load befor
    config = function()
      require('_neoconf')
    end
  },
  {
    -- Highlight occurences of word current cursor
    'RRethy/vim-illuminate',
    enabled = config.illuminate_plugin,
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
  },

  {
    'sindrets/diffview.nvim',
    config = function()
      require('_diffview')
    end
  },
  {
    'nvim-pack/nvim-spectre',
    enabled = config.spectre_plugin,
    dependencies = {
      'nvim-lua/plenary.nvim'
    },
    config = function()
      require('_spectre')
    end
  },
  {
    -- Make and resurrect sessions with vim's built-in mksession
    'folke/persistence.nvim',
    config = function()
      require('persistence').setup({
        options = { "buffers", "curdir", "tabpages", "winsize" },
        pre_save = function()
        end,
        save_empty = false, -- whether to save if there are no open file buffers
      })
    end
  },
  {
    'nvim-treesitter/nvim-treesitter',
    config = function()
      require('_treesitter')
    end
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    enabled = false,
    dependencies = {
      'nvim-treesitter/nvim-treesitter'
    },
    config = function()
      require('_treesitter_textobjects')
    end
  },
  {
    -- Act as tab bar
    'akinsho/bufferline.nvim',
    config = function()
      require('_bufferline')
    end
  },
  {
    -- TODO: doesn't work if window is not buffer? (e.g. help or command line window)
    -- Probably relies on closing the instance and reopening it again
    'declancm/maximize.nvim',
    enabled = require('config').maximize_plugin,
    config = function()
      require('maximize').setup({
        default_keymaps = false,
      })
    end
  },
  {
    'cshuaimin/ssr.nvim',
    enabled = config.ssr_plugin,
    config = function()
      require('_ssr')
    end
  },
  {
    'tanvirtin/vgit.nvim',
    enabled = config.vgit_plugin,
    dependencies = {
      'nvim-lua/plenary.nvim'
    },
    config = function()
      require('_vgit')
    end
  },
  {
    'mfussenegger/nvim-dap',
    enabled = config.dap_plugins,
    config = function()
      -- TODO
    end
  },
  {
    'folke/trouble.nvim',
    enabled = config.trouble_plugin,
    config = function()
      require('_trouble')
    end
  },
  {
    -- TODO: replace by forking fzflua
    'folke/todo-comments.nvim',
    enabled = false,
  },
  {
    -- UI Component Library
    'MunifTanjim/nui.nvim',
  },
  {
    -- vim.notify() backend + LSP $/progress handler
    'j-hui/fidget.nvim',
    enabled = config.notify_backend == "fidget",
    config = function()
      require('_fidget')
    end
  },
  {
    -- Change code by utilizing treesitter
    'Wansmer/treesj',
    enabled = false,
    -- TODO
  },
  {
    -- Peek lines when doing `:<line>` on cmdline
    'nacro90/numb.nvim',
    enabled = false,
    -- TODO
  },
  {
    'kylechui/nvim-surround',
    config = function()
      require('_surround')
    end
  }
})

require('keymaps').setup()
require('winbar').setup() -- i.e. breadcrumbs
require('commands')
require('theme').setup({
  debug = {
    enabled = false,
    toggle_colorizer = false,
    hide_defined_entries = false,
    show_non_ts_syntax_hl_only = true
  }
})

if vim.g.neovide then
  require("neovide")
end
