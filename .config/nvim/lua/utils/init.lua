local M = {}

M.map = function(tbl, func, opts)
  opts = vim.tbl_extend("force", { skip_nil = true }, opts or {})

  local new_tbl = {}
  if M.is_array(tbl) then
    for i, v in ipairs(tbl) do
      local result = func(i, v)
      if opts.skip_nil and result == nil then
        -- Skip
      else
        table.insert(new_tbl, result)
      end
    end
    return new_tbl
  else
    for k, v in pairs(tbl) do
      local result = func(k, v)
      if opts.skip_nil and result == nil then
        -- Skip
      else
        table.insert(new_tbl, result)
      end
    end
  end

  return new_tbl
end

M.split_string = function(inputstr, sep)
  if sep == nil then sep = "%s" end
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
  vim.api.nvim_buf_call(
    buf_nr,
    function() vim.cmd(string.format("set filetype=%s", opts.filetype)) end
  )
end

M.contains = function(tbl, str)
  for i, v in ipairs(tbl) do
    if v == str then return true end
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
  -- TODO: type annotations
  opts = opts or {}
  opts = vim.tbl_deep_extend("keep", opts, {
    notify = true,
    log_level = vim.log.levels.ERROR,
  })
  local ok, module = pcall(require, module_name)
  if not ok then
    if opts.notify then
      vim.notify(
        string.format("Failed to load module %s", module_name),
        opts.log_level
      )
    end
    return setmetatable({}, {
      __index = function(_, key)
        if opts.notify then
          vim.notify(
            string.format(
              "Failed to access key %s in module %s",
              key,
              module_name
            ),
            opts.log_level
          )
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

-- Tweaked from:
-- https://github.com/ibhagwan/fzf-lua/blob/main/lua/fzf-lua/utils.lua
M.ansi_codes = {}
M.ansi_escseq = {
  -- the "\x1b" esc sequence causes issues
  -- with older Lua versions
  -- clear    = "\x1b[0m",
  clear = "[0m",
  bold = "[1m",
  italic = "[3m",
  underline = "[4m",
  black = "[0;30m",
  red = "[0;31m",
  green = "[0;32m",
  yellow = "[0;33m",
  blue = "[0;34m",
  magenta = "[0;35m",
  cyan = "[0;36m",
  white = "[0;37m",
  grey = "[0;90m",
  dark_grey = "[0;97m",
}
for color, escseq in pairs(M.ansi_escseq) do
  M.ansi_codes[color] = function(string)
    if string == nil or #string == 0 then return "" end
    if not escseq or #escseq == 0 then return string end
    return escseq .. string .. M.ansi_escseq.clear
  end
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
M.nbsp = "\xe2\x80\x82" -- "\u{2002}"

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
  if i == nil then
    return nil
  else
    return i - 1
  end
end

function M.iter_to_table(iter)
  local tbl = {}
  for v in iter do
    table.insert(tbl, v)
  end
  return tbl
end

function M.get_visual_selection()
  local start_pos, end_pos
  local mode = vim.api.nvim_get_mode().mode
  if mode ~= "v" then
    start_pos = vim.fn.getpos("'<")
    end_pos = vim.fn.getpos("'>")
  else
    local selection_anchor = vim.fn.getpos("v")
    local cursor_pos = vim.fn.getpos(".")
    if
      cursor_pos[2] > selection_anchor[2]
      or cursor_pos[3] > selection_anchor[3]
    then
      start_pos = selection_anchor
      end_pos = cursor_pos
    else
      start_pos = cursor_pos
      end_pos = selection_anchor
    end
  end
  vim.notify(start_pos)
  vim.notify(end_pos)
  local lines = vim.fn.getline(start_pos[2], end_pos[2])
  if #lines == 0 then return "" end
  -- Caution: must trim off end first because trim off start will affect the pos
  lines[#lines] = string.sub(lines[#lines], 0, end_pos[3]) -- Trim off end
  lines[1] = string.sub(lines[1], start_pos[3], string.len(lines[1])) -- Trim off start
  return table.concat(lines, "")
end

M.is_array = function(t) return #t > 0 and t[1] ~= nil end

M.reduce = function(list, fn, init)
  local acc = init
  if M.is_array(list) then
    for i, v in ipairs(list) do
      if 1 == i and init == nil then
        acc = v
      else
        acc = fn(acc, i, v)
      end
    end
  else
    for k, v in pairs(list) do
      if init == nil then
        acc = v
      else
        acc = fn(acc, k, v)
      end
    end
  end
  return acc
end

M.sum = function(list)
  return M.reduce(list, function(acc, _, v) return acc + v end, 0)
end

M.filter = function(list, fn)
  local new_list = {}
  for _, v in ipairs(list) do
    if fn(v) then table.insert(new_list, v) end
  end
  return new_list
end

M.pad = function(str, length) return string.format("%-" .. length .. "s", str) end

M.reverse = function(list)
  local reversed = {}
  for i = #list, 1, -1 do
    table.insert(reversed, list[i])
  end
  return reversed
end

M.join_first_two_elements = function(list, join_fn)
  if #list < 2 then return list end

  local first = table.remove(list, 1)
  local second = table.remove(list, 1)
  table.insert(list, 1, join_fn(first, second))
  return list
end

M.find = function(list, fn)
  for i, v in ipairs(list) do
    if fn(v) then return v, i end
  end
  return nil
end

-- Sort in place
M.sort_filepaths = function(list, fn)
  table.sort(list, function(e1, e2)
    local a = fn(e1)
    local b = fn(e2)

    local a_is_in_dir = string.find(a, "/") ~= nil
    local b_is_in_dir = string.find(b, "/") ~= nil

    if a_is_in_dir == b_is_in_dir then
      return a:lower() < b:lower()
    else
      return a_is_in_dir
    end
  end)
end

-- Join l2 into l1 in place
M.list_join = function(l1, l2)
  for _, v in ipairs(l2) do
    table.insert(l1, v)
  end
end

M.split_string_n = function(str, count, sep, opts)
  sep = sep or "%s+"
  opts = vim.tbl_extend(
    "force",
    { include_remaining = true, trimempty = true },
    opts or {}
  )
  local result = {}
  local remaining = str

  if false then
    -- Lua doesn't support multi-char-negative-lookahead
    while count > 0 do
      -- .- means match as short as possible
      -- local match = string.match(remaining, "^(.-[(%s%s*)\n])")
      local match, whitespace =
        string.match(remaining, "([^" .. sep .. "]+)(" .. sep .. ")")
      if not match then return nil end
      remaining = remaining:sub(#match + #whitespace + 1)
      table.insert(result, match)
      count = count - 1
    end

    if opts.include_remaining then table.insert(result, remaining) end
  end

  str = string.gsub(str, sep, M.nbsp, count)
  result = vim.split(str, M.nbsp, { trimempty = opts.trimempty })
  if not #result == count + 1 then return nil end
  if not opts.include_remaining then table.remove(result, #result) end
  return result
end

M.in_list = function(value, list)
  for _, v in ipairs(list) do
    if v == value then return true end
  end
  return false
end

M.keys = function(tbl)
  local keys = {}
  for k, _ in pairs(tbl) do
    table.insert(keys, k)
  end
  return keys
end

M.heredoc = function(str, opts)
  opts = vim.tbl_extend("force", { pipe_to = nil }, opts or {})
  local pipe_to = opts.pipe_to

  return string.format(
    [[cat <<"EOF"%s
%s
EOF
    ]],
    pipe_to and " | " .. pipe_to or "",
    str
  )
end

return M
