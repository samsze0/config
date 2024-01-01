local M = {}

OS = vim.loop.os_uname().sysname
IS_MAC = OS == "Darwin"
IS_LINUX = OS == "Linux"

-- Return the shell command to connect to a unix socket
--
---@param addr string
---@return string
M.get_unix_sock_cmd = function(addr)
  if IS_MAC then
    return string.format("nc -U %s", addr)
  elseif IS_LINUX then
    return string.format("socat - UNIX-CONNECT:%s", addr)
  else
    error("Unsupported OS")
  end
end

-- Write data to a unix socket
--
---@param sock_path string
---@param data string | string[]
---@return nil
M.write_to_unix_sock = function(sock_path, data)
  local sock, err = vim.loop.new_pipe(false)
  assert(sock, err)
  local success, err = sock:connect(sock_path)
  assert(success, err)
  sock:write(data)
  sock:close()
end

return M
