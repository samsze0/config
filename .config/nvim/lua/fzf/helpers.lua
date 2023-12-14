local window_utils = require("utils.window")
local utils = require("utils")

local rg_colors = false

local M = {
  bat_default_opts = "--color=always --terminal-width $FZF_PREVIEW_COLUMNS",
  delta_default_opts = "--width=$FZF_PREVIEW_COLUMNS",
  rg_default_opts = "--smart-case --no-ignore --hidden --trim "
    .. (rg_colors and "--color=always --colors 'match:fg:blue' --colors 'path:fg:yellow' " or "--color=never ")
    .. "--no-column --line-number --no-heading",
  fzf_default_preview_window_args = "right,50%,border-none,wrap,nofollow,nocycle",
}

M.set_custom_keymaps_for_nvim_preview = function()
  window_utils.create_float_window_nav_keymaps({
    is_terminal = true,
    window = FZF_STATE.window,
    buffer = FZF_STATE.buffer,
  }, {
    is_terminal = false,
    window = FZF_STATE.preview_window,
    buffer = FZF_STATE.preview_buffer,
  })
end

M.set_custom_keymaps_for_fzf_preview = function()
  vim.keymap.set( -- TODO
    "t",
    "<S-PageUp>",
    -- function() vim.fn.chansend(FZF_STATE.channel, "hi \x1ba") end,
    function() vim.api.nvim_input("<M-a>") end,
    { buffer = FZF_STATE.buffer }
  )
  vim.keymap.set(
    "t",
    "<S-PageDown>",
    -- function() vim.fn.chansend(FZF_STATE.channel, "hi \x1bb") end,
    function() vim.api.nvim_input("<M-b>") end,
    { buffer = FZF_STATE.buffer }
  )
end

M.custom_fzf_keybinds = {
  ["shift-up"] = "preview-up+preview-up+preview-up+preview-up+preview-up",
  ["shift-down"] = "preview-down+preview-down+preview-down+preview-down+preview-down",
  ["alt-a"] = "preview-up",
  ["alt-b"] = "preview-down",
}

return M
