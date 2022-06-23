local cmp = require('cmp')

require('cmp').setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = {
    ['<S-PageUp>'] = cmp.mapping(
      function(fallback)
        if cmp.visible() then
          cmp.scroll_docs(-5)
        else
          fallback()
        end
      end, { 'i', 'c' }
    ),
    ['<S-PageDown>'] = cmp.mapping(
      function(fallback)
        if cmp.visible() then
          cmp.scroll_docs(5)
        else
          fallback()
        end
      end, { 'i', 'c' }
    ),
    ['<C-Space>'] = cmp.mapping(
      function(_)
        if cmp.visible() then
          cmp.abort()
        else
          cmp.complete()
        end
      end, { 'i', 'c' }
    ),
    ['<Escape>'] = cmp.config.disable,
    ['<C-y>'] = cmp.config.disable,
    ['<C-e>'] = cmp.config.disable,
    ['<Up>'] = cmp.mapping({
      i = function(fallback)
        if cmp.visible() then
          cmp.abort()
        end
        fallback()
      end,
      c = function(_)
      end
    }),
    ['<Down>'] = cmp.mapping({
      i = function(fallback)
        if cmp.visible() then
          cmp.abort()
        end
        fallback()
      end,
      c = function(_)
      end
    }),
    ['<C-b>'] = cmp.config.disable,
    ['<C-f>'] = cmp.config.disable,
    ['<C-n>'] = cmp.config.disable,
    ['<C-p>'] = cmp.config.disable,
    ['<S-Down>'] = cmp.mapping(
      function(fallback)
        if cmp.visible() then
          cmp.select_next_item({ behavior = cmp.SelectBehavior })
        else
          fallback()
        end
      end, { 'i', 'c' }
    ),
    ['<S-Up>'] = cmp.mapping(
      function(fallback)
        if cmp.visible() then
          cmp.select_prev_item({ behavior = cmp.SelectBehavior })
        else
          fallback()
        end
      end, { 'i', 'c' }
    ),
    ["<CR>"] = cmp.mapping({
      i = function(fallback)
        fallback()
      end
    }),
    ["<Tab>"] = cmp.mapping(
      function(fallback)
        if cmp.visible() then
          local entry = cmp.get_selected_entry()
      	  if not entry then
    	      cmp.select_next_item({ behavior = cmp.SelectBehavior })
            cmp.confirm()
      	  else
	          cmp.confirm()
      	  end
        else
          fallback()
        end
      end, { "i", "c" }),
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'buffer' },
    { name = 'path' },
    { name = 'nvim_lsp_signature_help' },
    { name = 'fish' },
    {
      name = 'cmp-clippy',
      options = {
        model = "EleutherAI/gpt-neo-2.7B", -- check code clippy vscode repo for options
        key = "", -- huggingface.co api key
      }
    },
    { name = 'copilot' },
    { name = 'emoji' },
    { name = "latex_symbols" },
    { name = 'nvim_lua' },
    { name = 'cmp_pandoc' },
    { name = 'cmp_dictionary' }
  })
})

-- Fish
require('cmp').setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    { name = 'luasnip' },
    { name = 'buffer' },
    { name = 'path' },
    { name = 'fish' },
  })
})

-- Lua
require('cmp').setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'buffer' },
    { name = 'path' },
    { name = 'nvim_lsp_signature_help' },
    { name = 'nvim_lua' },
  })
})

-- Gitcommit
require('cmp').setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    { name = 'cmp_git' },
    { name = 'buffer' }
  })
})

-- Toml
require('cmp').setup.filetype('toml', {
  sources = cmp.config.sources({
    { name = 'crates' },
    { name = 'buffer' },
    { name = 'path' },
  })
})

-- Markdown
require('cmp').setup.filetype('markdown', {
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'path' },
    { name = 'emoji' },
    { name = 'latex_symbols' },
    { name = 'cmp_dictionary' }
  })
})

-- Search
require('cmp').setup.cmdline('/', {
  sources = cmp.config.sources({
    { name = 'buffer' },
  })
})

-- Cmdline
require('cmp').setup.cmdline(':', {
  sources = cmp.config.sources({
    { name = 'path' },
    { name = 'cmdline' }
  })
})
