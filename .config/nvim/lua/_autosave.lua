require('autosave').setup({
  enabled = true,
  execution_message = "AutoSaved",
  events = {"InsertLeave", "TextChanged"},
  conditions = {
    -- These are the conditions that every file must meet so that it can be saved
    exists = true,
    modifiable = true
  },
  write_all_buffers = false,
  clean_command_line_interval = 500,
  debounce_delay = 135  -- if greater than 0, saves the file at most every `debounce_delay` milliseconds
})

-- Hooks
-- | hook_before_saving() | Before its even checked if the file meets the conditions to be saved |
-- | hook_after_saving    | After successfully saving the file or not                            |
-- autosave.hook_after_off = function ()
-- 	print("I was toggled off!")
-- end
