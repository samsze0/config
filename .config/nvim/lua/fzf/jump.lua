local M = {}

local core = require("fzf.core")
local helpers = require("fzf.helpers")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local jumplist = require("jumplist")

local fn = vim.fn

-- Show jump tree
--
---@param opts? { max_num_entries?: number }
M.jumps = function(opts)
  opts = vim.tbl_extend("force", {
    max_num_entries = 100,
  }, opts or {})

  local jumps

  local pos
  local win = vim.api.nvim_get_current_win()

  local function get_entries()
    jumps, pos = jumplist.get_jumps_as_list(
      win,
      { max_num_entries = opts.max_num_entries }
    )
    pos = pos or 0

    return utils.map(
      jumps,
      function(_, e)
        return fzf_utils.join_by_delim(
          utils.ansi_codes.grey(e.filename),
          e.line,
          e.col,
          e.text
        )
      end
    )
  end

  core.fzf(get_entries(), {
    prompt = "Jumps",
    initial_position = pos,
    preview_cmd = string.format(
      [[bat %s --highlight-line {2} {1}]],
      helpers.bat_default_opts
    ),
    binds = vim.tbl_extend("force", helpers.default_fzf_keybinds, {
      ["+select"] = function(state)
        local jump = jumps[state.focused_entry_index]

        vim.cmd(string.format([[e %s]], jump.filename))
        vim.cmd(string.format([[normal! %sG%s|]], jump.line, jump.col))
      end,
    }),
    extra_args = vim.tbl_extend("force", helpers.fzf_default_args, {
      ["--with-nth"] = "1,4..",
      ["--preview-window"] = string.format(
        [['%s,%s']],
        helpers.fzf_default_preview_window_args,
        fzf_utils.preview_offset("{2}", { fixed_header = 3 })
      ),
    }),
  })
end

return M
