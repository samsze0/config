-- Tweak from:
-- https://github.com/echasnovski/mini.statusline/blob/main/lua/mini/statusline.lua

local utils = require("utils")

local config = {
  padding = "  ",
  margin = " ",
  default_hl = "StatusLine",
  truncate_width = 5000, -- Never enter truncate mode
  diagnostic_levels = {
    {
      id = vim.diagnostic.severity.ERROR,
      sign = "E",
      hl = "StatusLineDiagnosticError",
    },
    {
      id = vim.diagnostic.severity.WARN,
      sign = "W",
      hl = "StatusLineDiagnosticWarn",
    },
    {
      id = vim.diagnostic.severity.INFO,
      sign = "I",
      hl = "StatusLineDiagnosticInfo",
    },
    {
      id = vim.diagnostic.severity.HINT,
      sign = "H",
      hl = "StatusLineDiagnosticHint",
    },
  },
}

local has_error = false

local M = {}

local function hl(hl_group, text)
  return string.format("%%#%s#%s%%#%s#", hl_group, text, config.default_hl) -- Escaping % with %
end

local function is_normal_buffer()
  -- For more information see ":h buftype"
  return vim.bo.buftype == ""
end

local function get_diagnostic_count(id)
  return #vim.diagnostic.get(0, { severity = id })
end

M.setup = function()
  _G.Statusline = M

  local augroup = vim.api.nvim_create_augroup("Statusline", {})

  local au = function(event, pattern, callback, desc)
    vim.api.nvim_create_autocmd(
      event,
      { group = augroup, pattern = pattern, callback = callback, desc = desc }
    )
  end

  local set_active = function()
    vim.wo.statusline = "%!v:lua.Statusline.active()"
  end
  au({ "WinEnter", "BufEnter" }, "*", set_active, "Set active statusline")

  local set_inactive = function()
    vim.wo.statusline = "%!v:lua.Statusline.inactive()"
  end
  au({ "WinLeave", "BufLeave" }, "*", set_inactive, "Set inactive statusline")

  -- :h statusline
  vim.g.qf_disable_statusline = 1 -- Disable built-in statusline in Quickfix window
  vim.opt.laststatus = 2 -- 3 = global; 2 = always ; 1 = at least 2 windows ; 0 = never
end

local pcall_section = function(section, name)
  local ok, val = pcall(section)
  if ok then
    return val
  else
    vim.error("Fail to render section:", name)
    has_error = true
    return ""
  end
end

M.active = function()
  if has_error then return hl("StatusLineDiagnosticError", "X") end

  return config.margin
    .. table.concat({
      pcall_section(M.section_filename, "filename"),
      pcall_section(M.section_diagnostics, "diagnostics"),
      pcall_section(M.section_git, "git"),
      pcall_section(M.section_copilot, "copilot"),
      "%=",
      pcall_section(M.section_fileinfo, "fileinfo"),
    }, config.padding)
    .. config.margin
end

M.inactive = function()
  if has_error then return hl("StatusLineDiagnosticError", "X") end

  return config.margin
    .. pcall_section(M.section_filename, "filename")
    .. config.margin
end

M.is_truncated = function()
  local cur_width = vim.o.laststatus == 3 and vim.o.columns
    or vim.api.nvim_win_get_width(0)
  return cur_width > config.truncate_width
end

M.section_git = function()
  local gitsigns_status = vim.b.gitsigns_status_dict
    or {
      added = 0,
      changed = 0,
      removed = 0,
    }

  if not is_normal_buffer() then return "" end

  local head_ref = vim.b.gitsigns_head or "-"
  local icon = ""

  if head_ref == "-" or head_ref == "" then return "" end

  local val = string.format("%s %s", icon, head_ref)
  if (gitsigns_status.added or 0) > 0 then
    val = val
      .. hl(
        "StatusLineDiagnosticInfo",
        string.format(" +%s", gitsigns_status.added)
      )
  end
  if (gitsigns_status.changed or 0) > 0 then
    val = val
      .. hl(
        "StatusLineDiagnosticWarn",
        string.format(" ~%s", gitsigns_status.changed)
      )
  end
  if (gitsigns_status.removed or 0) > 0 then
    val = val
      .. hl(
        "StatusLineDiagnosticError",
        string.format(" -%s", gitsigns_status.removed)
      )
  end
  return val
end

M.section_diagnostics = function()
  local hasnt_attached_client = next(vim.lsp.get_active_clients()) == nil
  if M.is_truncated() or not is_normal_buffer() or hasnt_attached_client then
    return ""
  end

  local t = {}
  for _, level in ipairs(config.diagnostic_levels) do
    local n = get_diagnostic_count(level.id)
    if n > 0 then
      table.insert(t, hl(level.hl, string.format("%s%s", level.sign, n)))
    end
  end

  local icon = ""
  if vim.tbl_count(t) == 0 then return ("%s -"):format(icon) end
  return string.format("%s%s", icon, table.concat(t, " "))
end

M.section_filename = function()
  if vim.bo.buftype == "terminal" then
    return " %t"
  else
    -- See :h statusline for all available fields
    local buf = vim.api.nvim_get_current_buf()
    local modified = vim.bo.modified
    local readonly = vim.bo.readonly
    return "%f" .. (modified and "  " or "") .. (readonly and "  " or "")
  end
end

M.section_fileinfo = function()
  local filetype = vim.bo.filetype

  if (filetype == "") or not is_normal_buffer() then return "" end

  if M.is_truncated() then return filetype end

  local encoding = vim.bo.fileencoding or vim.bo.encoding
  local format = vim.bo.fileformat

  return hl(
    "StatusLineMuted",
    string.format("%s  %s  %s", filetype, encoding, format)
  )
end

M.section_copilot = function()
  if (vim.bo.filetype == "") or not is_normal_buffer() then return "" end

  local copilot = require("copilot.client")
  if next(copilot) == nil then return hl("StatusLineMuted", " ") end

  local ok, val = pcall(function()
    if
      copilot.is_disabled()
      or not copilot.buf_is_attached(vim.api.nvim_get_current_buf())
    then
      return hl("StatusLineMuted", " ")
    else
      return hl(config.default_hl, " ")
    end
  end)

  if ok then return val end
  return hl("StatusLineDiagnosticWarn", " ")
end

return M
