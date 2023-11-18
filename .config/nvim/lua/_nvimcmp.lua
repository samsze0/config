local cmp = require('cmp')

local fallback_if_cmp_has_active = function(f)
  return function(fallback)
    if cmp.visible() and cmp.get_active_entry() ~= nil then
      f()
    else
      fallback()
    end
  end
end

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
    i = fallback_if_cmp_has_active(function()
      cmp.confirm()
    end),
    s = fallback_if_cmp_has_active(function()
      cmp.confirm()
    end),
    c = fallback_if_cmp_has_active(function()
      cmp.confirm()
    end),
  })
}

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end
  },
  completion = {
    keyword_length = 2, -- Number of char to trigger auto-completion
    -- autocompletion = ,  -- cmp.TriggerEvent | false
    -- completeopt = ,  -- See vim's completeopt
  },
  matching = {
    disallow_fuzzy_matching = false,
    disallow_fullfuzzy_matching = false,
    disallow_partial_fuzzy_matching = false,
    disallow_partial_matching = false,
    disallow_prefix_unmatching = false,
  },
  sorting = {
    -- comparators = function(entry1, entry2) cmp.config.compare end
  },
  window = {
    completion = {
      border = nil,
    },
    documentation = {
      border = nil,
    }
  },
  mapping = mapping,
  sources = cmp.config.sources({ -- Group index 1
    {
      name = 'nvim_lsp',
      -- option = ,
      -- keyword_length = ,
      -- priority = ,
      -- max_item_count = ,
      -- entry_filter = function(entry, ctx) end
    },
    { name = 'path' }
  }, { -- Group index 2
    -- { name = 'buffer' },
  }),
  formatting = {
    format = require('lspkind').cmp_format({
      mode = 'symbol_text',
      preset = 'codicons',
      maxwidth = 50,
      ellipsis_char = '...',
      before = function(entry, vim_item)
        return vim_item
      end
    })
  },
  view = {
    docs = {
      auto_open = true
    }
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
  completion = {
    keyword_length = 1
  },
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})
