local window_utils = require("utils.window")
local utils = require("utils")

local Layout = require("nui.layout")
local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event

local use_rg_colors = true

local M = {
  -- Let fzf handle the wrapping such that fzf can correctly offset the preview window
  bat_default_opts = "--color always --wrap never --terminal-width $FZF_PREVIEW_COLUMNS",
  delta_default_opts = "--width=$FZF_PREVIEW_COLUMNS",
  use_rg_colors = use_rg_colors,
  rg_default_opts = "--smart-case --no-ignore --hidden --trim "
    .. (use_rg_colors and "--color=always --colors 'match:fg:blue' --colors 'path:fg:80,130,150' --colors 'line:fg:80,130,150' " or "--color=never ")
    .. "--no-column --line-number --no-heading",
  fzf_default_args = "--scroll-off=10",
  fzf_default_preview_window_args = "right,50%,border-none,wrap,nofollow,nocycle",
}

M.set_keymaps_for_popups_nav = function(popup_nav_configs)
  -- For every permutation of cartesian product of popup_nav_configs where i ~= j,
  -- map the keybinds to switch to the window of popup j from popup i
  for i, ci in ipairs(popup_nav_configs) do
    for j, cj in ipairs(popup_nav_configs) do
      if j ~= i then
        cj.popup:map(cj.is_terminal and "t" or "n", ci.key, function()
          vim.api.nvim_set_current_win(ci.popup.winid)
          if ci.is_terminal then vim.cmd("startinsert") end
        end)
      end
    end
  end
end

M.set_keymaps_for_nvim_preview = function(main_popup, preview_popup, opts)
  opts = vim.tbl_extend("force", {
    scrollup_preview_from_main_popup = "<S-Up>",
    scrolldown_preview_from_main_popup = "<S-Down>",
  }, opts or {})

  main_popup:map("t", opts.scrollup_preview_from_main_popup, function()
    -- Setting current window to right window will cause scrollbar to refresh as well
    vim.api.nvim_set_current_win(preview_popup.winid)
    vim.api.nvim_input("<S-Up>")
    vim.schedule(function()
      vim.api.nvim_set_current_win(main_popup.winid)
      vim.cmd("startinsert")
    end)
  end)
  main_popup:map("t", opts.scrolldown_preview_from_main_popup, function()
    vim.api.nvim_set_current_win(preview_popup.winid)
    vim.api.nvim_input("<S-Down>")
    vim.schedule(function()
      vim.api.nvim_set_current_win(main_popup.winid)
      vim.cmd("startinsert")
    end)
  end)
end

-- FIX
M.set_keymaps_for_fzf_preview = function(main_popup, opts)
  opts = vim.tbl_extend("force", {
    scrollup_preview_from_main_popup = "<S-Up>",
    scrolldown_preview_from_main_popup = "<S-Down>",
  }, opts or {})

  main_popup:map( -- TODO
    "t",
    opts.scrollup_preview_from_main_popup,
    function() vim.api.nvim_input("<M-a>") end
  )
  vim.keymap.set(
    "t",
    opts.scrolldown_preview_from_main_popup,
    function() vim.api.nvim_input("<M-b>") end
  )
end

M.custom_fzf_keybinds = {
  ["shift-up"] = "preview-up+preview-up+preview-up+preview-up+preview-up",
  ["shift-down"] = "preview-down+preview-down+preview-down+preview-down+preview-down",
  ["alt-a"] = "preview-up",
  ["alt-b"] = "preview-down",
}

M.create_simple_layout = function()
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
      Layout.Box(main_popup, { size = "100%" }),
    }, {})
  )

  main_popup:on("BufLeave", function() layout:unmount() end)

  return layout, {
    main = main_popup,
  }
end

M.create_nvim_preview_layout = function()
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

  local popups = { main = main_popup, nvim_preview = nvim_preview_popup }

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
      Layout.Box(nvim_preview_popup, { size = "50%" }),
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

  return layout, popups
end

return M
