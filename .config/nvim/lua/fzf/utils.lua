local M = {}

FZF_TMPFILE = vim.fn.tempname()
local utils = require("utils")
local os_utils = require("utils.os")

M.fzf_initial_preview_scroll_offset = function(offset, opts)
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

M.generate_fzf_reload_action = function(input)
  return string.format(
    "reload(%s)",
    string.format(
      [[cat <<"EOF"
%s
EOF
]],
      table.concat(input, "\n")
    )
  )
end

M.generate_fzf_send_to_server_action = function(
  message,
  server_socket_path,
  opts
)
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

M.write_to_tmpfile = function(content)
  vim.fn.writefile(
    type(content) == "string" and vim.split(content, "\n") or content,
    FZF_TMPFILE
  )
  return FZF_TMPFILE
end

M.create_fzf_entry = function(...)
  local args = { ... }
  local size = #args
  return string.format(string.rep("%s", size, utils.nbsp), ...)
end

return M
