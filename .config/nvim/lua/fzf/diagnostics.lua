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

  local current_win = vim.api.nvim_get_current_win()
  local current_buf = vim.api.nvim_get_current_buf()

  local current_file = vim.api.nvim_buf_get_name(current_buf)
  current_file = vim.fn.fnamemodify(current_file, ":~:.")

  local function get_entries()
    local diagnostics = vim.diagnostic.get(
      opts.current_buffer_only and current_buf or nil,
      { severity = opts.severity }
    )
    return utils.map(diagnostics, function(i, e)
      local filename = opts.current_buffer_only and current_file
        or vim.fn.fnamemodify(vim.api.nvim_buf_get_name(e.bufnr), ":~:.") ---@diagnostic disable-line: undefined-field
      diagnostics[i].filename = filename ---@diagnostic disable-line: inject-field

      return fzf_utils.join_by_delim(
        utils.switch(e.severity, {
          [vim.diagnostic.severity.HINT] = utils.ansi_codes.blue("H"),
          [vim.diagnostic.severity.INFO] = utils.ansi_codes.blue("I"),
          [vim.diagnostic.severity.WARN] = utils.ansi_codes.yellow("W"),
          [vim.diagnostic.severity.ERROR] = utils.ansi_codes.red("E"),
        }, "?"),
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

  local parse_entry = function(entry)
    local args = vim.split(entry, utils.nbsp)
    return unpack(args)
  end

  local layout, popups, set_preview_content =
    helpers.create_nvim_preview_layout({
      preview_popup_win_options = {
        cursorline = true,
      },
    })

  core.fzf(entries, {
    prompt = "Diagnostics",
    layout = layout,
    main_popup = popups.main,
    binds = {
      ["+before-start"] = function(state)
        helpers.set_keymaps_for_preview_remote_nav(
          popups.main,
          popups.nvim_preview
        )
        helpers.set_keymaps_for_popups_nav({
          { popup = popups.main, key = "<C-s>", is_terminal = true },
          {
            popup = popups.nvim_preview,
            key = "<C-f>",
            is_terminal = false,
          },
        })
      end,
      ["focus"] = function(state)
        local severity, source, filepath, row, col =
          parse_entry(state.focused_entry)

        popups.nvim_preview.border:set_text(
          "top",
          " " .. vim.fn.fnamemodify(filepath, ":t") .. " "
        )

        helpers.preview_file(
          filepath,
          popups.nvim_preview,
          { cursor_pos = { row = row, col = col } }
        )
      end,
      ["ctrl-w"] = function(state)
        local symbol = diagnostics[state.focused_entry_index]

        core.abort_and_execute(state.id, function()
          vim.cmd(string.format([[vsplit %s]], current_file))
          vim.cmd(
            string.format([[normal! %sG%s|]], symbol.lnum + 1, symbol.col)
          )
          vim.cmd([[normal! zz]])
        end)
      end,
      ["ctrl-t"] = function(state)
        local symbol = diagnostics[state.focused_entry_index]

        core.abort_and_execute(state.id, function()
          vim.cmd(string.format([[tabnew %s]], current_file))
          vim.cmd(
            string.format([[normal! %sG%s|]], symbol.lnum + 1, symbol.col)
          )
          vim.cmd([[normal! zz]])
        end)
      end,
      ["+select"] = function(state)
        local symbol = diagnostics[state.focused_entry_index]

        jumplist.save(current_win)
        if not opts.current_buffer_only then
          vim.cmd(string.format([[e %s]], symbol.filename)) --- @diagnostic disable-line: undefined-field
        end
        vim.fn.cursor({ symbol.lnum + 1, symbol.col })
        vim.cmd("normal! zz")
      end,
    },
    extra_args = vim.tbl_extend("force", helpers.fzf_default_args, {
      ["--with-nth"] = "1,2,6..",
    }),
  })
end

return M
