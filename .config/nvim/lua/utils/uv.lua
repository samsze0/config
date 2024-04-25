local uv = vim.loop
local utils = require("utils")

local M = {}

-- Create a server that listens on a named pipe
--
---@param on_message fun(message: string): nil
---@param opts? {}
---@return { handle: uv_pipe_t, close: function, pipe_name: string }
M.create_named_pipe_server = function(on_message, opts)
  opts = opts or {}

  local path = vim.fn.tempname()
  local pipe_handle, err = uv.new_pipe(false)
  assert(pipe_handle, err)

  local ok, err = uv.pipe_bind(pipe_handle, path)
  assert(ok, err)

  local clients = {}
  local close = function()
    -- Seems like clients close themselves. So no need to close them ourselves
    -- for _, client in ipairs(clients) do
    --   client:close()
    -- end
    pipe_handle:close()
    local ok, err = os.remove(path)
    assert(ok, err)
  end

  local ok, err = pipe_handle:listen(100, function(err)
    assert(not err)

    local client_handle, err = uv.new_pipe(false)
    assert(client_handle, err)
    local ok, err = pipe_handle:accept(client_handle)
    assert(ok, err)
    table.insert(clients, client_handle)

    local ok, err = client_handle:read_start(function(err, chunk)
      assert(not err)
      if chunk then
        on_message(chunk)
      else -- EOF (stream closed)
        client_handle:close()
      end
    end)
    assert(ok, err)
  end)
  assert(ok, err)

  return {
    handle = pipe_handle,
    close = close,
    pipe_name = path,
  }
end

-- Create a server that listens on a tcp socket
--
---@param host string
---@param on_message fun(message: string): nil
---@param opts? {}
---@return { handle: uv_tcp_t, close: function, host: string, port: number }
M.create_tcp_server = function(host, on_message, opts)
  opts = opts or {}

  local tcp_handle = uv.new_tcp()

  local ok, err = tcp_handle:bind(host, 0)
  if not ok then
    ---@cast err string
    if err:match("EADDRINUSE") then
      -- Should not happen because tcp port are chosen by the OS
      error(err)
    else
      error(err)
    end
  end

  local sockname, err = tcp_handle:getsockname()
  assert(sockname, err)

  local port = sockname.port

  ---@type uv_tcp_t[]
  local clients = {}
  local close = function()
    -- Seems like clients close themselves. So no need to close them ourselves
    -- for _, client in ipairs(clients) do
    --   client:close()
    -- end
    tcp_handle:close()
  end

  local ok, err = tcp_handle:listen(100, function(err)
    assert(not err)

    local client_handle = uv.new_tcp()
    assert(client_handle)
    local ok, err = tcp_handle:accept(client_handle)
    assert(ok, err)
    table.insert(clients, client_handle)

    local ok, err = client_handle:read_start(function(err, chunk)
      assert(not err)
      if chunk then
        on_message(chunk)
      else -- EOF (stream closed)
        client_handle:close()
      end
    end)
    assert(ok, err)
  end)
  assert(ok, err)

  return {
    handle = tcp_handle,
    close = close,
    host = host,
    port = port,
  }
end

---@param filepath string
---@param on_file_change fun(events: uv.aliases.fs_event_start_callback_events): nil
---@param flags uv.aliases.fs_event_start_flags
---@param debounce_delay number
M.watch_file = function(filepath, on_file_change, flags, debounce_delay)
  local fullpath = vim.fn.fnamemodify(filepath, ":p")

  local function f()
    local fs_handle, err = uv.new_fs_event()
    assert(fs_handle, err)

    fs_handle:start(
      fullpath,
      flags,
      vim.schedule_wrap(function(err, fname, events)
        assert(not err)

        on_file_change(events)

        -- Debounce
        fs_handle:stop()
        vim.defer_fn(f, debounce_delay)
      end)
    )
  end

  f()
end

-- Check if running in vim main event-loop. If so, schedule the function to be executed
-- on main loop
M.schedule_if_needed = function(fn)
  if vim.in_fast_event() then
    vim.schedule(fn)
  else
    fn()
  end
end

return M
