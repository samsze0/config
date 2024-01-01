-- Tweaked from:
-- https://github.com/debugloop/telescope-undo.nvim/blob/main/lua/telescope-undo/init.lua

local M = {}

-- Construct the delta string for a specific undo
--
---@param buf integer
---@param undo_seq_nr integer
---@param opts? { diff_context_lines?: integer }
---@return string, string, string[], string[]
function M.show_undo_diff_with_delta(buf, undo_seq_nr, opts)
  opts = vim.tbl_extend("force", {
    diff_context_lines = 10,
  }, opts or {})

  local before_lines, after_lines =
    M.get_undo_before_and_after(buf, undo_seq_nr)

  local before = table.concat(before_lines, "\n")
  local after = table.concat(after_lines, "\n")

  -- create temporary vars and prepare this iteration
  local diff = ""
  local brief = ""
  local additions = {}
  local deletions = {}

  vim.diff(before, after, {
    result_type = "indices",
    algorithm = "patience",
    on_hunk = function(start_a, count_a, start_b, count_b)
      local current_file = vim.fn.expand("%")
      diff = "--- " .. current_file .. "\n+++ " .. current_file .. "\n"

      -- Location header
      diff = diff .. "@@ -" .. start_a
      if count_a ~= 1 then diff = diff .. "," .. count_a end
      diff = diff .. " +" .. start_b
      if count_b ~= 1 then diff = diff .. "," .. count_b end
      diff = diff .. " @@"

      -- Context lines before the hunk
      for j = start_a - opts.diff_context_lines, start_a - 1 do
        if before_lines[j] ~= nil then
          diff = diff .. "\n " .. before_lines[j]
        end
      end

      -- Deletions
      for j = start_a, start_a + count_a - 1 do
        diff = diff .. "\n-" .. before_lines[j]
        table.insert(deletions, before_lines[j])
        brief = brief .. before_lines[j]
      end

      brief = brief .. " -> "

      -- Additions
      for j = start_b, start_b + count_b - 1 do
        diff = diff .. "\n+" .. after_lines[j]
        table.insert(additions, after_lines[j])
        brief = brief .. after_lines[j]
      end

      -- Context lines after the hunk
      for j = start_a + count_a, start_a + count_a + opts.diff_context_lines - 1 do
        if before_lines[j] ~= nil then
          diff = diff .. "\n " .. before_lines[j]
        end
      end

      diff = diff .. "\n"
    end,
  })

  brief = vim.trim(brief)
  if brief:len() == 0 then brief = "<empty>" end

  return diff, brief, additions, deletions
end

-- Get the before and after (buffer content) of a specific undo
--
---@param buf integer
---@param undo_seq_nr integer
---@return string[], string[]
M.get_undo_before_and_after = function(buf, undo_seq_nr)
  return unpack(vim.api.nvim_buf_call(buf, function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local undotree = vim.fn.undotree()
    local current_seq_nr = undotree.seq_cur ---@diagnostic disable-line: undefined-field

    vim.cmd("undo " .. undo_seq_nr)
    local after = vim.api.nvim_buf_get_lines(0, 0, -1, false)

    vim.cmd("undo")
    local before = vim.api.nvim_buf_get_lines(0, 0, -1, false)

    vim.cmd("undo " .. current_seq_nr)
    vim.api.nvim_win_set_cursor(0, cursor)

    return { before, after } ---@diagnostic disable-line: redundant-return-value
  end))
end

return M
