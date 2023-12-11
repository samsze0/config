local api = vim.api

local function open_floating_window(opts)
  opts = vim.tbl_extend("force", {
    width = 0.9,
    height = 0.9,
    position = "right",
    winblend = 0,
    buffer = nil,
    buffiletype = "floating_window",
    border_win_extra_opts = nil,
    main_win_extra_opts = nil,
  }, opts or {})

  local height, width, row, col, anchor

  height = math.floor(vim.o.lines * opts.height)
  width = math.floor(vim.o.columns * opts.width)
  -- By default anchor is north-west
  row = math.ceil(vim.o.lines - height) / 2
  col = math.ceil(vim.o.columns - width) / 2

  if opts.position == "center" then
  elseif opts.position == "left" then
    width = math.floor(width * 0.5)
    anchor = "NW"
  elseif opts.position == "right" then
    width = math.floor(width * 0.5)
    col = vim.o.columns - col + 2
    anchor = "NE"
  else
    vim.notify("Window utils: invalid position option", vim.log.levels.ERROR)
    return
  end

  local topleft, top, topright, right, botright, bot, botleft, left
  local window_chars =
    { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
  topleft, top, topright, right, botright, bot, botleft, left =
    unpack(window_chars)

  local border_lines = { topleft .. string.rep(top, width) .. topright }
  local middle_line = left .. string.rep(" ", width) .. right
  for _ = 1, height do
    table.insert(border_lines, middle_line)
  end
  table.insert(border_lines, botleft .. string.rep(bot, width) .. botright)

  -- Create a unlisted scratch buffer for the border, which will be deleted when main buffer goes hidden
  local border_buffer = api.nvim_create_buf(false, true)
  api.nvim_buf_set_lines(border_buffer, 0, -1, true, border_lines)
  -- Create border window and enter immediately
  local border_window = api.nvim_open_win(
    border_buffer,
    true,
    vim.tbl_extend("error", {
      style = "minimal",
      relative = "editor",
      row = row - 1,
      col = (anchor == "NW" or anchor == "SW") and col - 1 or col + 1,
      width = width + 2,
      height = height + 2,
      anchor = anchor,
    }, opts.border_win_extra_opts or {})
  )
  vim.api.nvim_set_hl(
    0,
    "FloatingWindowBorder",
    { link = "Normal", default = true }
  )
  vim.cmd("set winhl=NormalFloat:FloatingWindowBorder")

  -- Create an unlisted scratch buffer for main if none currently exists or not associated to any window
  local main_buffer = opts.buffer
  if main_buffer == nil or vim.fn.bufwinnr(main_buffer) == -1 then
    main_buffer = api.nvim_create_buf(false, true)
  end

  -- Create window for main
  local main_win = api.nvim_open_win(
    main_buffer,
    true,
    vim.tbl_extend("error", {
      style = "minimal",
      relative = "editor",
      row = row,
      col = col,
      width = width,
      height = height,
      anchor = anchor,
    }, opts.main_win_extra_opts or {})
  )

  vim.bo[main_buffer].filetype = opts.buffiletype

  vim.cmd("setlocal bufhidden=hide")
  vim.cmd("setlocal nocursorcolumn")
  vim.api.nvim_set_hl(0, "FloatingWindow", { link = "Normal", default = true })
  vim.cmd("setlocal winhl=NormalFloat:FloatingWindow")
  vim.cmd("set winblend=" .. opts.winblend)

  -- Hide main window on WinLeave
  vim.cmd([[autocmd WinLeave <buffer> silent! execute 'hide']])
  -- Ensure that the border_buffer closes at the same time as the main buffer
  vim.cmd(
    string.format(
      [[autocmd WinLeave <buffer> silent! execute 'silent bdelete! %s']],
      border_buffer
    )
  )

  return main_win, main_buffer, border_window, border_buffer
end

return {
  open_floating_window = open_floating_window,
}
