local colors = require('colors/' .. vim.g.colors_name)

local im = require('lualine.themes.ayu_dark')

im.normal.a.bg = colors.blue
im.insert.a.bg = colors.red
im.visual.a.bg = colors.yellow

im.visual.c = {}
im.visual.c.fg = im.visual.b.fg
im.insert.c = {}
im.insert.c.fg = im.insert.b.fg
im.normal.c.fg = im.normal.b.fg

require('lualine').setup {
  options = {
    theme = im,
    component_separators = { left = ' ', right = ' ' },
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename', 'location', 'filetype'},
    lualine_x = {"require('dap').status()"},
    lualine_y = {'progress'},
    lualine_z = {'tabs'}
  },
}
