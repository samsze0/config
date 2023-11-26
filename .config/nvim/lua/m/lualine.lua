local colors = require('m.theme').colors

local theme = {}
for _, mode in ipairs({ "normal", "insert", "visual", "replace", "command", "inactive" }) do
  theme[mode] = {
    a = { fg = colors.white, gui = "bold" },
    b = { bg = colors.gray_100, fg = colors.gray_700 },
    c = { bg = colors.gray_100, fg = colors.gray_600 }
  }
end

local multi_color = false
if multi_color then
  theme.normal.a.bg = colors.blue_700
  theme.insert.a.bg = colors.gray_500
  theme.visual.a.bg = colors.yellow_700
else
  theme.normal.a.bg = colors.gray_600
  theme.insert.a.bg = colors.gray_600
  theme.visual.a.bg = colors.gray_600
end
theme.replace.a.bg = colors.gray_500
theme.command.a.bg = colors.gray_500
theme.inactive.b.fg = colors.gray_500
theme.inactive.c.fg = colors.gray_500

local mode_session = {
  'mode',
  fmt = function(mode)
    return ''
  end
}

local function maximize_status_session()
  return vim.t.maximized and 'Z' or ''
end

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
      fg = colors.gray_300
    }
  },
  show_modified_status = false,
  symbols = {
    modified = '',
  },
}

local indicator_colors = {
  red = {
    fg = colors.red_700,
    bg = colors.gray_100,
  },
  yellow = {
    fg = colors.yellow_700,
    bg = colors.gray_100,
  },
  blue = {
    fg = colors.blue_700,
    bg = colors.gray_100,
  },
  gray = {
    fg = colors.gray_700,
    bg = colors.gray_100,
  },
}

local gitsigns_status = vim.b.gitsigns_status_dict or {
  added = 0,
  changed = 0,
  removed = 0,
}

local diff_session = {
  'diff',
  colored = true,
  diff_color = {
    added    = indicator_colors.gray,
    modified = indicator_colors.gray,
    removed  = indicator_colors.gray,
  },
  symbols = { added = '+', modified = '~', removed = '-' },
  source = {
    added = gitsigns_status.added,
    modified = gitsigns_status.changed,
    removed = gitsigns_status.removed,
  },
}

local diagnostic_session = {
  'diagnostics',
  sources = { 'nvim_lsp' },
  sections = { 'error', 'warn', 'info', 'hint' },
  diagnostics_color = {
    error = indicator_colors.red,
    warn = indicator_colors.yellow,
    info = indicator_colors.blue,
    hint = indicator_colors.blue,
  },
  symbols = { error = 'E', warn = 'W', info = 'I', hint = 'H' },
  colored = true,
  update_in_insert = false,
  always_visible = false,
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

local use_triangle_separator = false

require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = theme,
    component_separators = { left = ' ', right = ' ' },
    section_separators = { left = use_triangle_separator and '' or ' ', right = use_triangle_separator and '' or ' ' },
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
    lualine_c = { diagnostic_session, diff_session },
    lualine_x = { 'selectioncount', 'searchcount', 'filetype', 'encoding' },
    lualine_y = {},
    lualine_z = { maximize_status_session }
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
