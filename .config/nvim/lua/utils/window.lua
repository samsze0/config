local api = vim.api

local M = {}

local utils = require("utils")

-- @Deprecated
-- Use nui instead
M.open_floating_window = function(opts)
  opts = vim.tbl_extend("force", {
    horizontal_position = "center",
    vertical_position = "center",
    winblend = 0,
    buffer = nil,
    buffiletype = "floating_window",
    border_win_extra_opts = nil,
    main_win_extra_opts = nil,
    enter_immediately = true,
    style = nil,
  }, opts or {})

  local height, width, row, col

  height = math.floor(vim.o.lines * 0.9)
  width = math.floor(vim.o.columns * 0.9)
  -- By default anchor is north-west
  row = math.ceil(vim.o.lines - height) / 2
  col = math.ceil(vim.o.columns - width) / 2

  if opts.horizontal_position == "center" then
  elseif opts.horizontal_position == "left" then
    width = math.floor(width * 0.5)
  elseif opts.horizontal_position == "right" then
    width = math.floor(width * 0.5)
    col = vim.o.columns - col - width + 2 -- Add 2 because col was ceiled and width was floored
  else
    vim.notify(
      "Window utils: invalid horizontal position option",
      vim.log.levels.ERROR
    )
    return
  end

  if opts.vertical_position == "center" then
  elseif opts.vertical_position == "top" then
    height = math.floor(height * 0.5)
  elseif opts.vertical_position == "down" then
    height = math.floor(height * 0.5)
    row = vim.o.lines - row - height + 2 -- Add 2 because row was ceiled and height was floored
  else
    vim.notify(
      "Window utils: invalid vertical position option",
      vim.log.levels.ERROR
    )
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
      focusable = false,
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

  if opts.style == "code" then vim.wo[main_win].number = true end

  vim.bo[main_buffer].filetype = opts.buffiletype

  vim.cmd("setlocal bufhidden=hide")
  vim.cmd("setlocal nocursorcolumn")
  vim.api.nvim_set_hl(0, "FloatingWindow", { link = "Normal", default = true })
  vim.cmd("setlocal winhl=NormalFloat:FloatingWindow")
  vim.cmd("set winblend=" .. opts.winblend)

  -- Delete border buf & close border window when WinLeave event triggers for main buffer
  vim.api.nvim_create_autocmd("WinClosed", {
    buffer = main_buffer,
    callback = function(ctx)
      vim.api.nvim_buf_delete(border_buffer, { force = true })
    end,
  })

  return main_win, main_buffer, border_window, border_buffer
end

-- @Deprecated
-- Use nui instead
-- Create autocmds that close all windows specified in the input list when current window isn't in the list
M.create_autocmd_close_all_windows_together = function(group, opts)
  opts = vim.tbl_extend("force", {
    delete_border_buffer = true,
    delete_on_leave = false,
  }, opts or {})
  local windows = utils.map(group, function(_, g) return g.window end)

  local autocmd_group = vim.api.nvim_create_augroup(
    "CloseAllWindowWhenLeaveWindowGroup",
    { clear = true }
  )

  if opts.delete_on_leave then
    vim.api.nvim_create_autocmd("WinEnter", {
      group = autocmd_group,
      nested = true,
      callback = function(ctx)
        local current_win = vim.api.nvim_get_current_win()
        if utils.in_list(current_win, windows) then return end

        vim.api.nvim_win_close(windows[1], true) -- Close a random window which causes all others to close
      end,
    })
  end

  for _, g in ipairs(group) do
    vim.api.nvim_create_autocmd("WinClosed", {
      group = autocmd_group,
      buffer = g.buffer,
      callback = function(ctx)
        vim.api.nvim_del_augroup_by_id(autocmd_group)

        for _, gr in ipairs(group) do
          if g == gr then goto continue end -- Don't close the closed window again
          vim.api.nvim_win_close(gr.window, true)
          if opts.delete_border_buffer then
            vim.api.nvim_buf_delete(gr.border_buffer, { force = true }) -- Delete manually because autocmd doesn't trigger
          end
          ::continue::
        end
      end,
    })
  end
end

return M
