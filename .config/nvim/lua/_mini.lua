-- Surround
require('mini.surround').setup({
  n_lines = 20,  -- No. lines to search
  mappings = {
    add = 'sa', -- Add surrounding
    delete = 'sd', -- Delete surrounding
    replace = 'sc', -- Replace surrounding
  },
})

-- Indent-scope
require('mini.indentscope').setup({
  draw = {
    -- Delay (in ms) between event and start of drawing scope indicator
    delay = 50,
    animation = require('mini.indentscope').gen_animation('none')
  },

  -- Module mappings. Use `''` (empty string) to disable one.
  mappings = {
    -- Textobjects
    object_scope = 'ii',
    object_scope_with_border = 'ai',
  },

  -- Options which control computation of scope.
  opions = {
    border = 'both',  -- Can be one of: 'both', 'top', 'bottom', 'none'.
    indent_at_cursor = true,
  },

  -- Which character to use for drawing scope indicator
  symbol = '│',
})
