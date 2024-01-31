local utils = require("utils")
local color_utils = require("utils.colors")

local HIGHLIGHT_NAME_PREFIX = "terminal-filetype"
local namespace = vim.api.nvim_create_namespace("terminal-filetype")
local autocmd_group =
  vim.api.nvim_create_augroup("terminal-filetype", { clear = true })
local debug = true

local M = {}

---@alias attributes { gui?: string, guifg?: string, guibg?: string, guisp?: string }

-- Process a color code and mutate the existing attributes
--
---@param rgb_color_table table<number, string>
---@param code number | string
---@param current_attributes attributes
---@return attributes
local function process_color(rgb_color_table, code, current_attributes)
  current_attributes = current_attributes or {}

  ---@type number
  local c = type(code) ~= "number" and tonumber(code) or code ---@diagnostic disable-line: assign-type-mismatch
  if c == nil then error("Invalid code: " .. vim.inspect(c)) end

  if debug then vim.info("Parsing color code", current_attributes, code) end

  if c >= 30 and c <= 37 then
    -- Foreground color
    current_attributes.guifg = rgb_color_table[c - 30]
  elseif c >= 40 and c <= 47 then
    -- Background color
    current_attributes.guibg = rgb_color_table[c - 40]
  elseif c >= 90 and c <= 97 then
    -- Bright colors. Foreground
    current_attributes.guifg = rgb_color_table[c - 90 + 8]
  elseif c >= 100 and c <= 107 then
    -- Bright colors. Background
    current_attributes.guibg = rgb_color_table[c - 100 + 8]
  elseif c == 22 then
    current_attributes.gui = "NONE"
  elseif c == 39 then
    -- Reset to normal color for foreground
    current_attributes.guifg = "fg"
  elseif c == 49 then
    -- Reset to normal color for background
    current_attributes.guibg = "bg"
  elseif c == 1 then
    -- Bold
    current_attributes.gui = "bold"
  elseif c == 0 then
    -- RESET
    current_attributes = {}
  end

  return current_attributes
end

---@param attributes attributes
---@return string
local function make_unique_hlgroup_name(attributes)
  local result = { HIGHLIGHT_NAME_PREFIX }
  if attributes.gui then
    table.insert(result, "g")
    table.insert(result, attributes.gui)
  end
  if attributes.guifg then
    table.insert(result, "gfg")
    table.insert(result, (attributes.guifg:gsub("^#", "")))
  end
  if attributes.guibg then
    table.insert(result, "gbg")
    table.insert(result, (attributes.guibg:gsub("^#", "")))
  end
  if attributes.guisp then
    table.insert(result, "gsp")
    table.insert(result, (attributes.guisp:gsub("^#", "")))
  end
  return table.concat(result, "_")
end

local highlight_cache = {}

local function table_is_empty(t) return next(t) == nil end

local function create_highlight_group(attributes)
  if table_is_empty(attributes) then return "Normal" end
  local hl_group = make_unique_hlgroup_name(attributes)

  local val = {}
  val.fg = attributes.guifg
  val.bg = attributes.guibg
  val.sp = attributes.guisp
  if attributes.gui then
    for x in string.gmatch(attributes.gui, "([^,]+)") do
      if x ~= "none" then val[x] = true end
    end
  end

  if not highlight_cache[hl_group] then
    vim.api.nvim_set_hl(0, hl_group, val)
    highlight_cache[hl_group] = true
  end
  return hl_group
end

local function create_highlight(
  buf,
  current_attributes,
  region_line_start,
  region_byte_start,
  region_line_end,
  region_byte_end
)
  if debug then
    vim.info("Creating highlight", {
      buf = buf,
      current_attributes = current_attributes,
      region_line_start = region_line_start,
      region_byte_start = region_byte_start,
      region_line_end = region_line_end,
      region_byte_end = region_byte_end,
    })
  end

  local highlight_name = create_highlight_group(current_attributes)
  if region_line_start == region_line_end then
    vim.api.nvim_buf_add_highlight(
      buf,
      namespace,
      highlight_name,
      region_line_start,
      region_byte_start,
      region_byte_end
    )
  else
    vim.api.nvim_buf_add_highlight(
      buf,
      namespace,
      highlight_name,
      region_line_start,
      region_byte_start,
      -1
    )
    for linenum = region_line_start + 1, region_line_end - 1 do
      vim.api.nvim_buf_add_highlight(
        buf,
        namespace,
        highlight_name,
        linenum,
        0,
        -1
      )
    end
    vim.api.nvim_buf_add_highlight(
      buf,
      namespace,
      highlight_name,
      region_line_end,
      0,
      region_byte_end
    )
  end
end

-- Process a code and mutate the existing attributes
--
---@param rgb_color_table table<number, string>
---@param code string
---@param current_attributes attributes
---@return attributes | nil
local function process_code(rgb_color_table, code, current_attributes)
  if debug then
    vim.info(
      "Parsing code",
      { code = code, current_attributes = current_attributes }
    )
  end

  -- CSI m is equivalent to CSI 0 m, which is Reset, which means null the attributes
  if #code == 0 then return {} end

  local find_start = 1
  while find_start <= #code do
    local match_start, match_end = code:find(";", find_start, true)
    local segment = code:sub(find_start, match_start and match_start - 1)
    if not match_start then
      process_color(rgb_color_table, segment, current_attributes)
    end

    if segment == "38" or segment == "48" then
      local is_foreground = segment == "38"
      -- Verify the segment start. The only possibilities are 2, 5
      segment = code:sub(find_start + #"38", find_start + #"38;2;" - 1)
      if segment == ";5;" or segment == ":5:" then
        local color_segment = code:sub(find_start + #"38;2;"):match("^(%d+)")
        if not color_segment then
          vim.error("Invalid color code: " .. code:sub(find_start))
          return
        end
        local color_code = tonumber(color_segment)
        find_start = find_start + #"38;2;" + #color_segment + 1
        if not color_code or color_code > 255 then
          vim.error("Invalid color code: " .. color_code)
          return
        elseif is_foreground then
          current_attributes.guifg = rgb_color_table[color_code]
        else
          current_attributes.guibg = rgb_color_table[color_code]
        end
      elseif segment == ";2;" or segment == ":2:" then
        local separator = segment:sub(1, 1)
        local r, g, b, len = code:sub(find_start + #"38;2;"):match(
          "^(%d+)" .. separator .. "(%d+)" .. separator .. "(%d+)()"
        )
        if not r then
          vim.error("Invalid color code: " .. code:sub(find_start))
          return
        end
        r, g, b = tonumber(r), tonumber(g), tonumber(b)
        find_start = find_start + #"38;2;" + len
        if not r or not g or not b or r > 255 or g > 255 or b > 255 then
          vim.error("Invalid color code: " .. r .. ", " .. g .. ", " .. b)
          return
        else
          current_attributes[is_foreground and "guifg" or "guibg"] =
            color_utils.rgb_to_hex(r, g, b)
        end
      else
        vim.error("Invalid color code: " .. code:sub(find_start))
        return
      end
    else
      find_start = match_end + 1
      process_color(rgb_color_table, segment, current_attributes)
    end
  end

  return current_attributes
end

-- Apply highlight to the buffer
--
---@param buf number
---@param lines string[]
---@param rgb_color_table table<number, string>
---@return nil
local function highlight_buffer(buf, lines, rgb_color_table)
  if debug then
    vim.info("Highlighting buffer", { buf = buf, lines = lines })
  end

  local current_region_start, current_attributes = nil, {}
  for current_linenum, line in ipairs(lines) do
    current_linenum = current_linenum - 1
    for match_start, code, match_end in line:gmatch("()%[([%d;:]*)m()") do
      if current_region_start then
        create_highlight(
          buf,
          current_attributes,
          current_region_start[1],
          current_region_start[2],
          current_linenum,
          match_start
        )
      end
      current_region_start = { current_linenum, match_start }
      ---@diagnostic disable-next-line: cast-local-type
      current_attributes =
        process_code(rgb_color_table, code, current_attributes)
      if debug then vim.info("Parsed code") end
      if not current_attributes then return end
    end
  end
  if current_region_start then
    create_highlight(
      buf,
      current_attributes,
      current_region_start[1],
      current_region_start[2],
      #lines,
      -1
    )
  end
end

M.setup = function()
  local rgb_color_table = {}

  vim.api.nvim_create_autocmd({
    "FileType",
  }, {
    group = autocmd_group,
    callback = function(ctx)
      local buf = ctx.buf

      if vim.bo[buf].filetype ~= "terminal" then return end

      vim.api.nvim_buf_clear_namespace(buf, namespace, 0, -1)
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, true)
      highlight_buffer(buf, lines, rgb_color_table)

      vim.api.nvim_buf_attach(buf, false, {
        on_lines = function()
          vim.api.nvim_buf_clear_namespace(buf, namespace, 0, -1)
          local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, true)
          highlight_buffer(buf, lines, rgb_color_table)
        end,
      })
    end,
  })
end

return M
