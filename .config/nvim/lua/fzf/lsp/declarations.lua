return function(opts)
  opts = vim.tbl_extend("force", {}, opts or {})

  local handle = vim.lsp.buf.declaration({
    on_list = function(list)
      vim.notify(list)
      -- TODO
    end,
  })
end
