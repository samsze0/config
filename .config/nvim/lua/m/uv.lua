local uv = vim.loop

local M = {}

local create_server_default_opts = {}

M.create_server = function(on_message, opts)
  opts = vim.tbl_extend("force", create_server_default_opts, opts or {})

  local tmpfile = vim.fn.tempname()
  local server, err = uv.new_pipe(false)
  assert(server, err)
  uv.pipe_bind(server, tmpfile)

  local clients = {}
  local close = function()
    for _, client in ipairs(clients) do
      client:close()
    end
    server:close()
    os.remove(tmpfile)
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
        client:write("ok!") -- Echo message back to client
      else -- EOF (stream closed)
        client:close()
      end
    end)
  end)

  return server, tmpfile, close
end

M.create_tcp_server = function(host, port, on_message)
  opts = vim.tbl_extend("force", create_server_default_opts, opts or {})

  local server = uv.new_tcp()
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
    server:accept(client)
    table.insert(clients, client)
    client:read_start(function(err, chunk)
      assert(not err, err)
      if chunk then
        on_message(chunk)
        client:write("ok!") -- Echo message back to client
      else -- EOF (stream closed)
        client:close()
      end
    end)
  end)
  return server, close
end

local function watch_file(filepath, on_file_change, flags, debounce_delay)
  local fullpath = vim.api.nvim_call_function("fnamemodify", { filepath, ":p" })

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
end

M.watch_file = watch_file

return M
