local cmp = require('cmp')

local mapping = {
  ['<Up>'] = cmp.mapping(
    cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select, count = 1 }),
    { 'i', 'c', 's' }
  ),
  ['<Down>'] = cmp.mapping(
    cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select, count = 1 }),
    { 'i', 'c', 's' }
  ),
  ['<PageUp>'] = cmp.mapping(
    cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select, count = 10 }),
    { 'i', 'c', 's' }
  ),
  ['<PageDown>'] = cmp.mapping(
    cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select, count = 10 }),
    { 'i', 'c', 's' }
  ),
  ['<S-Up>'] = cmp.mapping(
    cmp.mapping.scroll_docs(-5),
    { 'i', 'c', 's' }
  ),
  ['<S-Down>'] = cmp.mapping(
    cmp.mapping.scroll_docs(5),
    { 'i', 'c', 's' }
  ),
  ['<S-PageUp>'] = cmp.mapping(
    cmp.mapping.scroll_docs(-10),
    { 'i', 'c', 's' }
  ),
  ['<S-PageDown>'] = cmp.mapping(
    cmp.mapping.scroll_docs(10),
    { 'i', 'c', 's' }
  ),
  ['<C-Space>'] = cmp.mapping(
    cmp.mapping.complete(),
    { 'i', 'c', 's' }
  ),
  ['<Tab>'] = cmp.mapping(
    cmp.mapping.confirm({ select = true }),
    { 'i', 'c', 's' }
  ),
  ['<CR>'] = cmp.mapping({
    i = cmp.mapping.confirm({ select = true }),
    s = cmp.mapping.confirm({ select = true }),
    -- c = function(fallback) -- First confirm the entry if there is any, then execute fallback
    --   if not cmp.get_active_entry() == nil then
    --     cmp.complete_common_string()
    --   end

    --   return fallback()
    -- end
  })
}

cmp.setup({
  -- preselect = cmp.PreselectMode.Item,
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end
  },
  window = {
    -- completion = cmp.config.window.bordered(),
    -- documentation = cmp.config.window.bordered(),
  },
  mapping = mapping,
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
  }, {
    -- { name = 'buffer' },
  }),
  formatting = {
    format = require('lspkind').cmp_format({
      mode = 'symbol_text',  -- show only symbol annotations
      preset = 'codicons',
      maxwidth = 50,         -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
      ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)

      -- The function below will be called before any actual modifications from lspkind
      -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
      before = function(entry, vim_item)
        return vim_item
      end
    })
  }
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    { name = 'git' },
  }, {
    { name = 'buffer' },
  })
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
  completion = {
    autocomplete = false,
  },
  sources = {
    { name = 'buffer' } -- Can coverup the editor
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})
