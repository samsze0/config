local M = {}

local tempfile = vim.fn.tempname()
local utils = require("utils")
local os_utils = require("utils.os")

local Layout = require("nui.layout")
local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event

-- Generate a preview window offset string for fzf
--
---@param offset integer | string
---@param opts? { fixed_header?: number, center?: boolean }
---@return string
M.preview_offset = function(offset, opts)
  opts = vim.tbl_extend("force", {
    fixed_header = 0,
    center = true,
  }, opts or {})
  return string.format(
    [[~%s,+%s%s,+%s%s]],
    tostring(opts.fixed_header),
    tostring(opts.fixed_header),
    opts.center and "/2" or "",
    tostring(offset),
    opts.center and "/2" or ""
  )
end

-- Generate a reload action string for fzf
--
---@param entries string[]
---@return string
M.reload_action = function(entries)
  return string.format(
    "reload(%s)",
    string.format(
      [[cat <<"EOF"
%s
EOF
]],
      table.concat(entries, "\n")
    )
  )
end

-- Generate a send to lua server action string for fzf
--
---@param message string
---@param server_socket_path string
---@param opts? { var_expansion?: boolean }
---@return string
M._send_to_lua_action = function(message, server_socket_path, opts)
  opts = vim.tbl_extend("force", {
    var_expansion = false,
  }, opts or {})

  return string.format(
    [[execute-silent(%s)]],
    string.format(
      [[cat <<%s | %s
%s
EOF
]],
      opts.var_expansion and [[EOF]] or [["EOF"]],
      os_utils.get_unix_sock_cmd(server_socket_path),
      message
    )
  )
end

-- Write the given content to a temporary file and return the path to the file
--
---@param content string|string[]
---@return string
M.write_to_tmpfile = function(content)
  vim.fn.writefile(
    type(content) == "string" and vim.split(content, "\n") or content,
    tempfile
  )
  return tempfile
end

-- Generate a fzf entry by joining the given arguments with the nbsp character as delimiter
--
---@vararg string
---@return string
M.join_by_delim = function(...)
  local args = { ... }
  local size = #args
  return string.format(string.rep("%s", size, utils.nbsp), ...)
end

---@vararg table<string, bind_type>
---@return table<string, bind_type>
function M.bind_extend(...)
  local binds_list = { ... }

  local result = {} ---@type table<string, bind_type>

  for _, binds in pairs(binds_list) do
    for ev, actions in pairs(binds) do
      if type(actions) == "table" then
        M.add_actions_to_binds(ev, result, false, unpack(actions))
      else
        M.add_actions_to_binds(ev, result, false, actions)
      end
    end
  end

  return result
end

---@param event string
---@param binds table<string, bind_type>
---@param prepend boolean
---@vararg bind_type
function M.add_actions_to_binds(event, binds, prepend, ...)
  local new_actions = { ... }

  local current_type = type(binds[event])
  if current_type == "nil" then
    binds[event] = new_actions
  elseif current_type == "string" or current_type == "function" then
    if prepend then
      binds[event] = {
        unpack(new_actions), ---@diagnostic disable-line: assign-type-mismatch
        binds[event], ---@diagnostic disable-line: assign-type-mismatch
      }
    else
      binds[event] = {
        binds[event], ---@diagnostic disable-line: assign-type-mismatch
        unpack(new_actions), ---@diagnostic disable-line: assign-type-mismatch
      }
    end
  elseif current_type == "table" then
    for i, a in pairs(new_actions) do
      if prepend then
        table.insert(binds[event], i, a) ---@diagnostic disable-line: param-type-mismatch
      else
        table.insert(binds[event], a) ---@diagnostic disable-line: param-type-mismatch
      end
    end
  else
    error("Invalid fzf bind action type " .. current_type)
  end
end

-- Create a simple window layout for Fzf that includes only a main window
--
---@return NuiLayout, { main: NuiPopup }
M.create_simple_layout = function()
  local main_popup = Popup({
    enter = true,
    focusable = true,
    border = {
      style = "rounded",
    },
    buf_options = {
      modifiable = false,
      filetype = "fzf",
    },
    win_options = {
      winblend = 0,
      winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
    },
  })

  local layout = Layout(
    {
      position = "50%",
      relative = "editor",
      size = {
        width = "90%",
        height = "90%",
      },
    },
    Layout.Box({
      Layout.Box(main_popup, { size = "100%" }),
    }, {})
  )

  main_popup:on("BufLeave", function() layout:unmount() end)

  return layout, {
    main = main_popup,
  }
end

return M
