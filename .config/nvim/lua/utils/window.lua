local api = vim.api

local function open_floating_window(opts)
  opts = vim.tbl_extend("force", {
    width = 0.9,
    height = 0.9,
    position = "center",
    winblend = 0,
    buffer = nil,
    buffiletype = "floating_window",
    border_win_extra_opts = nil,
    main_win_extra_opts = nil,
    enter_immediately = true,
    parent_buffer = nil,
    style = nil,
  }, opts or {})

  local height, width, row, col

  height = math.floor(vim.o.lines * opts.height)
  width = math.floor(vim.o.columns * opts.width)
  -- By default anchor is north-west
  row = math.ceil(vim.o.lines - height) / 2
  col = math.ceil(vim.o.columns - width) / 2

  if opts.position == "center" then
  elseif opts.position == "left" then
    width = math.floor(width * 0.5)
  elseif opts.position == "right" then
    width = math.floor(vim.o.columns * opts.width * 0.5)
    col = vim.o.columns - col - width + 2 -- Add 2 because col was ceiled and width was floored
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

  -- Create a unlisted scratch buffer for the border
  local border_buffer = api.nvim_create_buf(false, true)
  api.nvim_buf_set_lines(border_buffer, 0, -1, true, border_lines)
  -- Create border window
  local border_window
  local border_window = api.nvim_open_win(
    border_buffer,
    opts.enter_immediately,
    vim.tbl_extend("force", {
      style = "minimal",
      relative = "editor",
      row = row - 1,
      col = col - 1,
      width = width + 2,
      height = height + 2,
      zindex = 10,
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
    opts.enter_immediately,
    vim.tbl_extend("force", {
      style = "minimal", -- Currently "minimal" is the only available option
      relative = "editor",
      row = row,
      col = col,
      width = width,
      height = height,
      zindex = 20,
    }, opts.main_win_extra_opts or {})
  )
  if opts.style == "code" then
    vim.wo[main_win].number = true
  end

  vim.bo[main_buffer].filetype = opts.buffiletype

  vim.cmd("setlocal bufhidden=hide")
  vim.cmd("setlocal nocursorcolumn")
  vim.api.nvim_set_hl(0, "FloatingWindow", { link = "Normal", default = true })
  vim.cmd("setlocal winhl=NormalFloat:FloatingWindow")
  vim.cmd("set winblend=" .. opts.winblend)

  if opts.enter_immediately then
    -- Close current window when WinLeave event triggers
    vim.cmd([[autocmd WinLeave <buffer> silent! execute 'hide']])
    -- Delete border buffer when WinLeave event triggers
    vim.cmd(
      string.format(
        [[autocmd WinLeave <buffer> silent! execute 'silent bdelete! %s']],
        border_buffer
      )
    )
  else
    -- Close main window when WinLeave event triggers
    vim.api.nvim_create_autocmd("WinLeave", {
      buffer = opts.parent_buffer,
      callback = function(ctx) vim.api.nvim_win_close(main_win, true) end,
    })
    -- Delete border buffer when WinLeave event triggers
    vim.api.nvim_create_autocmd("WinLeave", {
      buffer = opts.parent_buffer,
      callback = function(ctx)
        vim.api.nvim_buf_delete(border_buffer, { force = true })
      end,
    })
  end

  return main_win, main_buffer, border_window, border_buffer
end

return {
  open_floating_window = open_floating_window,
}
