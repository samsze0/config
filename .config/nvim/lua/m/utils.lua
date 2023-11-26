local M = {}

M.map = function(tbl, func)
  local new_tbl = {}
  for i, v in ipairs(tbl) do
    local result = func(i, v)
    if result ~= nil then
      table.insert(new_tbl, result)
    end
  end
  return new_tbl
end

M.split_string = function(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
    table.insert(t, str)
  end
  return t
end

M.show_content_as_buf = function(buf_lines)
  local buf_nr = vim.api.nvim_create_buf(false, false)

  vim.api.nvim_buf_set_lines(buf_nr, 0, -1, false, buf_lines)
  vim.api.nvim_set_current_buf(buf_nr)
  vim.api.nvim_buf_call(buf_nr, function()
    vim.cmd("filetype detect")
  end)
end

M.contains = function(tbl, str)
  for i, v in ipairs(tbl) do
    if v == str then
      return true
    end
  end
  return false
end

M.get_keys_as_string = function(tbl)
  local keys = ""
  for key, _ in pairs(tbl) do
    keys = keys .. key .. ", "
  end
  -- Remove the last comma and space
  keys = keys:sub(1, -3)
  return keys
end

M.get_command_history = function()
  local history = {}
  for i = 1, vim.fn.histlen(":") do
    table.insert(history, vim.fn.histget(":", i))
  end
  return history
end

M.get_register_length = function(reg)
  local content = vim.fn.getreg(reg)
  return #content
end

M.run_and_notify = function(f, msg)
  return function()
    f()
    vim.notify(msg)
  end
end

M.get_undo_before_and_after = function(seq)
  vim.cmd("silent undo " .. seq)
  local buffer_after = vim.api.nvim_buf_get_lines(0, 0, -1, false) or {}

  vim.cmd("silent undo")
  local buffer_before = vim.api.nvim_buf_get_lines(0, 0, -1, false) or {}

  return { buffer_before, buffer_after }
end

M.open_diff_in_new_tab = function(buf1_content, buf2_content)
  vim.api.nvim_command("tabnew")
  M.show_content_as_buf(buf1_content)
  vim.api.nvim_command("diffthis")

  vim.api.nvim_command("vsplit")
  vim.api.nvim_command("wincmd l")
  M.show_content_as_buf(buf2_content)
  vim.api.nvim_command("diffthis")
end

-- Tweaked from:
-- https://github.com/debugloop/telescope-undo.nvim/blob/main/lua/telescope-undo/init.lua

local function traverse_undotree(opts, entries, alt_level)
  local undolist = {}
  -- create diffs for each entry in our undotree
  for i = #entries, 1, -1 do
    local undo_before_and_after = M.get_undo_before_and_after(entries[i].seq)

    local before_lines = undo_before_and_after[1]
    local before = table.concat(before_lines, "\n")
    local after_lines = undo_before_and_after[2]
    local after = table.concat(after_lines, "\n")

    -- create temporary vars and prepare this iteration
    local diff = ""
    local brief = ""
    local additions = {}
    local deletions = {}
    local on_hunk_callback = function(start_a, count_a, start_b, count_b)
      -- build diff file header for this hunk, this is important for delta to syntax highlight
      -- TODO: timestamps are being omitted, but could be included here
      diff = vim.fn.expand("%")
      diff = "--- " .. diff .. "\n+++ " .. diff .. "\n"
      -- build diff location header for this hunk, this is important for delta to show line numbers
      diff = diff .. "@@ -" .. start_a
      if count_a ~= 1 then
        diff = diff .. "," .. count_a
      end
      diff = diff .. " +" .. start_b
      if count_b ~= 1 then
        diff = diff .. "," .. count_b
      end
      diff = diff .. " @@"
      -- get front context based on options
      local context_lines = 0


      if opts.diff_context_lines ~= nil then
        context_lines = opts.diff_context_lines
      end
      for j = start_a - context_lines, start_a - 1 do
        if before_lines[j] ~= nil then
          diff = diff .. "\n " .. before_lines[j]
        end
      end
      -- get deletions
      for j = start_a, start_a + count_a - 1 do
        diff = diff .. "\n-" .. before_lines[j]
        table.insert(deletions, before_lines[j])
        brief = brief .. before_lines[j]
      end
      brief = brief .. " -> "
      -- get additions
      for j = start_b, start_b + count_b - 1 do
        diff = diff .. "\n+" .. after_lines[j]
        table.insert(additions, after_lines[j])
        brief = brief .. before_lines[j]
      end
      -- and finally, get some more context in the back
      for j = start_a + count_a, start_a + count_a + context_lines - 1 do
        if before_lines[j] ~= nil then
          diff = diff .. "\n " .. before_lines[j]
        end
      end
      -- terminate all this with a newline, so we're ready for the next hunk
      diff = diff .. "\n"
    end

    vim.diff(before, after, {
      result_type = "indices",
      on_hunk = on_hunk_callback,
      algorithm = "patience",
    })

    brief = vim.trim(brief)
    if #brief > 80 then
      brief = brief:sub(1, 80) .. "..."
    end
    if #brief == 0 then
      brief = "<empty>"
    end

    table.insert(undolist, {
      seq = entries[i].seq,  -- save state number, used in display and to restore
      alt_level = alt_level, -- current level, i.e. how deep into alt branches are we, used to graph
      first = i == #entries, -- whether this is the first node in this branch, used to graph
      timestamp = entries[i].time,
      time = require('m.timeago').timeago(entries[i].time),
      brief = brief,         -- brief message to describe the change
      diff = diff,           -- the proper diff, used for preview
      additions = additions, -- all additions, used to yank a result
      deletions = deletions, -- all deletions, used to yank a result
      bufnr = vim.api.nvim_get_current_buf(),
    })

    -- descend recursively into alternate histories of undo states
    if entries[i].alt ~= nil then
      local alt_undolist = traverse_undotree(opts, entries[i].alt, alt_level + 1)
      for _, elem in pairs(alt_undolist) do
        table.insert(undolist, elem)
      end
    end
  end
  return undolist
end

M.get_undolist = function(opts)
  opts = opts or {}
  opts = vim.tbl_deep_extend("force", opts, {
    diff_context_lines = 10, -- Number of surrounding lines to add to the preview for context
  })

  -- save our current cursor
  local cursor = vim.api.nvim_win_get_cursor(0)

  -- get all diffs of current buf
  local ut = vim.fn.undotree()
  -- TODO: maybe use this opportunity to limit the number of root nodes we process overall, to ensure good performance
  local undolist = traverse_undotree(opts, ut.entries, 0)

  -- restore everything after all diffs have been created
  -- BUG: `gi` (last insert location) is being killed by our method, we should save that as well
  vim.cmd("silent undo " .. ut.seq_cur)
  vim.api.nvim_win_set_cursor(0, cursor)

  return undolist
end

return M
