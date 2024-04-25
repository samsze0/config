local cmp = require("cmp")

local fallback_if_cmp_has_no_active_entry = function(f)
  return function(fallback)
    if cmp.visible() and cmp.get_active_entry() ~= nil then
      f()
    else
      fallback()
    end
  end
end

local mapping = {
  ["<Up>"] = cmp.mapping(fallback_if_cmp_has_no_active_entry(function() cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select, count = 1 }) end), { "i", "c", "s" }),
  ["<Down>"] = cmp.mapping(fallback_if_cmp_has_no_active_entry(function() cmp.select_next_item({ behavior = cmp.SelectBehavior.Select, count = 1 }) end), { "i", "c", "s" }),
  ["<PageUp>"] = cmp.mapping(
    fallback_if_cmp_has_no_active_entry(function()
      cmp.select_prev_item({
        behavior = cmp.SelectBehavior.Select,
        count = 10,
      })
    end),
    { "i", "c", "s" }
  ),
  ["<PageDown>"] = cmp.mapping(
    fallback_if_cmp_has_no_active_entry(function()
      cmp.select_next_item({
        behavior = cmp.SelectBehavior.Select,
        count = 10,
      })
    end),
    { "i", "c", "s" }
  ),
  ["<S-Up>"] = cmp.mapping(fallback_if_cmp_has_no_active_entry(function() cmp.scroll_docs(-5) end), { "i", "c", "s" }),
  ["<S-Down>"] = cmp.mapping(fallback_if_cmp_has_no_active_entry(function() cmp.scroll_docs(5) end), { "i", "c", "s" }),
  ["<S-PageUp>"] = cmp.mapping(fallback_if_cmp_has_no_active_entry(function() cmp.scroll_docs(-10) end), { "i", "c", "s" }),
  ["<S-PageDown>"] = cmp.mapping(fallback_if_cmp_has_no_active_entry(function() cmp.scroll_docs(10) end), { "i", "c", "s" }),
  ["<C-Space>"] = cmp.mapping(function(fallback)
    local close_if_open = false

    if close_if_open then
      if cmp.visible() and cmp.get_active_entry() ~= nil then
        cmp.close()
        return
      end
    end

    if not cmp.visible() then cmp.complete() end

    cmp.select_next_item({ behavior = cmp.SelectBehavior.Select, count = 1 })
  end, { "i", "c", "s" }),
  ["<M-x>"] = cmp.mapping(function(fallback)
    if cmp.visible() then
      cmp.close()
    else
      fallback()
    end
  end, { "i", "c", "s" }),
  ["<Tab>"] = cmp.mapping({
    i = fallback_if_cmp_has_no_active_entry(function() cmp.confirm() end),
    s = fallback_if_cmp_has_no_active_entry(function() cmp.confirm() end),
    c = function(fallback)
      if not cmp.visible() then
        cmp.complete()
        cmp.select_next_item({ behavior = cmp.SelectBehavior.Select, count = 1 })
      else
        cmp.confirm({ select = true })
      end
    end,
  }),
  ["<CR>"] = cmp.mapping({
    i = fallback_if_cmp_has_no_active_entry(function() cmp.confirm() end),
    s = fallback_if_cmp_has_no_active_entry(function() cmp.confirm() end),
    c = fallback_if_cmp_has_no_active_entry(function() cmp.confirm() end),
  }),
}

cmp.setup({
  preselect = cmp.PreselectMode.None,
  snippet = {
    expand = function(args) require("luasnip").lsp_expand(args.body) end,
  },
  completion = {
    keyword_length = 1, -- Number of char to trigger auto-completion
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
    },
  },
  mapping = mapping,
  sources = cmp.config.sources({
    {
      name = "nvim_lsp",
      entry_filter = function(entry, ctx) return entry end,
      priority = 100,
    },
    {
      name = "path",
      keyword_length = 1,
      max_item_count = 5,
      priority = 30,
    },
    {
      name = "buffer",
      max_item_count = 5,
      priority = 30,
    },
  }),
  formatting = {
    format = require("lspkind").cmp_format({
      mode = "symbol_text",
      preset = "codicons",
      maxwidth = 50,
      ellipsis_char = "...",
      before = function(entry, vim_item) return vim_item end,
    }),
  },
  view = {
    docs = {
      auto_open = true,
    },
  },
})

-- Set configuration for specific filetype.
cmp.setup.filetype("gitcommit", {
  sources = cmp.config.sources({
    { name = "git" },
    { name = "buffer" },
  }),
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ "/", "?" }, {
  completion = {
    keyword_length = 1, -- Number of char to trigger auto-completion
  },
  sources = {
    { name = "buffer", max_item_count = 10 },
  },
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(":", {
  completion = {},
  sources = cmp.config.sources({
    { name = "path", max_item_count = 10 },
    { name = "cmdline" },
  }),
})
