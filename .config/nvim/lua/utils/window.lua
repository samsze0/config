local api = vim.api

local M = {}

local utils = require("utils")

M.open_floating_window = function(opts)
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
  if opts.style == "code" then
    vim.wo[main_win].number = true
    -- vim.bo[main_buffer].modifiable = false
    -- vim.bo[main_buffer].readonly = true
  end

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

M.create_float_window_nav_keymaps = function(left, right, opts)
  opts = vim.tbl_extend("force", {
    goto_right_win = "<C-f>",
    goto_left_win = "<C-s>",
    scrollup_right_win_from_left_win = "<S-Up>",
    scrolldown_right_win_from_left_win = "<S-Down>",
  }, opts or {})

  -- Window navigation
  vim.keymap.set(
    left.is_terminal and "t" or "n",
    opts.goto_right_win,
    function()
      vim.api.nvim_set_current_win(right.window)
      if right.is_terminal then vim.cmd("startinsert") end
    end,
    {
      buffer = left.buffer,
    }
  )
  vim.keymap.set(
    right.is_terminal and "t" or "n",
    opts.goto_left_win,
    function()
      vim.api.nvim_set_current_win(left.window)
      if left.is_terminal then vim.cmd("startinsert") end
    end,
    {
      buffer = right.buffer,
    }
  )

  -- Scroll up/down right window from left window
  if not right.is_terminal then
    vim.keymap.set(
      left.is_terminal and "t" or "n",
      opts.scrollup_right_win_from_left_win,
      function()
        -- Setting current window to right window will cause scrollbar to refresh as well
        -- TODO: make mapping generic and support any custom mapping in options
        vim.api.nvim_set_current_win(right.window)
        if false then
          vim.cmd("normal! <S-Up>")
        else
          vim.api.nvim_input("<S-Up>")
        end
        vim.schedule(function()
          vim.api.nvim_set_current_win(left.window)
          if left.is_terminal then vim.cmd("startinsert") end
        end)
      end,
      {
        buffer = left.buffer,
      }
    )
    vim.keymap.set(
      left.is_terminal and "t" or "n",
      opts.scrolldown_right_win_from_left_win,
      function()
        -- vim.fn.win_execute(right.window, "normal \\<S-down>")

        vim.api.nvim_set_current_win(right.window)
        if false then
          vim.cmd("normal! <S-Down>")
        else
          vim.api.nvim_input("<S-Down>")
          -- vim.api.nvim_feedkeys("<S-Down>", "m", true)
        end
        -- Because nvim_input is non-blocking, we need to queue the nvim_set_current_win so that it executes after nvim_input
        vim.schedule(function()
          vim.api.nvim_set_current_win(left.window)
          if left.is_terminal then vim.cmd("startinsert") end
        end)
      end,
      {
        buffer = left.buffer,
      }
    )
  end
end

return M
