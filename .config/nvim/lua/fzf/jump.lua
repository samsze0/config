local M = {}

local core = require("fzf.core")
local helpers = require("fzf.helpers")
local config = require("fzf.config")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local jumplist = require("jumplist")

local fn = vim.fn

M.jumps = function(opts)
  opts = vim.tbl_extend("force", {
    max_num_entries = 100,
  }, opts or {})

  local jumps
  local fzf_initial_pos
  local win_id = vim.api.nvim_get_current_win()

  local function get_entries()
    jumps, fzf_initial_pos = jumplist.get_jumps_as_list(
      win_id,
      { max_num_entries = opts.max_num_entries }
    )
    fzf_initial_pos = fzf_initial_pos or 0

    return utils.map(
      jumps,
      function(_, e)
        return fzf_utils.create_fzf_entry(
          utils.ansi_codes.grey(e.filename),
          e.line,
          e.col,
          e.text
        )
      end
    )
  end

  local get_selection = function()
    local selection = FZF_STATE.current_selection
    local args = vim.split(selection, utils.nbsp)
    local node = jumps[FZF_STATE.current_selection_index]
    return unpack(args), node
  end

  core.fzf(get_entries(), {
    fzf_prompt = "Jumps",
    fzf_initial_position = fzf_initial_pos,
    before_fzf = helpers.set_custom_keymaps_for_fzf_preview,
    fzf_binds = vim.tbl_extend("force", helpers.custom_fzf_keybinds, {}),
    fzf_on_focus = function() end,
    fzf_on_select = function()
      local filename, row, col = get_selection()
      vim.cmd(string.format([[e %s]], filename))
      vim.cmd(string.format([[normal! %sG%s|]], row, col))
    end,
    fzf_preview_cmd = string.format(
      [[bat %s --highlight-line {2} {1}]],
      helpers.bat_default_opts
    ),
    fzf_extra_args = helpers.fzf_default_args
      .. " --with-nth=1,4 "
      .. string.format(
        "--preview-window=%s,%s",
        helpers.fzf_default_preview_window_args,
        fzf_utils.fzf_initial_preview_scroll_offset("{2}", { fixed_header = 3 })
      ),
  })
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

      return fzf_utils.create_fzf_entry(j.row, j.col, filepath)
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
    fzf_extra_args = helpers.fzf_default_args
      .. " --with-nth=1,3 " -- Hide col number
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
