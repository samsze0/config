local api = vim.api

local winblend = 0 -- 0 to 100
local scaling_factor_horizontal = 0.9
local scaling_factor_vertical = 0.95

--- open floating window with nice borders
local function open_floating_window()
  local height = math.ceil(vim.o.lines * scaling_factor_vertical) - 1
  local width = math.ceil(vim.o.columns * scaling_factor_horizontal)

  local row = math.ceil(vim.o.lines - height) / 2
  local col = math.ceil(vim.o.columns - width) / 2

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

  -- create a unlisted scratch buffer for the border
  local border_buffer = api.nvim_create_buf(false, true)
  api.nvim_buf_set_lines(border_buffer, 0, -1, true, border_lines)
  -- create border window and enter immediately
  local border_window = api.nvim_open_win(border_buffer, true, {
    style = "minimal",
    relative = "editor",
    row = row - 1,
    col = col - 1,
    width = width + 2,
    height = height + 2,
  })
  vim.api.nvim_set_hl(0, "FzfBorder", { link = "Normal", default = true })
  vim.cmd("set winhl=NormalFloat:FzfBorder")

  -- create an unlisted scratch buffer for Fzf if none currently exists or not associated to any window
  if FZF_BUFFER == nil or vim.fn.bufwinnr(FZF_BUFFER) == -1 then
    FZF_BUFFER = api.nvim_create_buf(false, true)
  end

  -- create window for Fzf
  local win = api.nvim_open_win(FZF_BUFFER, true, {
    style = "minimal",
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
  })

  vim.bo[FZF_BUFFER].filetype = "fzf"

  vim.cmd("setlocal bufhidden=hide")
  vim.cmd("setlocal nocursorcolumn")
  vim.api.nvim_set_hl(0, "FzfFloat", { link = "Normal", default = true })
  vim.cmd("setlocal winhl=NormalFloat:FzfFloat")
  vim.cmd("set winblend=" .. winblend)

  -- hide Fzf window on WinLeave
  vim.cmd([[autocmd WinLeave <buffer> silent! execute 'hide']])
  -- ensure that the border_buffer closes at the same time as the fzf buffer
  vim.cmd(
    string.format(
      [[autocmd WinLeave <buffer> silent! execute 'silent bdelete! %s']],
      border_buffer
    )
  )

  return win
end

return {
  open_floating_window = open_floating_window,
}
