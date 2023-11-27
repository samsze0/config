local command = vim.api.nvim_create_user_command
local opts = {}
local safe_require = require('m.utils').safe_require

-- Utils
command("CopyRelPath", "call setreg('+', expand('%'))", opts)

-- FzfLua
local fzflua_custom = safe_require('m.fzflua-custom')
command("FzfLuaTest", fzflua_custom.test, opts)
command("FzfLuaUndoTree", fzflua_custom.undo_tree, opts)
command("FzfLuaNotifications", fzflua_custom.notifications, opts)
command("FzfLuaGitReflog", fzflua_custom.git_reflog, opts)
