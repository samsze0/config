-- Tweak from: https://github.com/fgheng/winbar.nvim/tree/main

local M = {}

local config = {
  exclude_filetype = {
    "help",
    "fzf",
    "lf",
  },
}

local function isempty(s) return s == nil or s == "" end

local section_file = function()
  local hl_winbar_path = "WinBarPath"
  local hl_winbar_file = "WinBarFile"
  local separator = ">"

  local file_path = vim.fn.expand("%:~:.:h")
  local filename = vim.fn.expand("%:t")
  local value = ""
  local file_icon = ""

  file_path = file_path:gsub("^%.", "")
  file_path = file_path:gsub("^%/", "")

  if not isempty(filename) then
    value = " "
    local file_path_list = {}
    local _ = string.gsub(file_path, "[^/]+", function(w) table.insert(file_path_list, w) end)

    for i = 1, #file_path_list do
      value = value
        .. "%#"
        .. hl_winbar_path
        .. "#"
        .. file_path_list[i]
        .. " "
        .. separator
        .. " %*"
    end
    value = value .. file_icon
    value = value .. "%#" .. hl_winbar_file .. "#" .. filename .. "%*"
  end

  return value
end

local excludes = function()
  if vim.tbl_contains(config.exclude_filetype, vim.bo.filetype) then
    vim.opt_local.winbar = nil
    return true
  end

  return false
end

local pcall_section = function(section, name)
  local ok, value = pcall(section)
  if not ok then
    vim.error("Failed to render section:", name)
    return
  end

  return value
end

M.show_winbar = function()
  if excludes() then return end

  local ok, _ =
    pcall(vim.api.nvim_set_option_value, "winbar", pcall_section(section_file), { scope = "local" })
  if not ok then
    vim.error("Failed to set winbar")
    return
  end
end

function M.setup()
  vim.api.nvim_create_autocmd({
    "DirChanged",
    "CursorMoved",
    "BufWinEnter",
    "BufFilePost",
    "InsertEnter",
    "BufWritePost",
  }, {
    callback = function() M.show_winbar() end,
  })
end

return M
