local M = {}

M.OS = vim.loop.os_uname().sysname
M.IS_MAC = M.OS == "Darwin"
M.IS_LINUX = M.OS == "Linux"

-- TODO: extract the heredoc part into a helper method

-- Return the shell command to send data to a named pipe
--
---@param name string
---@param data string
---@return string
M.write_to_named_pipe_cmd = function(name, data)
  -- if M.IS_MAC or M.IS_LINUX then
  --   return ([[echo "%s" > %s &]]):format(data, name)
  -- else
  --   error("Unsupported OS")
  -- end

  if M.IS_MAC then
    return ([[cat <<EOF | nc -U %s
%s
EOF
]]):format(name, data)
  elseif M.IS_LINUX then
    return ([[cat <<EOF | socat - UNIX-CONNECT:%s
%s
EOF
]]):format(name, data)
  else
    error("Unsupported OS")
  end
end

-- Write data to a unix socket
--
---@param name string
---@param data string | string[]
---@return nil
M.write_to_named_pipe = function(name, data)
  local sock, err = vim.loop.new_pipe(false)
  assert(sock, err)
  local success, err = sock:connect(name)
  assert(success, err)
  sock:write(data)
  sock:close()
end

-- Return shell cmd for sending data to a tcp server
--
---@param host string
---@param port number
---@param data string
---@return string
M.write_to_tcp_cmd = function(host, port, data)
  if M.IS_MAC then
    return ([[cat <<EOF | nc %s %s
%s
EOF
]]):format(host, port, data)
  elseif M.IS_LINUX then
    error("Not implemented")
  else
    error("Unsupported OS")
  end
end

-- Return next available port
--
---@param start number
---@param opts? { max?: number, step?: number }
---@return number
M.next_available_port = function(start, opts)
  opts = vim.tbl_extend("force", { max = 30, step = 10 }, opts or {})

  local port = start
  port = port - opts.step
  opts.max = opts.max + 1
  repeat
    port = port + opts.step
    opts.max = opts.max - 1
    vim.fn.system(([[netstat -taln | grep %s]]):format(port))
  until vim.v.shell_error ~= 0 or opts.max <= 0

  if opts.max <= 0 then error("No available port") end

  return port
end

return M
