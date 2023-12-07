local M = {}

local api = vim.api

M.set_buf_var = function(buf, name, value)
  if api.nvim_buf_is_valid(buf) then
    api.nvim_buf_set_var(buf, "persist_" .. name, value)
  end
end

M.get_buf_var = function(buf, name)
  local success, v = pcall(api.nvim_buf_get_var, buf, "persist_" .. name)
  return success and v or nil
end

M.buf_debounce = function(f, duration, buf)
  if not M.get_buf_var(buf, "queued") then
    vim.defer_fn(function()
      M.set_buf_var(buf, "queued", false)
      f(buf)
    end, duration)
    M.set_buf_var(buf, "queued", true)
  end
end

return M
