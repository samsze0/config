local core = require("fzf.core")
local utils = require("utils")
local fzf_misc = require("fzf.misc")

local Layout = require("nui.layout")
local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event

local M = {}

-- TODO: cleanup

---@return NuiLayout, { main: NuiPopup, nvim_preview: NuiPopup, replace_str: NuiPopup }, fun(): string
function M.create_layout()
  local main_popup = Popup({
    enter = true,
    focusable = true,
    border = {
      style = "rounded",
    },
    buf_options = {
      modifiable = false,
      filetype = "fzf",
    },
    win_options = {
      winblend = 0,
      winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
    },
  })

  local nvim_preview_popup = Popup({
    enter = false,
    focusable = true,
    border = {
      style = "rounded",
      text = {
        top = " Preview ",
      },
    },
    buf_options = {
      modifiable = true,
    },
    win_options = {
      winblend = 0,
      winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
      number = true,
      cursorline = true,
    },
  })

  local replace_str_popup = Popup({
    enter = false,
    focusable = true,
    border = {
      style = "rounded",
      text = {
        top = " Replacement ",
      },
    },
    buf_options = {
      modifiable = true,
    },
    win_options = {
      winblend = 0,
      winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
      number = true,
    },
  })

  local popups = {
    main = main_popup,
    nvim_preview = nvim_preview_popup,
    replace_str = replace_str_popup,
  }

  local layout = Layout(
    {
      position = "50%",
      relative = "editor",
      size = {
        width = "90%",
        height = "90%",
      },
    },
    Layout.Box({
      Layout.Box(main_popup, { size = "50%" }),
      Layout.Box({
        Layout.Box(replace_str_popup, { size = "20%" }),
        Layout.Box(nvim_preview_popup, { grow = 1 }),
      }, { size = "50%", dir = "col" }),
    }, { dir = "row" })
  )

  for _, popup in pairs(popups) do
    popup:on("BufLeave", function()
      vim.schedule(function()
        local curr_bufnr = vim.api.nvim_get_current_buf()
        for _, p in pairs(popups) do
          if p.bufnr == curr_bufnr then return end
        end
        layout:unmount()
      end)
    end)
  end

  local function get_replacement()
    return table.concat(
      -- Retrieve all lines (possibly modified)
      vim.fn.getbufline(popups.replace_str.bufnr, 1, "$"), ---@diagnostic disable-line: param-type-mismatch
      "\r"
    )
  end

  return layout, popups, get_replacement
end

---@param popups { nvim_preview: NuiPopup, replace_str: NuiPopup }
---@param replacement string
---@param parse_entry fun(entry: string): string, number
---@param focused_entry string
---@param query string
function M.reload_preview(
  popups,
  replacement,
  parse_entry,
  focused_entry,
  query
)
  if focused_entry == nil or focused_entry == "" then
    vim.api.nvim_buf_set_lines(popups.nvim_preview.bufnr, 0, -1, false, {})
    return
  end

  local filepath, row = parse_entry(focused_entry)
  local filename = vim.fn.fnamemodify(filepath, ":t")
  local filecontent = vim.fn.readfile(filepath)
  local current_win = vim.api.nvim_get_current_win()

  local ft = vim.filetype.match({
    filename = filename,
    contents = filecontent,
  })

  local filecontent_after
  if #replacement > 0 then
    filecontent_after = vim.fn.systemlist(
      string.format(
        [[cat "%s" | sed -E "%ss/%s/%s/g"]],
        filepath,
        row,
        query,
        replacement
      )
    )
    if vim.v.shell_error ~= 0 then
      vim.notify(
        "Error while trying to perform sed substitution",
        vim.log.levels.ERROR
      )
      return
    end
  end

  vim.api.nvim_buf_set_lines(
    popups.nvim_preview.bufnr,
    0,
    -1,
    false,
    #replacement > 0 and filecontent_after or filecontent
  )
  if ft then vim.bo[popups.nvim_preview.bufnr].filetype = ft end

  -- Switch to preview window and back in order to refresh scrollbar
  vim.api.nvim_set_current_win(popups.nvim_preview.winid)
  vim.fn.cursor({ row, 0 })
  vim.cmd([[normal! zz]])
  vim.api.nvim_set_current_win(current_win)
end

M.actions = {}

---@param state_id string
---@param parse_selection fun(selection: string): string, integer, string
---@param win integer
---@param callback? fun()
function M.actions.send_current_selections_to_loclist(
  state_id,
  parse_selection,
  win,
  callback
)
  core.get_current_selections(state_id, function(indices, selections)
    local entries = utils.map(selections, function(_, s)
      local filepath, line, text = parse_selection(s)

      -- :h setqflist
      return {
        filename = filepath,
        lnum = line,
        col = 0,
        text = text,
      }
    end)

    core.abort_and_execute(state_id, function()
      vim.fn.setloclist(win, entries)
      if callback then callback() end
      fzf_misc.loclist()
    end)
  end)
end

return M
