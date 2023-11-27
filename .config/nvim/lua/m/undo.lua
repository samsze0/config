-- Tweaked from:
-- https://github.com/debugloop/telescope-undo.nvim/blob/main/lua/telescope-undo/init.lua

local M = {}

local timeago = require('m.timeago')

function M.undolist_entry_producer(opts, entries, alt_level)
  alt_level = alt_level or 0

  return coroutine.create(function()
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

      local entry = {
        seq = entries[i].seq,  -- save state number, used in display and to restore
        alt_level = alt_level, -- current level, i.e. how deep into alt branches are we, used to graph
        first = i == #entries, -- whether this is the first node in this branch, used to graph
        timestamp = entries[i].time,
        time = timeago(entries[i].time),
        brief = brief,         -- brief message to describe the change
        diff = diff,           -- the proper diff, used for preview
        additions = additions, -- all additions, used to yank a result
        deletions = deletions, -- all deletions, used to yank a result
        bufnr = vim.api.nvim_get_current_buf(),
      }

      if opts.debug then
        vim.notify(string.format("Yielding successfully: %s", vim.inspect(entry)))
      end
      coroutine.yield(entry)

      -- descend recursively into alternate histories of undo states
      if entries[i].alt ~= nil then
        local alt_undotree_producer = M.undolist_entry_producer(opts, entries[i].alt, alt_level + 1)
        repeat
          local ok, alt_undolist_entry = coroutine.resume(alt_undotree_producer)
          if not ok then
            error("Failed to produce undotree entry")
          end

          if opts.debug then
            coroutine.yield(alt_undolist_entry)
          end
          coroutine.yield(alt_undolist_entry)
        until coroutine.status(alt_undotree_producer) == "dead"
      end
    end
  end)
end

M.get_undolist = function(opts)
  opts = opts or {}
  opts = vim.tbl_deep_extend("keep", opts, {
    diff_context_lines = 10,  -- Number of surrounding lines to add to the preview for context
    max_entries = 100,        -- Maximum number of entries to process
    debug = false,            -- Whether to log out entry inside coroutine
    coroutine = false,        -- Whether to run as coroutine
    coroutine_callback = nil, -- Callback to invoke that takes the entry as arg
  })

  local undotree = vim.fn.undotree()
  local undolist_entry_producer = M.undolist_entry_producer(opts, undotree.entries)

  if not opts.coroutine then
    if opts.debug then
      vim.notify("Non-coroutine mode")
    end
    local undolist = {}
    for i = 1, opts.max_entries do
      local ok, entry = coroutine.resume(undolist_entry_producer)
      if not ok then
        error("Failed to produce undotree entry: " .. entry)
      end

      if coroutine.status(undolist_entry_producer) == "dead" then
        break
      end
      table.insert(undolist, entry)

      if i == opts.max_entries then
        coroutine.close(undolist_entry_producer)
      end
    end
    return undolist
  else
    if opts.debug then
      vim.notify("Coroutine mode")
    end
    -- Main loop has access to vim's full API, buffers, and other states
    -- See vim.schedule_wrap vs vim.schedule
    -- https://github.com/neovim/neovim/issues/20048#issuecomment-1234844500
    local function f(i)
      local ok, entry = coroutine.resume(undolist_entry_producer)
      if not ok then
        error("Failed to produce undotree entry: " .. entry)
      end

      vim.notify(vim.inspect(entry))
      vim.notify(coroutine.status(undolist_entry_producer))
      if coroutine.status(undolist_entry_producer) == "dead" then
        return
      end
      if opts.callback then
        opts.callback(entry)
      end

      if i == opts.max_entries then
        coroutine.close(undolist_entry_producer)
        return
      end

      i = i + 1
      if i <= opts.max_entries then
        vim.schedule_wrap(f)(i + 1)
      end
    end

    vim.schedule_wrap(f)(0)
  end
end

-- Unnecessary for now because the only function that uses this is get_undo_before_and_after
-- But maybe we have other means of messing with the undotree in the future
M.mess_with_undotree = function(f, ...)
  -- save our current cursor
  local cursor = vim.api.nvim_win_get_cursor(0)
  -- get all diffs of current buf
  local undotree = vim.fn.undotree()

  local return_val = f(undotree, ...)

  -- restore everything after
  vim.cmd("silent undo " .. undotree.seq_cur)
  vim.api.nvim_win_set_cursor(0, cursor)

  return return_val
end

M.get_undo_before_and_after = function(seq)
  return M.mess_with_undotree(function(undotree)
    vim.cmd("silent undo " .. seq)
    local buffer_after = vim.api.nvim_buf_get_lines(0, 0, -1, false) or {}

    vim.cmd("silent undo")
    local buffer_before = vim.api.nvim_buf_get_lines(0, 0, -1, false) or {}

    return { buffer_before, buffer_after }
  end)
end

return M
