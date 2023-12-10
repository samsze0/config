local M = {}

M.setup = function(opts) end

M = vim.tbl_extend("error", M, require("m.fzf.git"))
M = vim.tbl_extend("error", M, require("m.fzf.lsp"))
M = vim.tbl_extend("error", M, require("m.fzf.grep"))
M = vim.tbl_extend("error", M, require("m.fzf.jump"))
M = vim.tbl_extend("error", M, require("m.fzf.misc"))
M = vim.tbl_extend("error", M, require("m.fzf.undo"))
M = vim.tbl_extend("error", M, require("m.fzf.files"))
M = vim.tbl_extend("error", M, require("m.fzf.backup"))
M = vim.tbl_extend("error", M, require("m.fzf.diagnostics"))
M = vim.tbl_extend("error", M, require("m.fzf.notification"))
M = vim.tbl_extend("error", M, require("m.fzf.core"))

return M
