local actions = require "fzf-lua.actions"

require('fzf-lua').setup({
  winopts = {
    fullscreen       = true,           -- start fullscreen?
    preview = {
      border         = 'border',        -- border|noborder, applies only to
                                        -- native fzf previewers (bat/cat/git/etc)
      wrap           = 'nowrap',        -- wrap|nowrap
      hidden         = 'nohidden',      -- hidden|nohidden
      vertical       = 'down:50%',      -- up|down:size
      horizontal     = 'right:50%',     -- right|left:size
      layout         = 'vertical',          -- horizontal|vertical|flex
      flip_columns   = 120,             -- #cols to switch to horizontal on flex
      -- Only valid with the builtin previewer:
      title          = true,            -- preview border title (file/buf)?
      scrollbar      = 'float',         -- `false` or string:'float|border'
                                        -- float:  in-window floating border
                                        -- border: in-border chars (see below)
      scrolloff      = '-2',            -- float scrollbar offset from right
                                        -- applies only when scrollbar = 'float'
      scrollchars    = {'█', '' },      -- scrollbar chars ({ <full>, <empty> }
                                        -- applies only when scrollbar = 'border'
      delay          = 100,             -- delay(ms) displaying the preview
                                        -- prevents lag on fast scrolling
      winopts = {                       -- builtin previewer window options
        number            = true,
        relativenumber    = false,
        cursorline        = true,
        cursorlineopt     = 'both',
        cursorcolumn      = false,
        signcolumn        = 'no',
        list              = false,
        foldenable        = false,
        foldmethod        = 'manual',
      },
    },
    on_create = function()
      -- called once upon creation of the fzf main window
      -- can be used to add custom fzf-lua mappings, e.g:
      --   vim.api.nvim_buf_set_keymap(0, "t", "<C-j>", "<Down>",
      --     { silent = true, noremap = true })
    end,
  },
  keymap = {
    builtin = {
      -- ["<C-h>"]        = "toggle-help",
      -- ["<C-f>"]        = "toggle-fullscreen",
      -- ["<C-r>"]        = "toggle-preview-cw",
      ["<S-PageDown>"]    = "preview-page-down",
      ["<S-PageUp>"]      = "preview-page-up",
      ["<S-Down>"]    = "preview-page-down",
      ["<S-Up>"]      = "preview-page-up",
    },
    fzf = {
      ["shift-down"]  = "preview-page-down",
      ["shift-up"]    = "preview-page-up",
    },
  },
  actions = {
    files = {
      -- providers that inherit these actions:
      --   files, git_files, git_status, grep, lsp
      --   oldfiles, quickfix, loclist, tags, btags
      --   args
      ["default"]     = actions.file_edit,
    },
    buffers = {
      -- providers that inherit these actions:
      --   buffers, tabs, lines, blines
      ["default"]     = actions.buf_edit,
    }
  },
  lsp = {
    severity = "warn",
  },
})
