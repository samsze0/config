local utils = require("utils")

local M = {}

---@alias VimBuffer { bufnr: number, changed: boolean, changedtick: number, hidden: boolean, lastused: number, listed: boolean, lnum: number, linecount: number, loaded: boolean, name: string, signs: { id: string, lnum: number, name: string }, variables: table, windows: number[] }

---@param opts? { buflisted?: boolean, bufloaded?: boolean, bufmodified?: boolean }
---@return VimBuffer[]
function M.getbufsinfo(opts)
  return utils.map(vim.fn.getbufinfo(opts or {}), function(_, buf)
    buf.changed = buf.changed == 1
    buf.hidden = buf.hidden == 1
    buf.listed = buf.listed == 1
    buf.loaded = buf.loaded == 1
    return buf
  end)
end

return M
