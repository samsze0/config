local M = {}

local core = require("fzf.core")
local config = require("fzf.config")
local fzf_utils = require("fzf.utils")
local helpers = require("fzf.helpers")
local utils = require("utils")
local fzf_git = require("fzf.git")
local fzf_files = require("fzf.files")
local fzf_jump = require("fzf.jump")

local fn = vim.fn

M.tabs = function()
  local function get_entries()
    local entries = utils.map(fn.gettabinfo(), function(_, tab)
      local tabnr = tab.tabnr

      return fzf_utils.create_fzf_entry(
        tabnr,
        _G.tabs[tabnr].full or "  ",
        utils.ansi_codes.blue(_G.tabs[tabnr].display or "  ")
      )
    end)
    return entries
  end

  local current_tabnr = fn.tabpagenr()

  local get_tabnr_from_selection = function()
    local selection = FZF.current_selection

    return vim.split(selection, utils.nbsp)[1]
  end

  core.fzf(get_entries(), {
    fzf_on_select = function()
      local tabnr = get_tabnr_from_selection()
      vim.cmd(string.format([[tabnext %s]], tabnr))
    end,
    fzf_preview_cmd = string.format([[bat %s {2}]], helpers.bat_default_opts),
    fzf_extra_args = helpers.fzf_default_args
      .. " --with-nth=1,3 --preview-window="
      .. helpers.fzf_default_preview_window_args,
    fzf_prompt = "Tabs",
    fzf_initial_position = current_tabnr,
    fzf_binds = {
      ["ctrl-x"] = function()
        local tabnr = get_tabnr_from_selection()
        vim.cmd(string.format([[tabclose %s]], tabnr))
        core.send_to_fzf(fzf_utils.generate_fzf_reload_action(get_entries()))
      end,
    },
    fzf_on_focus = function() end,
  })
end

M.buffers = function()
  local fzf_initial_pos = fn.bufnr()

  local function get_entries()
    local current_bufnr = fn.bufnr()

    -- Get all buffers
    local entries = utils.map(fn.getbufinfo({ buflisted = 1 }), function(i, buf)
      local bufnr = buf.bufnr
      local full_bufname = buf.name
      local bufname = vim.fn.fnamemodify(full_bufname, ":~:.")
      local modified = buf.changed == 1
      local readonly = buf.readonly == 1
      local buftype = buf.buftype
      local modified_icon = modified and "  " or ""

      local readonly_icon = readonly and "  " or ""
      local icon = modified_icon .. readonly_icon

      if bufnr == current_bufnr then fzf_initial_pos = i end

      return fzf_utils.create_fzf_entry(
        bufnr,
        full_bufname,
        utils.ansi_codes.blue(bufname .. icon)
      )
    end)
    return entries
  end

  local get_bufnr_from_selection = function()
    local selection = FZF.current_selection

    return vim.split(selection, utils.nbsp)[1]
  end

  core.fzf(get_entries(), {
    fzf_on_select = function()
      local bufnr = get_bufnr_from_selection()
      vim.cmd(string.format([[buffer %s]], bufnr))
    end,
    fzf_preview_cmd = string.format([[bat %s {2}]], helpers.bat_default_opts),
    fzf_extra_args = helpers.fzf_default_args
      .. " --with-nth=1,3 --preview-window="
      .. helpers.fzf_default_preview_window_args,
    fzf_prompt = "Buffers",
    fzf_initial_position = fzf_initial_pos,
    fzf_binds = {
      ["ctrl-x"] = function()
        local bufnr = get_bufnr_from_selection()
        vim.cmd(string.format([[bdelete %s]], bufnr))
        core.send_to_fzf(fzf_utils.generate_fzf_reload_action(get_entries()))
      end,
    },
    fzf_on_focus = function() end,
  })
end

M.loclist = function(opts)
  opts = vim.tbl_extend("force", {}, opts or {})

  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()

  local function get_entries()
    local ll = vim.fn.getloclist(win)

    return utils.map(
      ll,
      function(_, l)
        return fzf_utils.create_fzf_entry(
          l.bufnr,
          utils.ansi_codes.grey(
            vim.fn.fnamemodify(vim.api.nvim_buf_get_name(l.bufnr), ":~:.")
          ),
          l.lnum,
          l.col,
          l.text
        )
      end
    )
  end

  local entries = get_entries()

  local parse_selection = function()
    local selection = FZF.current_selection

    return unpack(vim.split(selection, utils.nbsp))
  end

  core.fzf(entries, {
    fzf_on_select = function()
      local bufnr = parse_selection()
      vim.cmd(string.format([[buffer %s]], bufnr))
    end,
    fzf_preview_cmd = string.format(
      [[bat %s --highlight-line {3} {2}]],
      helpers.bat_default_opts
    ),
    fzf_extra_args = helpers.fzf_default_args
      .. " --with-nth=2,5 "
      .. string.format(
        "--preview-window='%s,%s'",
        helpers.fzf_default_preview_window_args,
        fzf_utils.fzf_initial_preview_scroll_offset("{3}", { fixed_header = 3 })
      ),
    fzf_prompt = "Loclist",
    fzf_binds = {
      ["ctrl-w"] = function()
        vim.cmd([[ldo update]]) -- Write all changes
      end,
    },
    fzf_on_focus = function() end,
  })
end

return M
