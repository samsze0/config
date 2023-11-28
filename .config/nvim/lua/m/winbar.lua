-- Tweak from: https://github.com/fgheng/winbar.nvim/tree/main

local M = {}

local opts = {
  colors = {
    path = '',
    file_name = '',
    symbols = '',
  },

  icons = {
    seperator = '>',
  },

  exclude_filetype = {
    'help',
    'fzf',
  }
}

local function isempty(s)
  return s == nil or s == ''
end

local hl_winbar_path = 'WinBarPath'
local hl_winbar_file = 'WinBarFile'

local winbar_file = function()
  local file_path = vim.fn.expand('%:~:.:h')
  local filename = vim.fn.expand('%:t')
  local value = ''
  local file_icon = ''

  file_path = file_path:gsub('^%.', '')
  file_path = file_path:gsub('^%/', '')

  if not isempty(filename) then
    value = ' '
    local file_path_list = {}
    local _ = string.gsub(file_path, '[^/]+', function(w)
      table.insert(file_path_list, w)
    end)

    for i = 1, #file_path_list do
      value = value .. '%#' .. hl_winbar_path .. '#' .. file_path_list[i] .. ' ' .. opts.icons.seperator .. ' %*'
    end
    value = value .. file_icon
    value = value .. '%#' .. hl_winbar_file .. '#' .. filename .. '%*'
  end

  return value
end

local excludes = function()
  if vim.tbl_contains(opts.exclude_filetype, vim.bo.filetype) then
    vim.opt_local.winbar = nil
    return true
  end

  return false
end

M.init = function()
  if isempty(opts.colors.path) then
    hl_winbar_path = 'NonText'
  else
    vim.api.nvim_set_hl(0, hl_winbar_path, { fg = opts.colors.path })
  end

  if isempty(opts.colors.file_name) then
    hl_winbar_file = 'NonText'
  else
    vim.api.nvim_set_hl(0, hl_winbar_file, { fg = opts.colors.file_name })
  end
end

M.show_winbar = function()
  if excludes() then
    return
  end

  local value = winbar_file()

  local status_ok, _ = pcall(vim.api.nvim_set_option_value, 'winbar', value, { scope = 'local' })
  if not status_ok then
    return
  end
end

function M.setup()
  M.init()

  vim.api.nvim_create_autocmd(
    { 'DirChanged', 'CursorMoved', 'BufWinEnter', 'BufFilePost', 'InsertEnter', 'BufWritePost' }, {
      callback = function()
        M.show_winbar()
      end
    })
end

return M
