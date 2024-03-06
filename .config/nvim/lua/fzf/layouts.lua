local Layout = require("nui.layout")
local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event

local M = {}

-- Set keymaps for navigating between popups
--
---@param popup_nav_configs { popup: NuiPopup, key: string, is_terminal: boolean }[]
---@return nil
M._set_keymaps_for_popups_nav = function(popup_nav_configs)
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
M._set_keymaps_for_preview_remote_nav = function(
  main_popup,
  preview_popup,
  opts
)
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

-- FIX: low-level input to trigger Fzf key bind not working
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

---@return NuiPopup
M._generate_main_popup = function()
  local popup = Popup({
    enter = true,
    focusable = true,
    border = {
      style = "rounded",
      text = {
        top = "", -- FIX: border text not showing if undefined
        bottom = "",
        top_align = "left",
        bottom_align = "left",
      },
    },
    buf_options = {
      modifiable = false,
      filetype = "fzf",
    },
    win_options = {
      winblend = 0,
      winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
      wrap = false,
    },
  })

  vim.api.nvim_create_autocmd({ "BufEnter" }, {
    buffer = popup.bufnr,
    callback = function(ctx)
      vim.info("Test")
      vim.cmd("startinsert")
    end,
  })

  return popup
end

-- Create a simple window layout for Fzf that includes only a main window
--
---@return NuiLayout, { main: NuiPopup }
M.create_plain_layout = function()
  local main_popup = M._generate_main_popup()

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

  return layout, {
    main = main_popup,
  }
end

-- Create a window layout for Fzf that includes:
-- - a main window
-- - a preview window
---@param opts? { preview_in_terminal_mode?: boolean, preview_popup_win_options?: table<string, any>, preview_popup_buf_options?: table<string, any> }
--
---@return NuiLayout layout, { main: NuiPopup, nvim_preview: NuiPopup } popups, fun(content: string[]): nil set_preview_content, fzf_binds
M.create_nvim_preview_layout = function(opts)
  opts = vim.tbl_extend("force", {
    preview_in_terminal_mode = false,
    preview_popup_win_options = {},
    preview_popup_buf_options = {},
  }, opts or {})

  local main_popup = M._generate_main_popup()

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
      wrap = false,
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

  local set_preview_content = function(content)
    vim.api.nvim_buf_set_lines(popups.nvim_preview.bufnr, 0, -1, false, content)

    if opts.preview_in_terminal_mode then
      vim.bo[popups.nvim_preview.bufnr].filetype = "terminal"
    end

    local current_win = vim.api.nvim_get_current_win()

    -- Switch to preview window and back in order to refresh scrollbar
    -- TODO: Remove this once scrollbar plugin support remote refresh
    vim.api.nvim_set_current_win(popups.nvim_preview.winid)
    vim.api.nvim_set_current_win(current_win)
  end

  ---@type fzf_binds
  local binds = {
    ["+before-start"] = function(state)
      M._set_keymaps_for_preview_remote_nav(popups.main, popups.nvim_preview)
      popups.main:map(
        "t",
        "<C-f>",
        function() vim.api.nvim_set_current_win(popups.nvim_preview.winid) end
      )
      popups.nvim_preview:map(
        "n",
        "<C-s>",
        function() vim.api.nvim_set_current_win(popups.main.winid) end
      )
    end,
  }

  return layout, popups, set_preview_content, binds
end

-- Create a window layout for Fzf that includes:
-- - a main window
-- - two preview windows. One for before and one for after
---@param opts? { preview_popups_win_options?: table<string, any>, preview_popups_buf_options?: table<string, any> }
--
---@return NuiLayout layout, { main: NuiPopup, nvim_previews: { before: NuiPopup, after: NuiPopup } } popups, fun(before: string[], after: string[], opts?: {}): nil set_preview_content, fzf_binds
M.create_nvim_diff_preview_layout = function(opts)
  opts = vim.tbl_extend("force", {
    preview_popups_win_options = {},
    preview_popups_buf_options = {},
  }, opts or {})

  local main_popup = M._generate_main_popup()

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
      Layout.Box(nvim_preview_popups.before, { size = "35%" }),
      Layout.Box(nvim_preview_popups.after, { size = "35%" }),
    }, { dir = "row" })
  )

  local set_preview_content = function(before, after, opts)
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

  ---@type fzf_binds
  local binds = {
    ["+before-start"] = function(state)
      M._set_keymaps_for_preview_remote_nav(
        popups.main,
        popups.nvim_previews.after
      )
      popups.main:map(
        "t",
        "<C-f>",
        function()
          vim.api.nvim_set_current_win(popups.nvim_previews.before.winid)
        end
      )
      popups.nvim_previews.before:map(
        "n",
        "<C-f>",
        function()
          vim.api.nvim_set_current_win(popups.nvim_previews.after.winid)
        end
      )
      popups.nvim_previews.after:map(
        "n",
        "<C-s>",
        function()
          vim.api.nvim_set_current_win(popups.nvim_previews.before.winid)
        end
      )
      popups.nvim_previews.before:map(
        "n",
        "<C-s>",
        function() vim.api.nvim_set_current_win(popups.main.winid) end
      )
    end,
  }

  return layout, popups, set_preview_content, binds
end

return M
