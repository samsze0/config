local M = {}

local core = require("fzf.core")
local helpers = require("fzf.helpers")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local undo_utils = require("utils.undo")
local uv_utils = require("utils.uv")

M.undos = function(opts)
  opts = vim.tbl_extend("force", {}, opts or {})

  local undolist = undo_utils.get_undolist({ coroutine = false })

  local function get_entries()
    return utils.map(
      undolist,
      function(i, undo)
        return string.format(
          string.rep("%s", 2, utils.nbsp),
          undo.seq,
          undo.time
        )
      end
    )
  end

  local get_undo_from_selection = function()
    local selection_index = FZF_STATE.current_selection_index

    return undolist[selection_index]
  end

  core.fzf(get_entries(), {
    fzf_on_select = function()
      local undo = get_undo_from_selection()

      vim.cmd(string.format("undo %s", undo.seq))
      vim.notify(string.format("Restore to %s", undo.seq))
    end,
    fzf_preview_cmd = nil,
    fzf_prompt = "Undos",
    fzf_on_focus = function()
      local undo = get_undo_from_selection()

      core.send_to_fzf(
        "change-preview:"
          .. string.format(
            [[cat %s | delta %s --file-style=omit]],
            fzf_utils.write_to_tmpfile(undo.diff),
            helpers.delta_default_opts
          )
      )
    end,
    fzf_binds = vim.tbl_extend("force", helpers.custom_fzf_keybinds, {
      ["ctrl-y"] = function()
        -- Copy the seq to clipboard
        local undo = get_undo_from_selection()
        vim.fn.setreg("+", undo.seq)
        vim.notify(string.format("Copied %s to clipboard", undo.seq))
      end,
      ["ctrl-o"] = function()
        local undo = get_undo_from_selection()

        core.abort_and_execute(function()
          local before, after =
            unpack(undo_utils.get_undo_before_and_after(undo.seq))
          utils.open_diff_in_new_tab(before, after, {
            filetype = vim.bo.filetype,
          })
        end)
      end,
    }),
    fzf_extra_args = "--with-nth=2.. --preview-window="
      .. helpers.fzf_default_preview_window_args,
  })
end

return M
