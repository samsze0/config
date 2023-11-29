-- nvim-tabline
-- David Zhang <https://github.com/crispgm>

local M = {}
local fn = vim.fn

M.options = {
  show_index = false,
  show_modify = true,
  show_icon = false,
  fnamemodify = ':t',
  no_name = 'No Name',
  modify_indicator = ' ',
  inactive_tab_max_length = 0,
  padding = '  '
}

local function tabline(options)
  local s = ''
  for index = 1, fn.tabpagenr('$') do
    local winnr = fn.tabpagewinnr(index)
    local buflist = fn.tabpagebuflist(index)
    local bufnr = buflist[winnr]
    local bufname = fn.bufname(bufnr)
    local bufmodified = fn.getbufvar(bufnr, '&mod')
    local buffiletype = fn.getbufvar(bufnr, '&filetype')
    local bufbuftype = fn.getbufvar(bufnr, '&buftype')
    local buflisted = fn.getbufvar(bufnr, '&buflisted')

    s = s .. '%' .. index .. 'T'
    if index == fn.tabpagenr() then
      s = s .. '%#TabLineSel#'
    else
      s = s .. '%#TabLine#'
    end
    -- tab index
    s = s .. options.padding
    -- index
    if options.show_index then
      s = s .. index .. ':'
    end
    -- icon
    if bufbuftype == "terminal" then
      s = s .. '  '
    elseif bufbuftype == "" then -- Normal buffer
      local icon = ''
      if options.show_icon and M.has_devicons then
        local ext = fn.fnamemodify(bufname, ':e')
        icon = M.devicons.get_icon(bufname, ext, { default = true }) .. ' '
      end
      -- buf name
      local pre_title_s_len = string.len(s)
      if bufname ~= '' then
        s = s .. icon .. fn.fnamemodify(bufname, options.fnamemodify)
      else
        s = s .. options.no_name
      end
      if
          options.inactive_tab_max_length
          and options.inactive_tab_max_length > 0
          and index ~= fn.tabpagenr()
      then
        s = string.sub(
          s,
          1,
          pre_title_s_len + options.inactive_tab_max_length
        )
      end
      -- modify indicator
      if
          bufmodified == 1
          and options.show_modify
          and options.modify_indicator ~= nil
      then
        s = s .. options.modify_indicator
      end
    else
      s = s .. '  '
    end
    -- additional space at the end of each tab segment
    s = s .. options.padding
  end

  s = s .. '%#TabLineFill#'
  return s
end

function M.setup(user_options)
  M.options = vim.tbl_extend('force', M.options, user_options)
  M.has_devicons, M.devicons = pcall(require, 'nvim-web-devicons')

  function _G.tabline()
    return tabline(M.options)
  end

  vim.o.tabline = '%!v:lua.tabline()'
end

return M
