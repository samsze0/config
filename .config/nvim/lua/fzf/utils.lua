local M = {}

local tempfile = vim.fn.tempname()
local utils = require("utils")
local os_utils = require("utils.os")

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
M.send_to_lua_action = function(message, server_socket_path, opts)
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

return M
