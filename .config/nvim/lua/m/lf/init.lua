-- Tweaked from:
-- https://github.com/theniceboy/joshuto.nvim

local open_floating_window = require("m.lf.window").open_floating_window
local utils = require("m.utils")

local function is_lf_available()
  return vim.fn.executable('lf') == 1
end

local debug = false

LF_BUFFER = nil
LF_LOADED = false
vim.g.lf_opened = 0
local prev_win = -1
local win = -1
local buffer = -1
local selection_path = os.tmpname()
local lastdir_path = os.tmpname()

local function exec_lf_command(cmd, edit_cmd)
  local function on_exit(job_id, code, event)
    LF_BUFFER = nil
    LF_LOADED = false
    vim.g.lf_opened = 0
    vim.cmd("silent! :checktime")

    local selection = vim.fn.readfile(selection_path)
    local lastdir = vim.fn.readfile(lastdir_path)
    if debug then
      vim.notify(string.format("LF\nExit code: %s\nSelection: %s\nLastdir %s",
        code,
        table.concat(selection, ", "),
        lastdir[1])
      )
    end

    -- Close LF window & restore focus to preview window
    if vim.api.nvim_win_is_valid(prev_win) then
      vim.api.nvim_win_close(win, true)
      vim.api.nvim_set_current_win(prev_win)
      prev_win = -1
      -- Cleanup LF buf
      if vim.api.nvim_buf_is_valid(buffer) and vim.api.nvim_buf_is_loaded(buffer) then
        vim.api.nvim_buf_delete(buffer, { force = true })
      end
      buffer = -1
      win = -1
    end

    -- Filter invalid selection entries and open them
    selection = utils.filter(selection, function(v)
      return vim.trim(v) ~= ""
    end)
    if #selection > 0 then
      if debug then
        vim.notify("LF: opening selections")
      end
      for _, file in ipairs(selection) do
        vim.cmd(string.format([[%s %s]], edit_cmd, file))
      end
    end
  end

  if LF_LOADED == false then
    -- ensure that the buffer is closed on exit
    vim.g.lf_opened = 1
    vim.fn.termopen(cmd, { on_exit = on_exit })
  end
  vim.cmd("startinsert")
end

--- :Lf entry point
local function lf(opts)
  opts = opts or {}

  if is_lf_available() ~= true then
    print("Please install lf. Check documentation for more information")
    return
  end

  prev_win = vim.api.nvim_get_current_win()

  win, buffer = open_floating_window()

  vim.fn.writefile({ "" }, selection_path)
  vim.fn.writefile({ "" }, lastdir_path)

  exec_lf_command(
    string.format([[PAGER="nvim -RM" lf -last-dir-path="%s" -selection-path="%s" "%s"]],
      lastdir_path,
      selection_path,
      opts.path or vim.fn.expand("%:p:h")
    ),
    opts.edit_cmd or "vsplit"
  )
end

return {
  lf = lf,
}
