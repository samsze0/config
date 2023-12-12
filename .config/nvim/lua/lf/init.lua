-- Tweaked from:
-- https://github.com/theniceboy/joshuto.nvim

local utils = require("utils")
local window_utils = require("utils.window")

local function is_lf_available() return vim.fn.executable("lf") == 1 end

local debug = false

LF_WINDOW = -1
LF_PREV_WINDOW = -1
LF_BUFFER = nil

local reset_state = function()
  LF_WINDOW = -1
  LF_PREV_WINDOW = -1
  LF_BUFFER = nil
end

reset_state()

local selection_path = os.tmpname()
local lastdir_path = os.tmpname()
local current_selection_path = vim.fn.glob("~/.cache/lf_current_selection")

local nvim_server_path = "~/.cache/nvim/server.pipe"
local start_nvim_server = false
if start_nvim_server then
  vim.fn.system(string.format([[nvim --listen %s]], nvim_server_path))
end

local edit_selected_files = function(edit_cmd, selection, remote)
  -- Filter invalid selection entries and open them
  selection = utils.filter(selection, function(v) return vim.trim(v) ~= "" end)
  if #selection > 0 then
    if debug then vim.notify("LF: opening selections") end
    for _, file in ipairs(selection) do
      if remote and edit_cmd == "tabnew" then
        vim.cmd(
          string.format(
            [[nvim --server %s --remote-tab %s]],
            nvim_server_path,
            file
          )
        )
      else
        vim.cmd(string.format([[%s %s]], edit_cmd, file))
      end
    end
  end
end

local function exec_lf_command(cmd, edit_cmd)
  local function on_exit(job_id, code, event)
    LF_BUFFER = nil
    vim.cmd("silent! :checktime")

    local selection = vim.fn.readfile(selection_path)
    local lastdir = vim.fn.readfile(lastdir_path)
    if debug then
      vim.notify(
        string.format(
          "LF\nExit code: %s\nSelection: %s\nLastdir %s",
          code,
          table.concat(selection, ", "),
          lastdir[1]
        )
      )
    end

    -- Close LF window & restore focus to preview window
    if vim.api.nvim_win_is_valid(LF_PREV_WINDOW) then
      vim.api.nvim_win_close(LF_WINDOW, true)
      vim.api.nvim_set_current_win(LF_PREV_WINDOW)
      LF_PREV_WINDOW = -1
      LF_WINDOW = -1
    end

    edit_selected_files(edit_cmd, selection)
  end

  vim.fn.termopen(cmd, { on_exit = on_exit })

  vim.cmd("startinsert")
end

--- :Lf entry point
local function lf(opts)
  reset_state()

  opts = opts or {}

  if is_lf_available() ~= true then
    vim.notify(
      "Please install lf. Check documentation for more information",
      vim.log.level.ERROR
    )
    return
  end

  LF_PREV_WINDOW = vim.api.nvim_get_current_win()

  LF_WINDOW, LF_BUFFER = window_utils.open_floating_window({
    buffer = LF_BUFFER,
    buffiletype = "lf",
  })

  vim.keymap.set("t", "<C-t>", function()
    local selection = vim.fn.readfile(current_selection_path)
    edit_selected_files("tabnew", selection)
  end, {
    buffer = LF_BUFFER,
  })
  vim.keymap.set("t", "<C-w>", function()
    local selection = vim.fn.readfile(current_selection_path)
    edit_selected_files("vnew", selection)
  end, {
    buffer = LF_BUFFER,
  })

  vim.fn.writefile({ "" }, selection_path)
  vim.fn.writefile({ "" }, lastdir_path)

  exec_lf_command(
    string.format(
      [[PAGER="nvim -RM" lf -last-dir-path="%s" -selection-path="%s" "%s"]],
      lastdir_path,
      selection_path,
      opts.path or vim.fn.expand("%:p:h")
    ),
    opts.edit_cmd or "e"
  )
end

return {
  lf = lf,
}
