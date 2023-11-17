local theme = require('lualine.themes.ayu_dark')

local colors = require('theme').colors

theme.normal.a.bg = colors.blue
theme.insert.a.bg = colors.red
theme.visual.a.bg = colors.yellow

local mode_session = {
  'mode',
  fmt = function(str)
    return " "
  end
}

local tab_session = {
  'tabs',
  tab_max_length = 40,            -- Maximum width of each tab. The content will be shorten dynamically (example: apple/orange -> a/orange)
  max_length = vim.o.columns / 2, -- Maximum width of tabs component.
  -- Note:
  -- It can also be a function that returns
  -- the value of `max_length` dynamically.
  mode = 1, -- 0: Shows tab_nr
  -- 1: Shows tab_name
  -- 2: Shows tab_nr + tab_name

  path = 1, -- 0: just shows the filename
  -- 1: shows the relative path and shorten $HOME to ~
  -- 2: shows the full path
  -- 3: shows the full path and shorten $HOME to ~

  -- Automatically updates active tab color to match color of other components (will be overidden if buffers_color is set)
  use_mode_colors = false,

  tabs_color = {
    -- Same values as the general color option can be used here.
    active = {
      fg = colors.white
    },
    inactive = {
      fg = colors.base04
    }
  },

  show_modified_status = false, -- Shows a symbol next to the tab name if the file has been modified.
  symbols = {
    modified = '',           -- Text to show when the file is modified.
  },

  -- fmt = function(name, context)
  --   local num_of_tabs = vim.fn.tabpagenr()
  --   local tabnr = vim.fn.tabpagenr()
  --
  --   return tabnr .. "/" .. num_of_tabs
  -- end
}

local filename_session = {
  'filename',
  file_status = true,    -- Displays file status (readonly status, modified status)
  newfile_status = true, -- Display new file status (new file means no write after created)
  path = 1,              -- 0: Just the filename
  -- 1: Relative path
  -- 2: Absolute path
  -- 3: Absolute path, with tilde as the home directory
  -- 4: Filename and parent dir, with tilde as the home directory

  shorting_target = 50, -- Shortens path to leave 40 spaces in the window
  -- for other components. (terrible name, any suggestions?)
  symbols = {
    modified = '', -- Text to show when the file is modified.
    readonly = '', -- Text to show when the file is non-modifiable or readonly.
    unnamed = '?',  -- Text to show for unnamed buffers.
    newfile = '', -- Text to show for newly created file before first write
  }
}


require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = theme,
    component_separators = { left = ' ', right = ' ' },
    section_separators = { left = '', right = '' },
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    }
  },
  sections = {
    lualine_a = {
      mode_session
    },
    lualine_b = {
      -- tab_session
      filename_session
    },
    lualine_c = {},
    lualine_x = { 'filetype', 'encoding' },
    lualine_y = {},
    lualine_z = {}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {
      filename_session
    },
    lualine_x = {},
    lualine_y = { 'filetype', 'encoding' },
    lualine_z = {}
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {}
}
