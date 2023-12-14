local M = {}

local core = require("fzf.core")
local helpers = require("fzf.helpers")
local config = require("fzf.config")
local fzf_utils = require("fzf.utils")
local utils = require("utils")

local fn = vim.fn

M.jumps = function()
  -- TODO

  local fzf_initial_pos

  local function get_entries() end
end

M.builtin_jumps = function()
  local fzf_initial_pos

  local function get_entries()
    fzf_initial_pos = 0

    -- Get all jumps
    local jumplist, current_jump = unpack(fn.getjumplist())

    local jumps = {}
    for i = #jumplist, 1, -1 do
      if i == current_jump then fzf_initial_pos = #jumps end

      local info = jumplist[i]
      local bufname = fn.bufname(info.bufnr)
      local filepath = fn.fnamemodify(bufname, ":~:.")
      if filepath == "~" then goto continue end

      table.insert(jumps, {
        row = info.lnum,
        col = info.col,
        bufnr = info.bufnr,
      })
      ::continue::
    end

    return utils.map(jumps, function(_, j)
      local bufname = fn.bufname(j.bufnr)
      local filepath = fn.fnamemodify(bufname, ":~:.")

      return string.format(
        string.rep("%s", 3, utils.nbsp),
        j.row,
        j.col,
        filepath
      )
    end)
  end

  local get_info_from_selection = function()
    local selection = FZF_STATE.current_selection
    local args = vim.split(selection, utils.nbsp)
    return unpack(args)
  end

  core.fzf(get_entries(), {
    fzf_on_select = function()
      local _, bufnr, lnum, col = get_info_from_selection()
      vim.cmd(string.format([[buffer %s]], bufnr))
      vim.cmd(string.format([[normal! %sG%s|]], lnum, col))
    end,
    fzf_preview_cmd = string.format(
      [[bat %s --highlight-line {1} {3}]],
      helpers.bat_default_opts
    ),
    fzf_extra_args = "--with-nth=1,3 " -- Hide col number
      .. string.format(
        "--preview-window=%s,%s",
        helpers.fzf_default_preview_window_args,
        fzf_utils.fzf_initial_preview_scroll_offset("{1}", { fixed_header = 3 })
      ),
    fzf_prompt = "Jumps",
    fzf_initial_position = fzf_initial_pos,
    fzf_binds = {},
    fzf_on_focus = function() end,
  })
end

return M
