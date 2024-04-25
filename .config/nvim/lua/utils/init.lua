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

-- Split string using lua regular expression
-- See also: split_string_n
--
---@param inputstr string
---@param sep? string
---@return string[]
M.split_string = function(inputstr, sep)
  if sep == nil then sep = "%s" end
  local t = {}
  for str in inputstr:gmatch("([^" .. sep .. "]+)") do
    table.insert(t, str)
  end
  return t
end

---@param buf_lines string[]
---@param opts? { filetype?: string, buf_listed?: boolean, open_in_current_tab?: boolean }
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

-- Remove ansi escape sequences
--
---@param str string
---@return string
function M.strip_ansi_codes(str)
  local x, count = str:gsub("\x1b%[[%d:;]*[mK]", "")
  return x or str
end

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
---@param opts? { include_remaining?: boolean, discard_empty?: boolean, trim?: boolean, plain?: boolean }
---@return string[]
M.split_string_n = function(str, count, sep, opts)
  sep = sep or "%s+"
  opts = vim.tbl_extend(
    "force",
    { include_remaining = true, discard_empty = true },
    opts or {}
  )
  local result = {}

  -- TODO: handle error gracefully

  -- Lua doesn't support multi-char-negative-lookahead
  -- So we cannot just use Lua regex (because it won't support multi-char sep)

  -- We perform split by first replacing all occurrences of sep with nbsp,
  -- then we `vim.split` by nbsp

  str = str:gsub(sep, M.nbsp, count)
  result = vim.split(
    str,
    M.nbsp,
    { trimempty = opts.discard_empty, plain = opts.plain }
  )
  if count ~= nil and #result ~= count + 1 then
    error(M.str_fmt("Expected", count + 1, "parts, but got", result))
  end
  if not opts.include_remaining then table.remove(result, #result) end

  if opts.trim then
    for i, v in ipairs(result) do
      result[i] = vim.trim(v)
    end
  end

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
---@generic U : any
---@param tbl table<any, T> | T[]
---@param accessor fun(k: any, v: T): U
---@param opts? { is_array?: boolean }
---@return U
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

-- Format arguments into a string
--
---@vararg any
---@return string
M.str_fmt = function(...)
  local args = { ... }
  local tbl = M.map(args, function(_, arg)
    if type(arg) ~= "string" then
      return vim.inspect(arg)
    else
      return arg
    end
  end)
  return table.concat(tbl, " ")
end

-- vim.system wrapper
--
---@param cmd string
---@param opts? { error_msg_title?: string, input?: any, on_error?: fun(err: string): nil }
---@return string
M.system = function(cmd, opts)
  opts = M.opts_extend({
    error_msg_title = "Failed to execute command " .. cmd,
  }, opts)

  local result = vim.fn.system(cmd, opts.input)
  if vim.v.shell_error ~= 0 then
    if opts.on_error then opts.on_error(result) end
    error(M.str_fmt(opts.error_msg_title, result))
  end

  return result
end

-- vim.system wrapper
--
---@param cmd string
---@param opts? { input?: any, on_error?: fun(err: string): nil }
---@return string?
M.system_safe = function(cmd, opts)
  opts = opts or {}

  local result = vim.fn.system(cmd, opts.input)
  if vim.v.shell_error ~= 0 then
    if opts.on_error then opts.on_error(result) end
    return nil
  end

  return result
end

-- vim.systemlist wrapper
--
---@alias UtilsSystemlistOptions { trim?: boolean, error_msg_title?: string, input?: any, keepempty?: boolean, on_error?: fun(err: string): nil }
---@param cmd string
---@param opts? UtilsSystemlistOptions
---@return string[]
M.systemlist = function(cmd, opts)
  opts = M.opts_extend(
    { error_msg_title = "Failed to execute command " .. cmd },
    opts
  )
  ---@cast opts UtilsSystemlistOptions

  local result = vim.fn.systemlist(cmd, opts.input, opts.keepempty)
  if vim.v.shell_error ~= 0 then
    local err_msg = table.concat(result, "\n")
    if opts.on_error then opts.on_error(err_msg) end
    error(M.str_fmt(opts.error_msg_title, err_msg))
  end

  if opts.trim then
    for i, v in ipairs(result) do
      result[i] = vim.trim(v)
    end
    if not opts.keepempty then
      result = M.filter(result, function(_, v) return v ~= "" end)
    end
  end

  return result
end

-- vim.systemlist wrapper
--
---@param cmd string
---@param opts? { input?: any, keepempty?: boolean, on_error?: fun(err: string): nil }
---@return string[]?
M.systemlist_safe = function(cmd, opts)
  opts = opts or {}

  local result = vim.fn.systemlist(cmd, opts.input, opts.keepempty)
  if vim.v.shell_error ~= 0 then
    local err_msg = table.concat(result, "\n")
    if opts.on_error then opts.on_error(err_msg) end
    return nil
  end

  return result
end

-- Switch statement/expression
--
---@generic T : any
---@generic U : any
---@param val T
---@param switches table<T, U>
---@param default U?
---@return U
M.switch = function(val, switches, default)
  for case, expr in pairs(switches) do
    if val == case then return expr end
  end

  if not default then error("No default case provided") end
  return default
end

-- Switch with function cases
--
---@generic T : any
---@generic U : any
---@param val T
---@param switches table<T, fun(val: T): U>
---@param default (fun(val: T): U)?
---@return U
M.switch_with_func = function(val, switches, default)
  for case, expr in pairs(switches) do
    if val == case then return expr(val) end
  end

  if not default then error("No default case provided") end
  return default(val)
end

-- Slice an array
--
---@generic T : any
---@param list T[]
---@param first? number
---@param last? number
---@param step? number
---@return T[]
M.slice = function(list, first, last, step)
  local sliced = {}

  for i = first or 1, last or #list, step or 1 do
    sliced[#sliced + 1] = list[i]
  end

  return sliced
end

---@param target table
---@param k any key
---@param v any value
---@param mode "force" | "keep" | "error"
M._tbl_extend = function(target, k, v, mode)
  if mode == "keep" then
    if target[k] == nil then target[k] = v end
  elseif mode == "force" then
    target[k] = v
  else -- opts.mode == "error"
    if target[k] ~= nil then error(("Key %s already exists"):format(k)) end
    target[k] = v
  end
end

-- Same as `vim.tbl_extend` but does not mutate the input args
--
---@alias UtilsTblExtendOpts { mode: "force" | "keep" | "error" }
---@param opts UtilsTblExtendOpts
---@vararg table
---@return table
M.tbl_extend = function(opts, ...)
  local result = {}
  local args = { ... }
  for _, tbl in ipairs(args) do
    for k, v in pairs(tbl) do
      M._tbl_extend(result, k, v, opts.mode)
    end
  end

  return result
end

-- Same as `vim.tbl_deep_extend` but does not mutate the input args
-- Careful with classes as they will be treated as regular tables, unless `__is_class` is `true`
--
---@alias UtilsTblDeepExtendOpts { mode: "force" | "keep" | "error" }
---@param opts UtilsTblDeepExtendOpts
---@vararg table
---@return table
M.tbl_deep_extend = function(opts, ...)
  local result = {}
  local args = { ... }
  for _, tbl in ipairs(args) do
    M._tbl_deep_extend(result, tbl, opts.mode)
  end

  return result
end

---@param target table
---@param source table
---@param mode "force" | "keep" | "error"
M._tbl_deep_extend = function(target, source, mode)
  for k, v in pairs(source) do
    if type(v) ~= "table" then
      M._tbl_extend(target, k, v, mode)
    elseif getmetatable(v) ~= nil then -- If table is a class instance
      M._tbl_extend(target, k, v, mode)
    elseif v["__is_class"] == true or v["__is_module"] == true then
      M._tbl_extend(target, k, v, mode)
    elseif M.is_array(v) then
      M._tbl_extend(target, k, v, mode)
    else
      if target[k] == nil then target[k] = {} end
      M._tbl_deep_extend(target[k], v, mode)
    end
  end
end

-- Extension of `utils.tbl_extend`
--
---@vararg table?
---@return table
M.opts_extend = function(...)
  local args = { ... }
  return M.tbl_extend(
    { mode = "force" },
    unpack(M.map(args, function(_, tbl) return tbl or {} end))
  )
end

-- Extension of `utils.tbl_deep_extend`
--
---@vararg table?
---@return table
M.opts_deep_extend = function(...)
  local args = { ... }
  return M.tbl_deep_extend(
    { mode = "force" },
    unpack(M.map(args, function(_, tbl) return tbl or {} end))
  )
end

---@vararg number buffers
M.diff_bufs = function(...)
  local bufs = { ... }
  for _, buf in ipairs(bufs) do
    vim.api.nvim_buf_call(buf, function() vim.cmd("diffthis") end)
  end
end

-- Identity function
M.identity_func = function(...) return ... end

-- Convert shell opts table to string representation
--
---@alias UtilsShellOpts table<string, string | boolean | (string | boolean)[]>
---@param shell_opts UtilsShellOpts
---@return string
M.shell_opts_tostring = function(shell_opts)
  local result = {}
  for k, v in pairs(shell_opts) do
    if type(v) == "string" then
      if #v > 0 then
        table.insert(result, k .. "=" .. v)
      else
        table.insert(result, k)
      end
    elseif type(v) == "table" then
      if not M.is_array(v) then error("Unexpected type") end
      for _, val in ipairs(v) do
        table.insert(result, k .. "=" .. val)
      end
    elseif type(v) == "boolean" then
      if v then table.insert(result, k) end
    else
      error("Unexpected type")
    end
  end
  return table.concat(result, " ")
end

-- Join tbl/array as string with custom fn
--
---@generic T : any
---@generic U : any
---@param tbl table<any, T> | T[]
---@param fn fun(k: any, v: T): U
---@param delimiter? string
---@return string
M.join = function(tbl, fn, delimiter)
  delimiter = delimiter or " "

  return M.reduce(tbl, function(acc, i, v)
    if acc == "" then
      return fn(i, v)
    else
      return acc .. delimiter .. fn(i, v)
    end
  end, "")
end

-- Print and return value
--
---@generic T : any
---@param x T
---@return T
M.debug = function(x)
  print(vim.inspect(x))
  return x
end

-- Truncate or pad a string to a certain width
--
---@param str string
---@param width number The width to truncate or pad to
---@param opts? { pad_character?: string, elipses?: string }
---@return string
M.trunc_or_pad_to_width = function(str, width, opts)
  opts = M.opts_extend({
    pad_character = " ",
    elipses = "...",
  }, opts)

  if width < 0 then error("Width must be at least 0") end

  if #str > width then
    return str:sub(1, width - #opts.elipses) .. opts.elipses
  else
    return str .. opts.pad_character:rep(width - #str)
  end
end

-- Extend a list
--
---@generic T : any
---@vararg T[]
---@return T[]
M.list_extend = function(...)
  local args = { ... }
  local result = {}
  for _, list in ipairs(args) do
    if not M.is_array(list) then error("Expected array") end

    for _, v in ipairs(list) do
      table.insert(result, v)
    end
  end
  return result
end

return M
