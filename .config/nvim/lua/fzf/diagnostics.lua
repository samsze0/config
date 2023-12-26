local M = {}

local core = require("fzf.core")
local helpers = require("fzf.helpers")
local config = require("fzf.config")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local uv = vim.loop
local uv_utils = require("utils.uv")
local jumplist = require("jumplist")

M.diagnostics = function(opts)
  opts = vim.tbl_extend("force", {
    severity = { min = vim.diagnostic.severity.WARN },
    current_buffer_only = false,
  }, opts or {})

  local bufnr = vim.api.nvim_get_current_buf()
  local current_file = vim.api.nvim_buf_get_name(bufnr)
  current_file = vim.fn.fnamemodify(current_file, ":~:.")
  local win_id = vim.api.nvim_get_current_win()

  local function get_entries()
    local diagnostics = vim.diagnostic.get(
      opts.current_buffer_only and bufnr or nil,
      { severity = opts.severity }
    )
    return utils.map(diagnostics, function(i, e)
      local filename = opts.current_buffer_only and current_file
        or vim.fn.fnamemodify(vim.api.nvim_buf_get_name(e.bufnr), ":~:.")
      diagnostics[i].filename = filename

      return fzf_utils.create_fzf_entry(
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

  local get_selection = function()
    return diagnostics[FZF.current_selection_index]
  end

  core.fzf(entries, {
    fzf_on_select = function()
      local symbol = get_selection()

      jumplist.save(win_id)
      if not opts.current_buffer_only then
        vim.cmd(string.format([[e %s]], symbol.filename))
      end
      vim.fn.cursor({ symbol.lnum + 1, symbol.col })
      vim.cmd("normal! zz")
    end,
    fzf_preview_cmd = string.format(
      "bat %s --highlight-line {4} {3}",
      helpers.bat_default_opts
    ),
    fzf_extra_args = helpers.fzf_default_args
      .. string.format(
        " --with-nth=%s ",
        opts.current_buffer_only and "1,2,6.." or "1,2,6.."
      )
      .. string.format(
        "--preview-window=%s,%s",
        helpers.fzf_default_preview_window_args,
        fzf_utils.fzf_initial_preview_scroll_offset("{4}", { fixed_header = 3 })
      ),
    fzf_prompt = "Diagnostics",
    fzf_binds = vim.tbl_extend("force", helpers.custom_fzf_keybinds, {
      ["ctrl-w"] = function()
        local symbol = get_selection()
        core.abort_and_execute(function()
          vim.cmd(string.format([[vsplit %s]], current_file))
          vim.cmd(
            string.format([[normal! %sG%s|]], symbol.lnum + 1, symbol.col)
          )
          vim.cmd([[normal! zz]])
        end)
      end,
      ["ctrl-t"] = function()
        local symbol = get_selection()
        core.abort_and_execute(function()
          vim.cmd(string.format([[tabnew %s]], current_file))
          vim.cmd(
            string.format([[normal! %sG%s|]], symbol.lnum + 1, symbol.col)
          )
          vim.cmd([[normal! zz]])
        end)
      end,
    }),
    fzf_on_focus = function() end,
  })
end

return M
