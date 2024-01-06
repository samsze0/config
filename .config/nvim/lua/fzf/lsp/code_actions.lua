return function(opts)
  opts = vim.tbl_extend("force", {}, opts or {})

  local handle = vim.lsp.buf.code_action({
    on_list = function(list)
      vim.debug(list)
      -- TODO
    end,
  })
end
