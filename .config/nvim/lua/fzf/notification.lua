local M = {}

local core = require("fzf.core")
local fzf_utils = require("fzf.utils")
local helpers = require("fzf.helpers")
local timeago = require("utils.timeago")
local utils = require("utils")
local notifier = require("notify")

-- Fzf all notifications
--
---@param opts? { max_num_enxtires?: integer }
M.notifications = function(opts)
  local notify = vim.notify -- Restore vim.notify later
  vim.notify = function(...) end ---@diagnostic disable-line: duplicate-set-field

  opts = vim.tbl_extend("force", {
    max_num_entries = 100,
  }, opts or {})

  local get_entries = function()
    local notifications = notifier.notifications
    local num_unread = utils.sum(notifier.unread_notifications)
    notifier.clear_unread()

    local entries = {}
    for i = #notifications, 1, -1 do
      if #entries >= opts.max_num_entries then break end

      local noti = notifications[i]
      local l = noti.level
      ---@type string
      local level
      local unread = #entries < num_unread
      if l == vim.log.levels.INFO then
        level = unread and utils.ansi_codes.blue("󰋼 ") or "󰋼 "
      elseif l == vim.log.levels.WARN then
        level = unread and utils.ansi_codes.yellow(" ") or " "
      elseif l == vim.log.levels.ERROR then
        level = unread and utils.ansi_codes.red(" ") or " "
      elseif l == vim.log.levels.DEBUG or level == vim.log.levels.TRACE then
        level = unread and utils.ansi_codes.grey(" ") or " "
      else
        level = unread and utils.ansi_codes.grey(" ") or " "
      end
      local brief = noti.message
      local parts = vim.split(brief, "\n")
      if #parts > 1 then brief = parts[1] end
      if not brief or brief == "" then brief = "<empty>" end
      local brief_max_length = 50
      brief = #brief > brief_max_length
          and brief:sub(1, brief_max_length - 3) .. "..."
        or utils.pad_string(brief, brief_max_length)
      table.insert(
        entries,
        fzf_utils.join_by_delim(
          level,
          timeago(noti.time),
          unread and utils.ansi_codes.white(brief) or brief
        )
      )
    end
    return entries
  end

  local get_notification = function(index)
    local notifications = require("notify").notifications
    return notifications[#notifications - index + 1]
  end

  local parse_entry = function(entry)
    local args = vim.split(entry, utils.nbsp)
    local level, time, brief = unpack(args)
    return level, time, vim.trim(brief)
  end

  local layout, popups, set_preview_content =
    helpers.create_nvim_preview_layout({
      preview_popup_win_options = {
        wrap = true,
      },
    })

  core.fzf(get_entries(), {
    prompt = "Notifications",
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

        popups.main.border:set_text("bottom", " ")
      end,
      ["focus"] = function(state)
        local level, time, brief = parse_entry(state.focused_entry)
        local noti = get_notification(state.focused_entry_index)

        local tmpfile = fzf_utils.write_to_tmpfile(noti.message)

        popups.nvim_preview.border:set_text("top", " " .. brief .. " ")

        helpers.preview_file(tmpfile, popups.nvim_preview)
      end,
      ["+after-exit"] = function(state) vim.notify = notify end, -- Restore vim.notify
    },
    extra_args = vim.tbl_extend("force", helpers.fzf_default_args, {
      ["--with-nth"] = "1..",
    }),
  })
end

return M
