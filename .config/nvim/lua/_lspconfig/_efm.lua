require('lspconfig')['efm'].setup{
  init_options = { documentFormatting = true },
  settings = {
    rootMarkers = {".git/"},
    languages = {
      -- lua = {
      --   { formatCommand = "lua-format -i", formatStdin = true }
      -- },
      -- python = {
      --   {
      --     lintCommand = 'mypy --show-column-numbers',
      --     lintFormats = {
      --       '%f:%l:%c: %trror: %m',
      --       '%f:%l:%c: %tarning: %m',
      --       '%f:%l:%c: %tote: %m'
      --     }
      --   },
      --   {
      --     formatCommand = 'black --quiet -',
      --     formatStdin = true
      --   },
      -- },
    }
  },
}
