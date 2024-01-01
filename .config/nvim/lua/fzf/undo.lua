local M = {}

local core = require("fzf.core")
local helpers = require("fzf.helpers")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local undo_utils = require("utils.undo")
local timeago = require("utils.timeago")

---@param opts? {}
M.undos = function(opts)
  opts = vim.tbl_extend("force", {}, opts or {})

  local fzf_initial_pos = 0

  local function get_entries()
    local undotree = vim.fn.undotree()
    local undotree_entries = undotree.entries ---@diagnostic disable-line: undefined-field
    local current_undo = undotree.seq_cur ---@diagnostic disable-line: undefined-field

    local entries = {}

    local function process_undos(undos, alt_level)
      alt_level = alt_level or 0

      for i = #undos, 1, -1 do
        local undo = undos[i]
        local seq_nr = undo.seq ---@diagnostic disable-line: undefined-field
        local time = undo.time ---@diagnostic disable-line: undefined-field
        local alt = undo.alt ---@diagnostic disable-line: undefined-field
        time = timeago(time)

        if seq_nr == current_undo then fzf_initial_pos = #entries + 1 end

        table.insert(
          entries,
          fzf_utils.create_fzf_entry(
            seq_nr,
            string.rep("⋅", alt_level + 1),
            time
          )
        )

        if alt then process_undos(alt, alt_level + 1) end
      end
    end

    process_undos(undotree_entries)

    return entries
  end

  local buf = vim.api.nvim_get_current_buf()
  local entries = get_entries()
  vim.info(entries)

  ---@return integer, string, string
  local parse_selection = function()
    local selection = FZF.current_selection

    local undo_nr_str, alt_indent, time =
      unpack(vim.split(selection, utils.nbsp))
    local undo_nr = tonumber(undo_nr_str)
    ---@cast undo_nr integer
    return undo_nr, alt_indent, time
  end

  core.fzf(entries, {
    fzf_on_select = function()
      local undo_nr = parse_selection()

      vim.cmd(string.format("undo %s", undo_nr))
      vim.notify(string.format("Restored to %s", undo_nr))
    end,
    fzf_initial_position = fzf_initial_pos,
    fzf_preview_cmd = nil,
    fzf_prompt = "Undos",
    fzf_on_focus = function()
      local undo_nr = parse_selection()
      local delta_str, brief, additions, deletions =
        undo_utils.show_undo_diff_with_delta(buf, undo_nr)

      core.send_to_fzf(
        "change-preview:"
          .. string.format(
            [[cat %s | delta %s --file-style=omit]],
            fzf_utils.write_to_tmpfile(delta_str),
            helpers.delta_default_opts
          )
      )
    end,
    fzf_binds = vim.tbl_extend("force", helpers.custom_fzf_keybinds, {
      ["ctrl-y"] = function()
        local undo_nr = parse_selection()
        vim.fn.setreg("+", undo_nr)
        vim.notify(string.format("Copied %s to clipboard", undo_nr))
      end,
      ["ctrl-o"] = function()
        local undo_nr = parse_selection()

        core.abort_and_execute(function()
          local before, after =
            undo_utils.get_undo_before_and_after(buf, undo_nr)
          utils.show_diff(before, after, {
            filetype = vim.bo.filetype,
          })
        end)
      end,
    }),
    fzf_extra_args = helpers.fzf_default_args
      .. " --with-nth=2.. --preview-window="
      .. helpers.fzf_default_preview_window_args,
  })
end

return M
