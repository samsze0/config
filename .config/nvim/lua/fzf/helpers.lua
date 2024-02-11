local utils = require("utils")
local uv_utils = require("utils.uv")
local fzf_utils = require("fzf.utils")
local core = require("fzf.core")

local Layout = require("nui.layout")
local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event

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
    ["--scroll-off"] = "10",
  },
  fzf_default_preview_window_args = "right,50%,border-none,wrap,nofollow,nocycle",
}

-- Set keymaps for navigating between popups
--
---@param popup_nav_configs { popup: NuiPopup, key: string, is_terminal: boolean }[]
---@return nil
M.set_keymaps_for_popups_nav = function(popup_nav_configs)
  -- For every permutation of cartesian product of popup_nav_configs where i ~= j,
  -- map the keybinds to switch to the window of popup j from popup i
  for i, ci in ipairs(popup_nav_configs) do
    for j, cj in ipairs(popup_nav_configs) do
      if j ~= i then
        cj.popup:map(
          cj.is_terminal and "t" or "n",
          ci.key,
          function() vim.api.nvim_set_current_win(ci.popup.winid) end
        )
      end
    end
  end
end

-- Set default keymaps for remotely navigating the preview window
-- This includes:
-- - <S-Up> and <S-Down> to scroll the preview window up and down
--
---@param main_popup NuiPopup
---@param preview_popup NuiPopup
---@param opts? { scrollup_key: string, scrolldown_key: string }
M.set_keymaps_for_preview_remote_nav = function(main_popup, preview_popup, opts)
  opts = vim.tbl_extend("force", {
    scrollup_key = "<S-Up>",
    scrolldown_key = "<S-Down>",
  }, opts or {})

  main_popup:map("t", opts.scrollup_key, function()
    -- Setting current window to right window will cause scrollbar to refresh as well
    vim.api.nvim_set_current_win(preview_popup.winid)
    vim.api.nvim_input("<S-Up>")
    vim.schedule(function() vim.api.nvim_set_current_win(main_popup.winid) end)
  end)
  main_popup:map("t", opts.scrolldown_key, function()
    vim.api.nvim_set_current_win(preview_popup.winid)
    vim.api.nvim_input("<S-Down>")
    vim.schedule(function() vim.api.nvim_set_current_win(main_popup.winid) end)
  end)
end

-- FIX
-- M.set_keymaps_for_fzf_preview = function(main_popup, opts)
--   opts = vim.tbl_extend("force", {
--     scrollup_preview_from_main_popup = "<S-Up>",
--     scrolldown_preview_from_main_popup = "<S-Down>",
--   }, opts or {})
--
--   main_popup:map( -- TODO
--     "t",
--     opts.scrollup_preview_from_main_popup,
--     function() vim.api.nvim_input("<M-a>") end
--   )
--   vim.keymap.set(
--     "t",
--     opts.scrolldown_preview_from_main_popup,
--     function() vim.api.nvim_input("<M-b>") end
--   )
-- end

M.default_fzf_keybinds = {
  ["shift-up"] = "preview-up+preview-up+preview-up+preview-up+preview-up",
  ["shift-down"] = "preview-down+preview-down+preview-down+preview-down+preview-down",
  -- ["alt-a"] = "preview-up",
  -- ["alt-b"] = "preview-down",
}

-- TODO: cleanup layout code

-- Create a simple window layout for Fzf that includes only a main window
--
---@return NuiLayout, { main: NuiPopup }
M.create_fzf_preview_layout = function()
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
        width = "95%",
        height = "95%",
      },
    },
    Layout.Box({
      Layout.Box(main_popup, { size = "100%" }),
    }, {})
  )

  vim.api.nvim_create_autocmd({ "BufEnter" }, {
    buffer = main_popup.bufnr,
    callback = function(ctx) vim.cmd("startinsert") end,
  })

  return layout, {
    main = main_popup,
  }
end

-- Create a window layout for Fzf that includes:
-- - a main window
-- - a preview window
---@param opts? { preview_in_terminal_mode?: boolean, preview_popup_win_options?: table<string, any>, preview_popup_buf_options?: table<string, any> }
--
---@return NuiLayout layout, { main: NuiPopup, nvim_preview: NuiPopup } popups, fun(content: string[]): nil set_preview_content
M.create_nvim_preview_layout = function(opts)
  opts = vim.tbl_extend("force", {
    preview_in_terminal_mode = false,
    preview_popup_win_options = {},
    preview_popup_buf_options = {},
  }, opts or {})

  local main_popup = Popup({
    enter = true,
    focusable = true,
    border = {
      style = "rounded",
      text = {
        top = "", -- FIX: border text not showing if undefined
        bottom = "",
        top_align = "center",
        bottom_align = "center",
      },
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
        top = "", -- FIX: border text not showing if undefined
        bottom = "",
        top_align = "center",
        bottom_align = "center",
      },
    },
    buf_options = vim.tbl_extend("force", {
      filetype = opts.preview_in_terminal_mode and "terminal" or "",
      modifiable = true,
      synmaxcol = 0,
    }, opts.preview_popup_buf_options),
    win_options = vim.tbl_extend("force", {
      winblend = 0,
      winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
      number = true,
      conceallevel = opts.preview_in_terminal_mode and 3 or 0,
      concealcursor = "nvic",
    }, opts.preview_popup_win_options),
  })

  local popups = { main = main_popup, nvim_preview = nvim_preview_popup }

  local layout = Layout(
    {
      position = "50%",
      relative = "editor",
      size = {
        width = "95%",
        height = "95%",
      },
    },
    Layout.Box({
      Layout.Box(main_popup, { size = "50%" }),
      Layout.Box(nvim_preview_popup, { size = "50%" }),
    }, { dir = "row" })
  )

  vim.api.nvim_create_autocmd({ "BufEnter" }, {
    buffer = main_popup.bufnr,
    callback = function(ctx) vim.cmd("startinsert") end,
  })

  return layout,
    popups,
    function(content)
      vim.api.nvim_buf_set_lines(
        popups.nvim_preview.bufnr,
        0,
        -1,
        false,
        content
      )

      if opts.preview_in_terminal_mode then
        vim.bo[popups.nvim_preview.bufnr].filetype = "terminal"
      end

      local current_win = vim.api.nvim_get_current_win()

      -- Switch to preview window and back in order to refresh scrollbar
      -- TODO: Remove this once scrollbar plugin support remote refresh
      vim.api.nvim_set_current_win(popups.nvim_preview.winid)
      vim.api.nvim_set_current_win(current_win)
    end
end

-- Create a window layout for Fzf that includes:
-- - a main window
-- - two preview windows. One for before and one for after
---@param opts? { preview_popups_win_options?: table<string, any>, preview_popups_buf_options?: table<string, any> }
--
---@return NuiLayout layout, { main: NuiPopup, nvim_previews: { before: NuiPopup, after: NuiPopup } } popups, fun(before: string[], after: string[], opts?: {}): nil set_preview_content
M.create_nvim_diff_preview_layout = function(opts)
  opts = vim.tbl_extend("force", {
    preview_popups_win_options = {},
    preview_popups_buf_options = {},
  }, opts or {})

  local main_popup = Popup({
    enter = true,
    focusable = true,
    border = {
      style = "rounded",
      text = {
        top = "", -- FIX: border text not showing if undefined
        bottom = "",
        top_align = "center",
        bottom_align = "center",
      },
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

  local nvim_preview_popups = {
    before = Popup({
      enter = false,
      focusable = true,
      border = {
        style = "rounded",
        text = {
          top = "", -- FIX: border text not showing if undefined
          bottom = "",
          top_align = "center",
          bottom_align = "center",
        },
      },
      buf_options = vim.tbl_extend("force", {
        modifiable = true,
      }, opts.preview_popups_buf_options),
      win_options = vim.tbl_extend("force", {
        winblend = 0,
        winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
        number = true,
      }, opts.preview_popups_win_options),
    }),
    after = Popup({
      enter = false,
      focusable = true,
      border = {
        style = "rounded",
        text = {
          top = "", -- FIX: border text not showing if undefined
          bottom = "",
          top_align = "center",
          bottom_align = "center",
        },
      },
      buf_options = vim.tbl_extend("force", {
        modifiable = true,
      }, opts.preview_popups_buf_options),
      win_options = vim.tbl_extend("force", {
        winblend = 0,
        winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
        number = true,
      }, opts.preview_popups_win_options),
    }),
  }

  local popups = { main = main_popup, nvim_previews = nvim_preview_popups }

  local layout = Layout(
    {
      position = "50%",
      relative = "editor",
      size = {
        width = "95%",
        height = "95%",
      },
    },
    Layout.Box({
      Layout.Box(main_popup, { size = "30%" }),
      Layout.Box({
        Layout.Box(nvim_preview_popups.before, { size = "50%" }),
        Layout.Box(nvim_preview_popups.after, { size = "50%" }),
      }, { dir = "row", size = "70%" }),
    }, { dir = "col" })
  )

  vim.api.nvim_create_autocmd({ "BufEnter" }, {
    buffer = main_popup.bufnr,
    callback = function(ctx) vim.cmd("startinsert") end,
  })

  return layout,
    popups,
    function(before, after, opts)
      opts = vim.tbl_extend("force", {}, opts or {})

      local ft = opts.filetype
      if not ft then
        ft = vim.filetype.match({
          contents = before,
        })
        if not ft then
          ft = vim.filetype.match({
            contents = after,
          })
        end
        if not ft then vim.warn("Unable to autodetect filetype") end
      end

      vim.api.nvim_buf_set_lines(
        popups.nvim_previews.before.bufnr,
        0,
        -1,
        false,
        before
      )
      vim.api.nvim_win_call(
        popups.nvim_previews.before.winid,
        function() vim.cmd("diffthis") end
      )

      vim.api.nvim_buf_set_lines(
        popups.nvim_previews.after.bufnr,
        0,
        -1,
        false,
        after
      )
      vim.api.nvim_win_call(
        popups.nvim_previews.after.winid,
        function() vim.cmd("diffthis") end
      )

      ---@cast ft string
      vim.bo[popups.nvim_previews.before.bufnr].filetype = ft
      vim.bo[popups.nvim_previews.after.bufnr].filetype = ft

      local current_win = vim.api.nvim_get_current_win()

      -- Switch to preview window and back in order to refresh scrollbar
      -- TODO: Remove this once scrollbar plugin support remote refresh
      vim.api.nvim_set_current_win(popups.nvim_previews.before.winid)
      vim.api.nvim_set_current_win(popups.nvim_previews.after.winid)
      vim.api.nvim_set_current_win(current_win)
    end
end

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

return M
