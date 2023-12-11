local M = {}

M.setup = function(opts) end

M = vim.tbl_extend("error", M, require("fzf.git"))
M = vim.tbl_extend("error", M, require("fzf.lsp"))
M = vim.tbl_extend("error", M, require("fzf.grep"))
M = vim.tbl_extend("error", M, require("fzf.jump"))
M = vim.tbl_extend("error", M, require("fzf.misc"))
M = vim.tbl_extend("error", M, require("fzf.undo"))
M = vim.tbl_extend("error", M, require("fzf.files"))
M = vim.tbl_extend("error", M, require("fzf.backup"))
M = vim.tbl_extend("error", M, require("fzf.diagnostics"))
M = vim.tbl_extend("error", M, require("fzf.notification"))
M = vim.tbl_extend("error", M, require("fzf.core"))

return M
