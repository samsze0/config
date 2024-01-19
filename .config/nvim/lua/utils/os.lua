local M = {}

M.OS = vim.loop.os_uname().sysname
M.IS_MAC = M.OS == "Darwin"
M.IS_LINUX = M.OS == "Linux"

-- Return the shell command to connect to a unix socket
--
---@param addr string
---@return string
M.get_unix_sock_cmd = function(addr)
  if M.IS_MAC then
    return string.format("nc -U %s", addr)
  elseif M.IS_LINUX then
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
