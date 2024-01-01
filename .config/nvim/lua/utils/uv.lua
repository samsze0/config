local uv = vim.loop

local M = {}

local create_server_default_opts = {}

-- Create a server that listens on a unix socket
--
---@param on_message fun(message: string): nil
---@param opts? {}
---@return uv_pipe_t pipe, string socket_path, fun(): nil close_fn
M.create_server = function(on_message, opts)
  opts = vim.tbl_extend("force", create_server_default_opts, opts or {})

  local socket_path = vim.fn.tempname()
  local server, err = uv.new_pipe(false)
  assert(server, err)
  uv.pipe_bind(server, socket_path)

  local clients = {}
  local close = function()
    for _, client in ipairs(clients) do
      client:close()
    end
    server:close()
    os.remove(socket_path)
  end

  uv.listen(server, 100, function(err)
    assert(not err, err)

    local client, err = uv.new_pipe(false)
    assert(client, err)
    server:accept(client)
    table.insert(clients, client)
    client:read_start(function(err, chunk)
      assert(not err)
      if chunk then
        on_message(chunk)
      else -- EOF (stream closed)
        client:close()
      end
    end)
  end)

  return server, socket_path, close
end

-- Create a server that listens on a tcp socket
--
---@param host string
---@param port number
---@param on_message fun(message: string): nil
---@param opts? {}
---@return uv_tcp_t pipe, fun(): nil close_fn
M.create_tcp_server = function(host, port, on_message, opts)
  opts = vim.tbl_extend("force", create_server_default_opts, opts or {})

  local server = uv.new_tcp()
  assert(server)
  server:bind(host, port)

  local clients = {}
  local close = function()
    for _, client in ipairs(clients) do
      client:close()
    end
    server:close()
  end

  server:listen(128, function(err)
    assert(not err, err)

    local client = uv.new_tcp()
    assert(client)
    server:accept(client)
    table.insert(clients, client)
    client:read_start(function(err, chunk)
      assert(not err, err)
      if chunk then
        on_message(chunk)
      else -- EOF (stream closed)
        client:close()
      end
    end)
  end)
  return server, close
end

---@param filepath string
---@param on_file_change fun(events: uv.fs_event_start.callback.events): nil
---@param flags uv.fs_event_start.flags
---@param debounce_delay number
---@return nil
local function watch_file(filepath, on_file_change, flags, debounce_delay)
  local fullpath = vim.fn.fnamemodify(filepath, ":p")

  local function f()
    local w, err = uv.new_fs_event()
    assert(w, err)

    w:start(
      fullpath,
      flags,
      vim.schedule_wrap(function(err, fname, events)
        assert(not err, err)

        on_file_change(events)
        vim.api.nvim_command("checktime")

        -- Debounce
        w:stop()
        vim.defer_fn(f, debounce_delay)
      end)
    )
  end

  f()
end

M.watch_file = watch_file

---@param timeout number
---@param callback fun(): nil
---@param opts? { callback_in_vim_loop?: boolean }
---@return uv_timer_t timer
M.set_timeout = function(timeout, callback, opts)
  opts = vim.tbl_extend("force", { callback_in_vim_loop = false }, opts or {})

  local timer, err = uv.new_timer()
  assert(timer, err)
  timer:start(timeout, 0, function()
    timer:stop()
    timer:close()

    if opts.callback_in_vim_loop then
      vim.schedule(callback)
    else
      callback()
    end
  end)
  return timer
end

---@param interval number
---@param callback fun(): nil
---@param opts? { callback_in_vim_loop?: boolean }
---@return uv_timer_t timer
M.set_interval = function(interval, callback, opts)
  opts = vim.tbl_extend("force", { callback_in_vim_loop = false }, opts or {})

  local timer, err = uv.new_timer()
  assert(timer, err)
  timer:start(interval, interval, function()
    if opts.callback_in_vim_loop then
      vim.schedule(callback)
    else
      callback()
    end
  end)
  return timer
end

---@param timer uv_timer_t
---@return nil
M.clear_interval = function(timer)
  timer:stop()
  timer:close()
end

return M
