local options = {
  RGB      = true,         -- #RGB hex codes
  RRGGBB   = true,         -- #RRGGBB hex codes
  names    = false,        -- "Name" codes like Blue
  RRGGBBAA = true,         -- #RRGGBBAA hex codes
  rgb_fn   = false,        -- CSS rgb() and rgba() functions
  hsl_fn   = false,        -- CSS hsl() and hsla() functions
  css      = false,        -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
  css_fn   = false,        -- Enable all CSS *functions*: rgb_fn, hsl_fn
  mode     = 'background', -- Set the display mode.
}

require('colorizer').setup({
  '*', -- Highlight all files, but customize some others.
  css = { rgb_fn = true, hsl_fn = true, css = true, css_fn = true, names = true },
}, options)

