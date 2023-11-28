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
    -- Prefer this over "filetype detect"
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

M.open_diff_in_new_tab = function(buf1_content, buf2_content_or_filepath, opts)
  opts = opts or {}

  vim.api.nvim_command("tabnew")

  -- Create the right window first
  if type(buf2_content_or_filepath) == "string" then
    vim.api.nvim_command(string.format("edit %s", buf2_content_or_filepath))
    opts.filetype = vim.bo.filetype -- Overwrite filetype if existing file was given as buf2
  else
    M.show_content_as_buf(buf2_content_or_filepath, opts)
  end
  vim.api.nvim_command("diffthis")

  vim.api.nvim_command("vsplit")
  M.show_content_as_buf(buf1_content, opts)
  vim.api.nvim_command("diffthis")

  vim.api.nvim_command("wincmd l") -- Move focus to right window
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

-- Tweaked from:
-- https://github.com/ibhagwan/fzf-lua/blob/main/lua/fzf-lua/utils.lua
function M.strip_ansi_coloring(str)
  if not str then return str end
  -- remove escape sequences of the following formats:
  -- 1. ^[[34m
  -- 2. ^[[0;34m
  -- 3. ^[[m
  return str:gsub("%[[%d;]-m", "")
end

-- From:
-- https://github.com/ibhagwan/fzf-lua/blob/main/lua/fzf-lua/utils.lua
-- Sets an invisible unicode character as icon separator
-- the below was reached after many iterations, a short summary of everything
-- that was tried and why it failed:
-- nbsp, U+00a0: the original separator, fails with files that contain nbsp
-- nbsp + zero-width space (U+200b): works only with `sk` (`fzf` shows <200b>)
-- word joiner (U+2060): display works fine, messes up fuzzy search highlights
-- line separator (U+2028), paragraph separator (U+2029): created extra space
-- EN space (U+2002): seems to work well
-- For more unicode SPACE options see:
-- http://unicode-search.net/unicode-namesearch.pl?term=SPACE&.submit=Search
M.fzflua_nbsp = "\xe2\x80\x82" -- "\u{2002}"

-- Tweaked from:
-- https://github.com/ibhagwan/fzf-lua/blob/main/lua/fzf-lua/path.lua
function M.strip_before_last_occurrence_of(str, sep)
  local idx = M.last_index_of(str, sep) or 0
  return str:sub(idx + 1), idx
end

-- Tweaked from:
-- https://github.com/ibhagwan/fzf-lua/blob/main/lua/fzf-lua/path.lua
function M.last_index_of(haystack, needle)
  local i = haystack:match(".*" .. needle .. "()")
  if i == nil then return nil else return i - 1 end
end

function M.iter_to_table(iter)
  local tbl = {}
  for v in iter do
    table.insert(tbl, v)
  end
  return tbl
end

function M.get_visual_selection()
  local start_pos = vim.api.nvim_buf_get_mark(0, '<')
  local end_pos = vim.api.nvim_buf_get_mark(0, '>')
  local lines = vim.fn.getline(start_pos[1], end_pos[1])
  -- add when only select in 1 line
  local plusEnd = 0
  local plusStart = 1
  if #lines == 0 then
    return ''
  elseif #lines == 1 then
    plusEnd = 1
    plusStart = 1
  end
  lines[#lines] = string.sub(lines[#lines], 0, end_pos[2] + plusEnd)
  lines[1] = string.sub(lines[1], start_pos[2] + plusStart, string.len(lines[1]))
  return table.concat(lines, '')
end

return M
