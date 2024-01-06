return function(opts)
  opts = vim.tbl_extend("force", {}, opts or {})

  local handle = vim.lsp.buf.type_definition({
    on_list = function(list)
      vim.info(list)
      -- TODO
    end,
  })
end
