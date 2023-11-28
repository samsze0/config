local config = require('m.config')
local command = vim.api.nvim_create_user_command
local safe_require = require('m.utils').safe_require
local utils = require('m.utils')
local fmt = string.format

-- Utils
command("CopyRelPath", utils.run_and_notify(function()
  vim.fn.setreg('+', vim.fn.expand('%'))
end, fmt("Copied %s", vim.fn.expand('%'))), {})

-- FzfLua
local fzflua_custom = safe_require('m.fzflua-custom')
command("FzfLuaTest", fzflua_custom.test, {})
command("FzfLuaUndoTree", fzflua_custom.undo_tree, {})
if config.notify_backend == "nvim-notify" then
  command("FzfLuaNotifications", fzflua_custom.nvim_notify_notifications, {})
elseif config.notify_backend == "custom" then
  command("FzfLuaNotifications", fzflua_custom.notifications, {})
end
command("FzfLuaGitReflog", fzflua_custom.git_reflog, {})

-- Search n replace
local snr = require('m.search-n-replace')
command("SearchNReplace", snr.open, {})
