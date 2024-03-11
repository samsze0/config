local uv_utils = require("utils.uv")
local fzf_utils = require("fzf.utils")
local core = require("fzf.core")

local use_rg_colors = true

local M = {
  -- Let fzf handle the wrapping such that fzf can correctly offset the preview window
  bat_default_opts = "--color always --wrap never --terminal-width $FZF_PREVIEW_COLUMNS",
  delta_default_opts = "--width=$FZF_PREVIEW_COLUMNS",
  delta_nvim_default_opts = "--syntax-theme='Nord'", -- FIX: base16 theme not working properly
  use_rg_colors = use_rg_colors,
  rg_default_opts = "--smart-case --no-ignore --hidden --trim "
    .. (use_rg_colors and "--color=always --colors 'match:fg:blue' --colors 'path:fg:80,130,150' --colors 'line:fg:80,130,150' " or "--color=never ")
    .. "--no-column --line-number --no-heading",
  fzf_default_args = {
    ["--padding"] = "0,1",
    ["--margin"] = "0",
    ["--scroll-off"] = "2",
  },
  fzf_default_preview_window_args = "right,50%,border-none,wrap,nofollow,nocycle",
}

-- Binds for auto reload
--
---@param get_entries fun(): string[]
---@param opts? { get_entries_in_vim_loop?: boolean, interval?: number }
M.auto_reload_binds = function(get_entries, opts)
  opts = vim.tbl_extend("force", {
    get_entries_in_vim_loop = true,
    interval = 1000,
  }, opts or {})

  local timer = nil ---@type uv_timer_t?

  return {
    ["start"] = function(state)
      -- Using set_timeout rather than set_interval in order to avoid scheduling too many reload actions to the event loop
      local function reload()
        if timer then
          core.send_to_fzf(state.id, fzf_utils.reload_action(get_entries()))
          uv_utils.set_timeout(opts.interval, reload, {
            callback_in_vim_loop = opts.get_entries_in_vim_loop,
          })
        end
      end

      timer = uv_utils.set_timeout(opts.interval, reload, {
        callback_in_vim_loop = opts.get_entries_in_vim_loop,
      })
    end,
    ["+after-exit"] = function(state) timer = nil end,
  }
end

-- Open a file in the preview buffer and auto detect the filetype
--
---@param filepath string
---@param preview_popup NuiPopup
---@param opts? { cursor_pos?: { row: number, col?: number } }
M.preview_file = function(filepath, preview_popup, opts)
  opts = vim.tbl_extend("force", {}, opts or {})

  local filename = vim.fn.fnamemodify(filepath, ":t")
  local ft = vim.filetype.match({
    filename = filename,
    contents = vim.fn.readfile(filepath),
  })

  vim.api.nvim_buf_set_lines(
    preview_popup.bufnr,
    0,
    -1,
    false,
    vim.fn.readfile(filepath)
  )
  if ft then vim.bo[preview_popup.bufnr].filetype = ft end

  local current_win = vim.api.nvim_get_current_win()

  -- Switch to preview window and back in order to refresh scrollbar
  -- TODO: Remove this once scrollbar plugin support remote refresh
  vim.api.nvim_set_current_win(preview_popup.winid)
  if opts.cursor_pos then
    vim.fn.cursor({ opts.cursor_pos.row, opts.cursor_pos.col or 0 })
    vim.cmd([[normal! zz]])
  end
  vim.api.nvim_set_current_win(current_win)
end

-- Open a buffer's content in the preview buffer and auto detect the filetype
--
---@param bufnr number
---@param preview_popup NuiPopup
---@param opts? { cursor_pos?: { row: number, col?: number } }
M.preview_buffer = function(bufnr, preview_popup, opts)
  opts = vim.tbl_extend("force", {}, opts or {})

  local filename = vim.fn.bufname(bufnr)
  local buf_content = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local ft = vim.filetype.match({
    filename = filename,
    contents = buf_content,
  })

  vim.api.nvim_buf_set_lines(preview_popup.bufnr, 0, -1, false, buf_content)
  if ft then vim.bo[preview_popup.bufnr].filetype = ft end

  local current_win = vim.api.nvim_get_current_win()

  -- Switch to preview window and back in order to refresh scrollbar
  -- TODO: Remove this once scrollbar plugin support remote refresh
  vim.api.nvim_set_current_win(preview_popup.winid)
  if opts.cursor_pos then
    vim.fn.cursor({ opts.cursor_pos.row, opts.cursor_pos.col or 0 })
    vim.cmd([[normal! zz]])
  end
  vim.api.nvim_set_current_win(current_win)
end

-- Truncate or pad a string to a certain width
--
---@param str string
---@param width number The width to truncate or pad to, expressed in number of columns or percentage of current window
---@param opts? { width_in_percentage?: boolean }
---@return string
M.trunc_or_pad_to_width = function(str, width, opts)
  opts = vim.tbl_extend("force", {
    width_in_percentage = false,
  }, opts or {})

  if width < 0 then error("Width must be at least 0") end

  if opts.width_in_percentage then
    width = math.floor(vim.api.nvim_win_get_width(0) * width * 0.01)
  end

  if #str > width then
    return str:sub(1, width - 3) .. "..."
  else
    return str .. string.rep(" ", width - #str)
  end
end

return M
