return function(opts)
  opts = vim.tbl_extend("force", {}, opts or {})

  local handle = vim.lsp.buf.implementation({
    on_list = function(list) vim.notify(list) end,
    -- TODO
  })
end
