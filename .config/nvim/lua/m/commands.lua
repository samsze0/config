local command = vim.api.nvim_create_user_command
local opts = {}

-- Utils
command("CopyRelPath", "call setreg('+', expand('%'))", opts)

-- FzfLua
local fzflua = require('m.fzflua')
command("FzfLuaTest", fzflua.test, opts)
command("FzfLuaUndoTree", fzflua.undo_tree, opts)
command("FzfLuaNotifications", fzflua.notifications, opts)