local M = {}

---@param str string
---@param n number
function M.nth_byte(str, n) return str:byte(n, n) end

---@param bytes number[]
---@return string
function M.bytes_to_string(bytes)
  local s = ""
  for _, el in ipairs(bytes) do
    s = s .. string.char(el)
  end
  return s
end

---@param str string
---@return number[]
function M.string_to_bytes(str)
  local bytes = {}
  for i = 1, #str do
    table.insert(bytes, str:byte(i))
  end
  return bytes
end

return M
