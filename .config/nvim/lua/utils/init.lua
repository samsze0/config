local M = {}

---@generic T : any
---@generic U : any
---@param tbl table<any, T> | T[]
---@param func fun(k: any, v: T): U
---@param opts? { skip_nil?: boolean, is_array?: boolean | nil }
---@return U[]
M.map = function(tbl, func, opts)
  opts = vim.tbl_extend("force", {
    skip_nil = true,
    is_array = nil, -- If nil, auto-detect if tbl is array
  }, opts or {})

  local new_tbl = {}
  if
    (opts.is_array ~= nil and opts.is_array)
    or (opts.is_array == nil and M.is_array(tbl))
  then
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

---@param buf_lines string[]
---@param opts { filetype?: string, buf_listed?: boolean, open_in_current_tab?: boolean }
---@return number buf_nr Buffer number
M.show_content_in_buffer = function(buf_lines, opts)
  opts = vim.tbl_deep_extend("keep", opts or {}, {
    filetype = "text", -- Better than "filetype detect"
    buf_listed = false,
    open_in_current_tab = false,
  })

  local buf_nr = vim.api.nvim_create_buf(opts.buf_listed, true)

  vim.api.nvim_buf_set_lines(buf_nr, 0, -1, false, buf_lines)
  vim.bo[buf_nr].filetype = opts.filetype
  if not opts.open_in_current_tab then vim.cmd("tabnew") end
  vim.api.nvim_set_current_buf(buf_nr)

  return buf_nr
end

---@generic T : any
---@param tbl table<any, T>
---@param elem T
---@return boolean
M.contains = function(tbl, elem)
  for i, v in ipairs(tbl) do
    if v == elem then return true end
  end
  return false
end

---@param opts { show_in_current_tab?: boolean, filetype?: string | nil, cursor_at?: number | nil }
---@vararg { filepath_or_content: string | string[], readonly?: boolean }
---@return integer[] buffers
M.show_diff = function(opts, ...)
  local entries = { ... }

  opts = vim.tbl_extend("force", {
    show_in_current_tab = false,
    filetype = nil, -- If nil, auto-detect
  }, opts or {})

  if not opts.show_in_current_tab then
    vim.api.nvim_command("tabnew")
  else
    vim.cmd("only") -- Close all other windows in current tab
  end

  local filetype = nil

  local buffers = {}
  for i, e in ipairs(entries) do
    if i > 1 then vim.cmd("vsplit") end

    if type(e.filepath_or_content) == "string" then
      vim.cmd(string.format("e %s", e.filepath_or_content))
      filetype = vim.bo.filetype
    else
      local content = e.filepath_or_content
      ---@cast content string[]
      local buf = M.show_content_in_buffer(content, {
        open_in_current_tab = true,
      })
      vim.bo[buf].readonly = e.readonly
    end
    table.insert(buffers, vim.api.nvim_get_current_buf())
    vim.cmd("diffthis")
  end

  if opts.filetype then filetype = opts.filetype end

  if filetype then
    for _, buf in ipairs(buffers) do
      vim.bo[buf].filetype = filetype
    end
  end

  -- Goto the window specified by `opts.window`
  if opts.cursor_at then
    for _ = 1, (#entries - opts.cursor_at) do
      vim.cmd("wincmd W")
    end
  end

  return buffers
end

-- Safely require a file by invoking "require" in protected mode
--
-- Module LS info can still be obtained by using the "@module" annotation
-- https://github.com/LuaLS/lua-language-server/wiki/Annotations
--
---@param module_name string
---@param on_error? fun(err: any): nil
M.safe_require = function(module_name, on_error)
  on_error = on_error
    or function(err)
      vim.error("Failed to load module:", module_name, "Err:", err)
    end
  local ok, module = xpcall(require, on_error, module_name)
  if not ok then
    -- Return nil if we try to index into the result of safe_require.
    -- We don't support indexing into multiple levels
    return setmetatable({}, {
      __index = function(_, key) return nil end,
    })
  end
  return module
end

-- Tweaked from:
-- https://github.com/ibhagwan/fzf-lua/blob/main/lua/fzf-lua/utils.lua
--
-- Remove escape sequences of the following formats:
-- 1. ^[[34m
-- 2. ^[[0;34m
-- 3. ^[[m
--
---@param str string
---@return string
function M.strip_ansi_coloring(str) return str:gsub("%[[%d;]-m", "")[1] end

-- Tweaked from:
-- https://github.com/ibhagwan/fzf-lua/blob/main/lua/fzf-lua/utils.lua
--
-- Decorate a string by wrapping it with ANSI escape sequences
--
---@alias ansi_color_fn fun(str: string): string
---@type { clear: ansi_color_fn, bold: ansi_color_fn, italic: ansi_color_fn, underline: ansi_color_fn, black: ansi_color_fn, red: ansi_color_fn, green: ansi_color_fn, yellow: ansi_color_fn, blue: ansi_color_fn, magenta: ansi_color_fn, cyan: ansi_color_fn, white: ansi_color_fn, grey: ansi_color_fn, dark_grey: ansi_color_fn }
M.ansi_codes = {}

-- Ansi escape sequences
--
-- the "\x1b" esc sequence causes issues
-- with older Lua versions
-- clear    = "\x1b[0m",
M.ansi_escseq = {
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
    if type(string) ~= "string" then
      error("Expected string, got " .. type(string))
    end

    if string:len() == 0 then return "" end
    return escseq .. string .. M.ansi_escseq.clear
  end
end

-- From:
-- https://github.com/ibhagwan/fzf-lua/blob/main/lua/fzf-lua/utils.lua
--
-- Sets an invisible unicode character as icon separator
-- the below was reached after many iterations, a short summary of everything
-- that was tried and why it failed:
--
-- nbsp, U+00a0: the original separator, fails with files that contain nbsp
-- nbsp + zero-width space (U+200b): works only with `sk` (`fzf` shows <200b>)
-- word joiner (U+2060): display works fine, messes up fuzzy search highlights
-- line separator (U+2028), paragraph separator (U+2029): created extra space
-- EN space (U+2002): seems to work well
--
-- For more unicode SPACE options see:
-- http://unicode-search.net/unicode-namesearch.pl?term=SPACE&.submit=Search
M.nbsp = "\xe2\x80\x82" -- "\u{2002}"

---@generic T : any
---@param iter fun(): T
---@return T[]
function M.iter_to_table(iter)
  local tbl = {}
  for v in iter do
    table.insert(tbl, v)
  end
  return tbl
end

---@return string
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
  local lines = vim.fn.getline(start_pos[2], end_pos[2])
  if #lines == 0 then return "" end
  -- Caution: must trim off end first because trim off start will affect the pos
  lines[#lines] = string.sub(lines[#lines], 0, end_pos[3]) -- Trim off end
  lines[1] = string.sub(lines[1], start_pos[3], string.len(lines[1])) -- Trim off start
  return table.concat(lines, "")
end

---@param t table<any, any> | any[]
---@return boolean
M.is_array = function(t) return #t > 0 and t[1] ~= nil end

---@generic T : any
---@generic U: any
---@param tbl table<any, T> | T[]
---@param fn fun(acc?: U, k: any, v: T): any
---@param opts? { is_array?: boolean | nil }
---param init? U
M.reduce = function(tbl, fn, init, opts)
  opts = vim.tbl_extend("force", {
    is_array = nil, -- If nil, auto-detect if tbl is array
  }, opts or {})

  local acc = init
  if
    (opts.is_array ~= nil and opts.is_array)
    or (opts.is_array == nil and M.is_array(tbl))
  then
    for i, v in ipairs(tbl) do
      acc = fn(acc, i, v)
    end
  else
    for k, v in pairs(tbl) do
      acc = fn(acc, k, v)
    end
  end
  return acc
end

---@generic T : any
---@generic V : any
---@param tbl table<any, T> | T[]
---@param accessor? fun(k: any, v: T): V
---@param opts? { is_array?: boolean | nil }
---@return V
M.sum = function(tbl, accessor, opts)
  opts = vim.tbl_extend("force", {
    is_array = nil, -- If nil, auto-detect if tbl is array
  }, opts or {})

  return M.reduce(
    tbl,
    function(acc, i, v)
      if not accessor then
        return acc + v
      else
        return acc + accessor(i, v)
      end
    end,
    0,
    {
      is_array = opts.is_array,
    }
  )
end

---@generic T : any
---@param tbl T
---@fn fun(k: any, v: any): boolean
---@param opts? { is_array?: boolean | nil }
---@return T
M.filter = function(tbl, fn, opts)
  opts = vim.tbl_extend("force", {
    is_array = nil, -- If nil, auto-detect if tbl is array
  }, opts or {})

  local result = {}
  if
    (opts.is_array ~= nil and opts.is_array)
    or (opts.is_array == nil and M.is_array(tbl))
  then
    for i, v in ipairs(tbl) do
      if fn(i, v) then table.insert(result, v) end
    end
  else
    for k, v in pairs(tbl) do
      if fn(k, v) then result[k] = v end
    end
  end
  return result
end

---@param str string
---@param length number
---@return string
M.pad_string = function(str, length)
  return string.format("%-" .. length .. "s", str)
end

---@generic T: any[]
---@param list T
---@return T
M.reverse = function(list)
  local reversed = {}
  for i = #list, 1, -1 do
    table.insert(reversed, list[i])
  end
  return reversed
end

---@generic T: any[]
---@param list T
---@param join_fn fun(a: any, b: any): any
---@param opts? { error_if_insufficient_length?: boolean }
---@return T
M.join_first_two_elements = function(list, join_fn, opts)
  opts = vim.tbl_extend(
    "force",
    { error_if_insufficient_length = false },
    opts or {}
  )

  if #list < 2 then
    if opts.error_if_insufficient_length then
      error("Insufficient length")
    else
      return list
    end
  end

  local first = table.remove(list, 1)
  local second = table.remove(list, 1)
  table.insert(list, 1, join_fn(first, second))
  return list
end

---@generic T : any
---@param tbl table<any, T> | T[]
---@param fn fun(k: any, v: T): boolean
---@param opts? { is_array?: boolean | nil }
---@return any, T | nil
M.find = function(tbl, fn, opts)
  opts = vim.tbl_extend("force", {
    is_array = nil, -- If nil, auto-detect if tbl is array
  }, opts or {})

  if
    (opts.is_array ~= nil and opts.is_array)
    or (opts.is_array == nil and M.is_array(tbl))
  then
    for i, v in ipairs(tbl) do
      if fn(i, v) then return i, v end
    end
  else
    for k, v in pairs(tbl) do
      if fn(k, v) then return k, v end
    end
  end
  return nil
end

---@param str string
---@param count? number
---@param sep? string
---@param opts? { include_remaining?: boolean, trimempty?: boolean }
---@return string[]
M.split_string_n = function(str, count, sep, opts)
  sep = sep or "%s+"
  opts = vim.tbl_extend(
    "force",
    { include_remaining = true, trimempty = true },
    opts or {}
  )
  local result = {}

  -- Lua doesn't support multi-char-negative-lookahead
  -- So we cannot just use Lua regex (because it won't support multi-char sep)

  -- We perform split by first replacing all occurrences of sep with nbsp,
  -- then we `vim.split` by nbsp

  str = string.gsub(str, sep, M.nbsp, count)
  result = vim.split(str, M.nbsp, { trimempty = opts.trimempty })
  if count ~= nil and #result ~= count + 1 then error("Unexpected") end
  if not opts.include_remaining then table.remove(result, #result) end
  return result
end

---@generic T : any
---@param tbl table<T, any> | T[]
---@return T[]
M.keys = function(tbl)
  local keys = {}
  for k, _ in pairs(tbl) do
    table.insert(keys, k)
  end
  return keys
end

---@generic T : any
---@param tbl table<any, T> | T[]
---@param accessor fun(k: any, v: T): any
---@param opts? { is_array?: boolean }
---@return T
M.max = function(tbl, accessor, opts)
  opts = vim.tbl_extend("force", {
    is_array = nil, -- If nil, auto-detect if tbl is array
  }, opts or {})

  local max = nil
  if
    (opts.is_array ~= nil and opts.is_array)
    or (opts.is_array == nil and M.is_array(tbl))
  then
    for i, v in ipairs(tbl) do
      local value = accessor(i, v)
      if max == nil or value > max then max = value end
    end
  else
    for k, v in pairs(tbl) do
      local value = accessor(k, v)
      if max == nil or value > max then max = value end
    end
  end

  return max
end

-- Sort a table
--
-- If the table is an array, the sorted array is returned.
-- If the table is a map, the sorted keys are returned.
-- The original table is not modified.
--
---@generic T : any
---@param tbl table<any, T> | T[]
---@param compare_fn fun(a: T, b: T): boolean
---@param opts? { is_array?: boolean }
---@return any[] | T[]
M.sort = function(tbl, compare_fn, opts)
  opts = vim.tbl_extend("force", {
    is_array = nil, -- If nil, auto-detect if tbl is array
  }, opts or {})

  local keys = M.keys(tbl)
  table.sort(keys, function(a, b) return compare_fn(tbl[a], tbl[b]) end)
  if
    (opts.is_array ~= nil and opts.is_array)
    or (opts.is_array == nil and M.is_array(tbl))
  then
    local sorted = {}
    for _, k in ipairs(keys) do
      table.insert(sorted, tbl[k])
    end
    return sorted
  else
    return keys
  end
end

---@param paths string[]
---@param transformer? fun(path: string): string
---@return string[]
M.sort_by_files = function(paths, transformer)
  if not transformer then transformer = function(path) return path end end

  return M.sort(paths, function(a, b)
    a = transformer(a)
    b = transformer(b)

    local a_is_in_dir = string.find(a, "/") ~= nil
    local b_is_in_dir = string.find(b, "/") ~= nil

    if a_is_in_dir == b_is_in_dir then
      return a:lower() < b:lower()
    else
      return a_is_in_dir
    end
  end)
end

local random = math.random

-- Generate a UUID
--
---@return string
M.uuid = function()
  local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
  local result = string.gsub(template, "[xy]", function(c)
    local v = (c == "x") and random(0, 0xf) or random(8, 0xb)
    return string.format("%x", v)
  end)
  return result
end

return M
