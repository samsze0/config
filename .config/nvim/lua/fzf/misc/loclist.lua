local core = require("fzf.core")
local fzf_utils = require("fzf.utils")
local helpers = require("fzf.helpers")
local utils = require("utils")

local fn = vim.fn

-- Fzf the most recent loclist of current window
--
---@param opts? { }
return function(opts)
  opts = vim.tbl_extend("force", {}, opts or {})

  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()

  local function get_entries()
    local ll = vim.fn.getloclist(win)

    return utils.map(
      ll,
      function(_, l)
        return fzf_utils.join_by_delim(
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

  local parse_entry = function(entry)
    return unpack(vim.split(entry, utils.nbsp))
  end

  core.fzf(entries, {
    prompt = "Loclist",
    preview_cmd = string.format(
      [[bat %s --highlight-line {3} {2}]],
      helpers.bat_default_opts
    ),
    binds = {
      ["+select"] = function(state)
        local bufnr = parse_entry(state.focused_entry)

        vim.cmd(string.format([[buffer %s]], bufnr))
      end,
      ["ctrl-w"] = function(state)
        vim.cmd([[ldo update]]) -- Write all changes
      end,
    },
    extra_args = vim.tbl_extend("force", helpers.fzf_default_args, {
      ["--with-nth"] = "2,5",
      ["--preview-window"] = string.format(
        [['%s,%s']],
        helpers.fzf_default_preview_window_args,
        fzf_utils.preview_offset("{3}", { fixed_header = 3 })
      ),
    }),
  })
end
