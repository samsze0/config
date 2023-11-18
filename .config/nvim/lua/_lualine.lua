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
  mode = 1,                       -- 0: tab_nr; 1: tab_name 2: tab_nr + tab_name
  path = 1,                       -- 0: filename; 1: relative; 2: full; 3: full + shorten home to ~
  tabs_color = {
    active = {
      fg = colors.white
    },
    inactive = {
      fg = colors.base04
    }
  },
  show_modified_status = false,
  symbols = {
    modified = '',
  },
}

local filename_session = {
  'filename',
  file_status = true,    -- Displays file status (readonly status, modified status)
  newfile_status = true, -- Display new file status (new file means no write after created)
  path = 1,              -- 0: filename; 1: relative path; 2: absolute path; 3: absolute path w/ ~ as home; 4: filename and parent dir
  shorting_target = 30,  -- Shortens path to leave x spaces in the window
  symbols = {
    modified = '',
    readonly = '',
    unnamed = '?',
    newfile = '',
  }
}


require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = theme,
    component_separators = { left = ' ', right = ' ' },
    section_separators = { left = '', right = '' },
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
      filename_session
    },
    lualine_c = {},
    lualine_x = { 'selectioncount', 'searchcount', 'filetype', 'encoding' },
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
