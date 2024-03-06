local layouts = require("fzf.layouts")

local Layout = require("nui.layout")
local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event

local M = {}

-- TODO: cleanup

---@return NuiLayout, { main: NuiPopup, nvim_preview: NuiPopup, replace: NuiPopup }, fun(): string get_replacement, fun(content: string[]): nil set_preview_content, fzf_binds
function M.create_layout()
  local main_popup = layouts._generate_main_popup()

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

  local replace_popup = Popup({
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
    replace = replace_popup,
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
        Layout.Box(replace_popup, { size = "20%" }),
        Layout.Box(nvim_preview_popup, { grow = 1 }),
      }, { size = "50%", dir = "col" }),
    }, { dir = "row" })
  )

  local function get_replacement()
    return table.concat(
      -- Retrieve all lines (possibly modified)
      vim.fn.getbufline(popups.replace.bufnr, 1, "$"), ---@diagnostic disable-line: param-type-mismatch
      "\r"
    )
  end

  local function set_preview_content(content)
    vim.api.nvim_buf_set_lines(popups.nvim_preview.bufnr, 0, -1, false, content)

    local current_win = vim.api.nvim_get_current_win()

    -- Switch to preview window and back in order to refresh scrollbar
    -- TODO: Remove this once scrollbar plugin support remote refresh
    vim.api.nvim_set_current_win(popups.nvim_preview.winid)
    vim.api.nvim_set_current_win(current_win)
  end

  ---@type fzf_binds
  local binds = {
    ["+before-start"] = function(state)
      layouts._set_keymaps_for_preview_remote_nav(
        popups.main,
        popups.nvim_preview
      )
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
      popups.nvim_preview:map(
        "n",
        "<C-e>",
        function() vim.api.nvim_set_current_win(popups.replace.winid) end
      )
      popups.replace:map(
        "n",
        "<C-d>",
        function() vim.api.nvim_set_current_win(popups.nvim_preview.winid) end
      )
      popups.replace:map(
        "n",
        "<C-s>",
        function() vim.api.nvim_set_current_win(popups.main.winid) end
      )
      layouts._set_keymaps_for_popups_nav({
        { popup = popups.main, key = "<C-s>", is_terminal = true },
        { popup = popups.nvim_preview, key = "<C-f>", is_terminal = false },
        { popup = popups.replace, key = "<C-r>", is_terminal = false },
      })
    end,
  }

  return layout, popups, get_replacement, set_preview_content, binds
end

return M
