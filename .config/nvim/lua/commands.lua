local command = vim.api.nvim_create_user_command
local opts = {}

-- Utils
command("CopyRelPath", "call setreg('+', expand('%'))", opts)
