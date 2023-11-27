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

M.show_content_as_buf = function(buf_lines, opts)
  opts = opts or {}
  opts = vim.tbl_deep_extend("keep", opts, {
    filetype = "text",
  })

  local buf_nr = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_buf_set_lines(buf_nr, 0, -1, false, buf_lines)
  vim.api.nvim_set_current_buf(buf_nr)
  vim.api.nvim_buf_call(buf_nr, function()
    vim.cmd(string.format("set filetype=%s", opts.filetype))
  end)
end

M.contains = function(tbl, str)
  for i, v in ipairs(tbl) do
    if v == str then
      return true
    end
  end
  return false
end

M.get_keys_as_string = function(tbl)
  local keys = ""
  for key, _ in pairs(tbl) do
    keys = keys .. key .. ", "
  end
  -- Remove the last comma and space
  keys = keys:sub(1, -3)
  return keys
end

M.get_command_history = function()
  local history = {}
  for i = 1, vim.fn.histlen(":") do
    table.insert(history, vim.fn.histget(":", i))
  end
  return history
end

M.get_register_length = function(reg)
  local content = vim.fn.getreg(reg)
  return #content
end

M.run_and_notify = function(f, msg)
  return function()
    f()
    vim.notify(msg)
  end
end

M.open_diff_in_new_tab = function(buf1_content, buf2_content, opts)
  opts = opts or {}

  vim.api.nvim_command("tabnew")
  M.show_content_as_buf(buf1_content, opts)
  vim.api.nvim_command("diffthis")

  vim.api.nvim_command("vsplit")
  vim.api.nvim_command("wincmd l")
  M.show_content_as_buf(buf2_content, opts)
  vim.api.nvim_command("diffthis")
end

M.safe_require = function(module_name, opts)
  opts = opts or {}
  opts = vim.tbl_deep_extend("keep", opts, {
    notify = true,
    log_level = vim.log.levels.ERROR,
  })
  local ok, module = pcall(require, module_name)
  if not ok then
    if opts.notify then
      vim.notify(string.format("Failed to load module %s", module_name), opts.log_level)
    end
    return setmetatable({}, {
      __index = function(_, key)
        if opts.notify then
          vim.notify(string.format("Failed to access key %s in module %s", key, module_name), opts.log_level)
        end
        return nil
      end,
    }) -- In case we try to index into the result of safe_require
  end
  return module
end

return M
