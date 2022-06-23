-- Peek
vim.api.nvim_set_keymap("n", "lu", "<cmd>lua vim.lsp.buf.hover()<CR>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("i", "<C-p>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("n", "lo", "<cmd>FzfLua lsp_definitions<CR>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("n", "li", "<cmd>FzfLua lsp_references<CR>", {silent = true, noremap = true})

-- Action
vim.api.nvim_set_keymap("n", "lr", "<cmd>lua vim.lsp.buf.rename()<CR>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("n", "la", "<cmd>lua vim.lsp.buf.code_action()<CR>", {silent = true, noremap = true})

-- Diagnostic
vim.api.nvim_set_keymap("n", "le", "<cmd>lua vim.diagnostic.open_float()<CR>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("n", "ls", [[<cmd>lua vim.lsp.buf.goto_prev({
  severity = {min=vim.diagnostic.severity.WARN}
})<CR>]], {silent = true, noremap = true})
vim.api.nvim_set_keymap("n", "lf", [[<cmd>lua vim.lsp.buf.goto_next({
  severity = {min=vim.diagnostic.severity.WARN}
})<CR>]], {silent = true, noremap = true})
vim.api.nvim_set_keymap("n", "ld", "<cmd>FzfLua lsp_document_diagnostics<CR>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("n", "lD", "<cmd>FzfLua lsp_workspace_diagnostics<CR>", {silent = true, noremap = true})

-- Symbols/tags
vim.api.nvim_set_keymap("n", "ll", "<cmd>FzfLua lsp_document_symbols<CR>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("n", "lL", "<cmd>FzfLua lsp_workspace_symbols<CR>", {silent = true, noremap = true})

-- Restart server
vim.api.nvim_set_keymap("n", "lR", "<cmd>LspRestart<CR>", {silent = true, noremap = true})
