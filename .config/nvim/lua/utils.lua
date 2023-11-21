local M = {}

M.map = function(tbl, func)
  local new_tbl = {}
  for i, v in ipairs(tbl) do
    local result = func(i, v)
    if result ~= nil then
      table.insert(new_tbl, result)
    end
  end
  return new_tbl
end

M.split_string = function(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
    table.insert(t, str)
  end
  return t
end

M.show_content_as_buf = function(buf_lines)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, buf_lines)
  vim.api.nvim_set_current_buf(buf)
end

M.contains = function(tbl, str)
  for i, v in ipairs(tbl) do
    if v == str then
      return true
    end
  end
  return false
end

return M
