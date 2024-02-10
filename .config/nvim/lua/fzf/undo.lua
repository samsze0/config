local M = {}

local core = require("fzf.core")
local helpers = require("fzf.helpers")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local undo_utils = require("utils.undo")
local timeago = require("utils.timeago")

-- Fzf undo tree
--
---@param opts? {}
M.undos = function(opts)
  opts = vim.tbl_extend("force", {}, opts or {})

  local initial_pos = 0

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

        if seq_nr == current_undo then initial_pos = #entries + 1 end

        table.insert(
          entries,
          fzf_utils.join_by_delim(
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

  ---@param entry string
  ---@return integer undo_nr, string alt_indent, string time
  local parse_entry = function(entry)
    local undo_nr_str, alt_indent, time = unpack(vim.split(entry, utils.nbsp))
    local undo_nr = tonumber(undo_nr_str)
    ---@cast undo_nr integer
    return undo_nr, alt_indent, time
  end

  local layout, popups, set_preview_content =
    helpers.create_nvim_diff_preview_layout({
      preview_popups_win_options = {},
    })

  core.fzf(entries, {
    prompt = "Undos",
    layout = layout,
    initial_position = initial_pos,
    binds = {
      ["+before-start"] = function(state)
        helpers.set_keymaps_for_preview_remote_nav(
          popups.main,
          popups.nvim_previews.after
        )
        helpers.set_keymaps_for_popups_nav({
          { popup = popups.main, key = "<C-e>", is_terminal = true },
          {
            popup = popups.nvim_previews.before,
            key = "<C-s>",
            is_terminal = false,
          },
          {
            popup = popups.nvim_previews.after,
            key = "<C-f>",
            is_terminal = false,
          },
        })
      end,
      ["ctrl-y"] = function(state)
        local undo_nr = parse_entry(state.focused_entry)
        vim.fn.setreg("+", undo_nr)
        vim.notify(string.format("Copied %s to clipboard", undo_nr))
      end,
      ["ctrl-o"] = function(state)
        local undo_nr = parse_entry(state.focused_entry)

        core.abort_and_execute(state.id, function()
          local before, after =
            undo_utils.get_undo_before_and_after(buf, undo_nr)
          utils.show_diff(
            {
              filetype = vim.bo.filetype,
            },
            { filepath_or_content = before, readonly = true },
            { filepath_or_content = after, readonly = false }
          )
        end)
      end,
      ["focus"] = function(state)
        local undo_nr = parse_entry(state.focused_entry)
        local before, after = undo_utils.get_undo_before_and_after(buf, undo_nr)

        set_preview_content(before, after, { filetype = vim.bo[buf].filetype })
      end,
      ["+select"] = function(state)
        local undo_nr = parse_entry(state.focused_entry)

        vim.cmd(string.format("undo %s", undo_nr))
        vim.notify(string.format("Restored to %s", undo_nr))
      end,
    },
    extra_args = vim.tbl_extend("force", helpers.fzf_default_args, {
      ["--with-nth"] = "2..",
      ["--scroll-off"] = "2",
    }),
  })
end

return M
