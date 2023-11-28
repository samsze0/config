-- :help <option> to get info (or :h)

vim.cmd [[set clipboard+=unnamedplus]] -- Use system clipboard

vim.opt.number = true
vim.opt.cursorline = false   -- Highlight current line
vim.opt.signcolumn = "auto"
vim.opt.signcolumn = 'yes:1' -- Maximum 1 signs, fixed
vim.opt.wrap = false

-- New window spawn on right or bottom
vim.opt.splitright = true
vim.opt.splitbelow = true
-- Make help window open as right split
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = vim.api.nvim_create_augroup("help_window", { clear = true }),
  pattern = { "*.txt" },
  callback = function()
    if vim.o.filetype == 'help' then vim.cmd.wincmd("L") end
  end
})

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

local config = require('m.config')

require('m.theme').setup({}) -- Setup once because some plugins might read existing highlight groups values

require("lazy").setup({
  {
    'nvim-telescope/telescope.nvim',
    enabled = config.telescope_over_fzflua,
    dependencies = {
      'nvim-lua/plenary.nvim'
    },
    config = function()
      require('m.telescope')
    end
  },
  {
    'ibhagwan/fzf-lua',
    enabled = not config.telescope_over_fzflua,
    config = function()
      require('m.fzflua').setup()
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
      require('m.copilotlua')
    end
  },
  {
    'nvim-lualine/lualine.nvim',
    enabled = config.statusline_plugin == "lualine",
    config = function()
      require('m.lualine')
    end
  },
  {
    -- Show colors for color values e.g. hex
    'norcalli/nvim-colorizer.lua',
    config = function()
      require('m.colorizer')
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
      require('m.toggleterm')
    end
  },
  {
    'lmburns/lf.nvim',
    enabled = config.lf_plugin == "nvim",
    requires = {
      'akinsho/toggleterm.nvim'
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
      require('m.lspconfig')
    end
  },
  {
    -- Autoclosing brackets
    'windwp/nvim-autopairs',
    config = function()
      require('m.autopairs')
    end
  },
  {
    -- Hop. Hijack search and f/t
    'folke/flash.nvim',
    config = function()
      require('m.flash')
    end
  },
  {
    -- Configure lua-language-server for neovim config
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
      require('m.gitsigns')
    end
  },
  {
    'nvim-tree/nvim-tree.lua',
    enabled = config.filetree_plugin == "nvimtree",
    config = function()
      require('m.nvimtree')
    end
  },
  {
    -- Indentation markers
    'lukas-reineke/indent-blankline.nvim',
    config = function()
      require('m.theme').setup({})
      require("ibl").setup({
        indent = { char = "▏" },
        scope = {
          highlight = require('m.theme').rainbow_hl_groups,
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
      require('m.theme').setup({})
      vim.g.rainbow_delimiters = { highlight = require('m.theme').rainbow_hl_groups }
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
      require('m.neoconf')
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
      require('m.conform')
    end
  },
  {
    -- Linters interface that reports to vim.diagnostic, unlike ALE
    'mfussenegger/nvim-lint',
    config = function()
      require('m.nvimlint')
    end
  },
  {
    -- Completion
    'hrsh7th/nvim-cmp',
    config = function()
      require('m.nvimcmp')
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
    enabled = config.diffview_plugin,
    config = function()
      require('m.diffview')
    end
  },
  {
    'nvim-pack/nvim-spectre',
    enabled = config.spectre_plugin,
    dependencies = {
      'nvim-lua/plenary.nvim'
    },
    config = function()
      require('m.spectre')
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
      require('m.treesitter')
    end
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    enabled = false,
    dependencies = {
      'nvim-treesitter/nvim-treesitter'
    },
    config = function()
      require('m.treesitter-textobjects')
    end
  },
  {
    -- Act as tab bar
    'akinsho/bufferline.nvim',
    enabled = config.tabbar_plugin == "bufferline",
    config = function()
      require('m.bufferline')
    end
  },
  {
    -- Relies on closing the instance and reopening it again. Doesn't work with help / command line window
    'declancm/maximize.nvim',
    enabled = config.maximize_plugin,
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
      require('m.ssr')
    end
  },
  {
    'tanvirtin/vgit.nvim',
    enabled = config.vgit_plugin,
    dependencies = {
      'nvim-lua/plenary.nvim'
    },
    config = function()
      require('m.vgit')
    end
  },
  {
    'mfussenegger/nvim-dap',
    enabled = config.dap_plugins,
    config = function()
    end
  },
  {
    'folke/trouble.nvim',
    enabled = config.trouble_plugin,
    config = function()
      require('m.trouble')
    end
  },
  {
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
      require('m.fidget')
    end
  },
  {
    -- vim.notify() backend
    'rcarriga/nvim-notify',
    enabled = config.notify_backend == "nvim-notify",
    config = function()
      require('m.nvim-notify')
    end
  },
  {
    -- Change code by utilizing treesitter
    'Wansmer/treesj',
    enabled = false,
  },
  {
    -- Peek lines when doing `:<line>` on cmdline
    'nacro90/numb.nvim',
    enabled = false,
  },
  {
    'kylechui/nvim-surround',
    enabled = config.surround_plugin == "nvim-surround",
    config = function()
      require('m.surround')
    end
  },
  {
    -- Requried for search-n-replace
    'nvim-lua/plenary.nvim',
  }
})

require('m.keymaps').setup()
require('m.winbar').setup() -- i.e. breadcrumbs
require('m.commands')
require('m.theme').setup(config.theme_opts)
if config.tabline_plugin == "custom" then
  -- :h tabbline
  -- :h tabbar
  require('m.tabline').setup({})
  vim.opt.showtabline = 2 -- 2 = always ; 1 = at least 2 tabs ; 0 = never
end
if config.statusline_plugin == "custom" then
  -- :h statusline
  vim.opt.laststatus = 2 -- 3 = global; 2 = always ; 1 = at least 2 windows ; 0 = never
  require('m.statusline').setup({})
end
if config.notify_backend == "custom" then
  require('m.notify')
end
if config.lf_plugin == "custom" then
  require('m.lf')
end

if vim.g.neovide then
  require("m.neovide")
end
