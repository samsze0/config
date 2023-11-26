-- Tweak from:
-- https://github.com/sindrets/diffview.nvim/blob/main/lua/diffview/path.lua

local M = {}

local sep = "/"

---Joins an ordered list of path segments into a path string.
---@vararg ... string|string[] Paths
---@return string
M.join = function(...)
  local segments = { ... }

  if type(segments[1]) == "table" then
    segments = segments[1]
  end

  local path = ""

  for i = 1, #segments do
    local seg = segments[i]
    if seg and seg ~= "" then
      if #path > 0 and not path:sub(-1, -1):match("[\\/]") then
        path = path .. sep
      end
      path = path .. seg
    end
  end

  return path
end

return M
