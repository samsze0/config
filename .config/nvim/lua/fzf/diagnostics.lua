local M = {}

local core = require("fzf.core")
local helpers = require("fzf.helpers")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local jumplist = require("jumplist")

-- Fzf diagnostics
--
---@param opts? { severity?: { min?: DiagnosticSeverity }, current_buffer_only?: boolean }
M.diagnostics = function(opts)
  opts = vim.tbl_extend("force", {
    severity = { min = vim.diagnostic.severity.WARN },
    current_buffer_only = false,
  }, opts or {})

  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()
  local current_file = vim.api.nvim_buf_get_name(buf)
  current_file = vim.fn.fnamemodify(current_file, ":~:.")

  local function get_entries()
    local diagnostics = vim.diagnostic.get(
      opts.current_buffer_only and buf or nil,
      { severity = opts.severity }
    )
    return utils.map(diagnostics, function(i, e)
      local filename = opts.current_buffer_only and current_file
        or vim.fn.fnamemodify(vim.api.nvim_buf_get_name(e.bufnr), ":~:.") ---@diagnostic disable-line: undefined-field
      diagnostics[i].filename = filename ---@diagnostic disable-line: inject-field

      return fzf_utils.join_by_delim(
        e.severity == vim.diagnostic.severity.HINT
            and utils.ansi_codes.blue("H")
          or e.severity == vim.diagnostic.severity.INFO and utils.ansi_codes.blue(
            "I"
          )
          or e.severity == vim.diagnostic.severity.WARN and utils.ansi_codes.yellow(
            "W"
          )
          or e.severity == vim.diagnostic.severity.ERROR and utils.ansi_codes.red(
            "E"
          )
          or "?",
        utils.ansi_codes.grey(e.source),
        utils.ansi_codes.blue(filename),
        e.lnum + 1,
        e.col,
        e.message
      )
    end),
      diagnostics
  end

  local entries, diagnostics = get_entries()

  core.fzf(entries, {
    prompt = "Diagnostics",
    preview_cmd = string.format(
      "bat %s --highlight-line {4} {3}",
      helpers.bat_default_opts
    ),
    binds = vim.tbl_extend("force", helpers.default_fzf_keybinds, {
      ["ctrl-w"] = function(state)
        local symbol = diagnostics[state.focused_entry_index]

        core.abort_and_execute(function()
          vim.cmd(string.format([[vsplit %s]], current_file))
          vim.cmd(
            string.format([[normal! %sG%s|]], symbol.lnum + 1, symbol.col)
          )
          vim.cmd([[normal! zz]])
        end)
      end,
      ["ctrl-t"] = function(state)
        local symbol = diagnostics[state.focused_entry_index]

        core.abort_and_execute(function()
          vim.cmd(string.format([[tabnew %s]], current_file))
          vim.cmd(
            string.format([[normal! %sG%s|]], symbol.lnum + 1, symbol.col)
          )
          vim.cmd([[normal! zz]])
        end)
      end,
      ["+select"] = function(state)
        local symbol = diagnostics[state.focused_entry_index]

        jumplist.save(win)
        if not opts.current_buffer_only then
          vim.cmd(string.format([[e %s]], symbol.filename)) --- @diagnostic disable-line: undefined-field
        end
        vim.fn.cursor({ symbol.lnum + 1, symbol.col })
        vim.cmd("normal! zz")
      end,
    }),
    extra_args = vim.tbl_extend("force", helpers.fzf_default_args, {
      ["--with-nth"] = "1,2,6..",
      ["--preview-window"] = string.format(
        [['%s,%s']],
        helpers.fzf_default_preview_window_args,
        fzf_utils.preview_offset("{4}", { fixed_header = 3 })
      ),
    }),
  })
end

return M
