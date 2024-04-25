local utils = require("utils")

local function is_lf_available() return vim.fn.executable("lf") == 1 end

local debug = false

local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event

local selection_path = os.tmpname() .. "lf-selection"
local lastdir_path = os.tmpname() .. "lf-lastdir"
local current_selection_path = vim.fn.glob("~/.cache/lf_current_selection")

-- https://github.com/MunifTanjim/nui.nvim/tree/main/lua/nui/popup
local popup = Popup({
  enter = true,
  focusable = true,
  border = {
    style = "rounded",
  },
  position = "50%",
  relative = "editor",
  size = {
    width = "90%",
    height = "90%",
  },
  buf_options = {
    modifiable = false,
    filetype = "lf",
  },
  win_options = {
    winblend = 0,
    winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
  },
})

local M = {}

--- :Lf entry point
function M.lf(opts)
  opts = vim.tbl_extend("force", {
    edit_cmd = "e",
    path = vim.fn.getcwd(),
  }, opts or {})

  if is_lf_available() ~= true then
    vim.notify(
      "Please install lf. Check documentation for more information",
      vim.log.level.ERROR
    )
    return
  end

  local prev_win = vim.api.nvim_get_current_win()

  popup:mount()
  popup:on(event.BufLeave, function() popup:unmount() end)

  local close_popup_and_edit_selected_files = function(edit_cmd, selection)
    popup:unmount()

    -- Close LF window & restore focus to preview window
    if vim.api.nvim_win_is_valid(prev_win) then
      vim.cmd(string.format([[silent! %s wincmd w]], prev_win))
    end

    -- Filter invalid selection entries and open them
    selection = utils.filter(
      selection,
      function(_, v) return vim.trim(v) ~= "" end
    )
    if #selection > 0 then
      if debug then vim.notify("LF: opening selections") end
      for _, file in ipairs(selection) do
        vim.cmd(string.format([[%s %s]], edit_cmd, file))
      end
    end
  end

  popup:map("t", "<C-t>", function()
    local selection = vim.fn.readfile(current_selection_path)
    close_popup_and_edit_selected_files("tabnew", selection)
  end)
  popup:map("t", "<C-w>", function()
    local selection = vim.fn.readfile(current_selection_path)
    close_popup_and_edit_selected_files("vnew", selection)
  end)

  -- Empty cache files
  vim.fn.writefile({ "" }, selection_path)
  vim.fn.writefile({ "" }, lastdir_path)

  local cmd = string.format(
    [[PAGER="nvim -RM" lf -last-dir-path="%s" -selection-path="%s" "%s"]],
    lastdir_path,
    selection_path,
    opts.path
  )

  vim.fn.termopen(cmd, {
    on_exit = function(job_id, code, event)
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

      close_popup_and_edit_selected_files(opts.edit_cmd, selection)
    end,
  })

  vim.cmd("startinsert")
end

return M
