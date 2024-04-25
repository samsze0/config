local utils = require("utils")

local M = {}

---@alias VimTab { tabnr: number, variables: table, windows: number[] }

---@param tab_nr number
---@return VimTab
function M.gettabinfo(tab_nr) return vim.fn.gettabinfo(tab_nr or 0) end

---@return VimTab[]
function M.gettabsinfo()
  return utils.map(vim.fn.gettabinfo(), function(_, tab) return tab end)
end

return M
