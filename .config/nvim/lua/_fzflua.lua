local actions = require "fzf-lua.actions"

require('fzf-lua').setup({
  winopts = {
    fullscreen = false,
    preview    = {
      border     = 'noborder',
      wrap       = 'nowrap',
      hidden     = 'nohidden',
      vertical   = 'down:50%',
      horizontal = 'right:50%',
      layout     = 'horizontal',
      title      = true,
      scrollbar  = 'float',
      delay      = 100, -- delay(ms) displaying the preview
      winopts    = {
        -- builtin previewer window options
        number         = true,
        relativenumber = false,
        cursorline     = true,
        cursorlineopt  = 'both',
        cursorcolumn   = false,
        signcolumn     = 'no',
        list           = false,
        foldenable     = false,
        foldmethod     = 'manual',
      },
    },
    on_create  = function()
    end,
  },
  keymap = {
    builtin = {
      ["<S-PageDown>"] = "preview-page-down",
      ["<S-PageUp>"]   = "preview-page-up",
      ["<S-Down>"]     = "preview-page-down",
      ["<S-Up>"]       = "preview-page-up",
    },
    fzf = {
      ["shift-down"] = "preview-page-down",
      ["shift-up"]   = "preview-page-up",
    },
  },
  actions = {
    files = {
      ["default"] = actions.file_edit,
    },
    buffers = {
      ["default"] = actions.buf_edit,
    }
  },
  lsp = {
    severity = "warn",
  },
})
