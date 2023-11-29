-- https://github.com/mfussenegger/nvim-lint#available-linters
require("lint").linters_by_ft = {
  lua = { "luacheck" },
}

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  pattern = "*",
  callback = function() require("lint").try_lint() end,
})
