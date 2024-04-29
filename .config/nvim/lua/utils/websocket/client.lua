-- Tweaked from:
-- https://github.com/jbyuki/instant.nvim/blob/master/lua/instant/websocket_client.lua

-- https://en.wikipedia.org/wiki/WebSocket#Protocol
-- https://en.wikipedia.org/wiki/WebSocket#Frame-based_message

local base64 = require("utils.base64")
local utils = require("utils")
local WebsocketConn = require("utils.websocket.shared").UtilsWebsocketConn
local MessageReplayBuffer = require("utils.websocket.message-replay-buffer").MessageReplayBuffer

---@class UtilsWebsocketClient
---@field _started boolean
---@field _message_replay_buffer UtilsWebsocketMessageReplayBuffer
---@field connect fun(self: UtilsWebsocketClient): nil
---@field disconnect fun(self: UtilsWebsocketClient): nil
---@field send_data fun(self: UtilsWebsocketClient, str: string): nil
---@field is_active fun(self: UtilsWebsocketClient): boolean

local M = {}

---@alias UtilsCreateWebsocketClientOpts { frame_size?: number, on_message: (fun(client: UtilsWebsocketClient, message: string): nil), on_disconnect?: (fun(client: UtilsWebsocketClient): nil), on_connect?: (fun(client: UtilsWebsocketClient): nil), on_upgrade?: (fun(client: UtilsWebsocketClient): nil), headers?: table<string, string> }
---@param host string
---@param port number
---@param opts UtilsCreateWebsocketClientOpts
---@return UtilsWebsocketClient
function M.create(host, port, opts)
  opts = utils.opts_extend({ frame_size = 8192 }, opts)
  ---@cast opts UtilsCreateWebsocketClientOpts

  local sock = vim.loop.new_tcp()

  ---@type UtilsWebsocketClient
  local UtilsWebsocketClient = { ---@diagnostic disable-line: missing-fields
    _started = false,
    _message_replay_buffer = MessageReplayBuffer.new()
  }

  local conn_state = WebsocketConn.new()
  conn_state:setup({
    unmask = false,
    on_ws_frame = function(opcode, data)
      if opcode == 0x1 then -- TEXT
        opts.on_message(UtilsWebsocketClient, data)
        return true
      elseif opcode == 0x2 then -- BINARY
        error("Binary frames are not supported")
      elseif opcode == 0x8 then -- CLOSE
        UtilsWebsocketClient:disconnect()
        return false
      elseif opcode == 0x9 then -- PING
        sock:write(WebsocketConn.to_frame({ 0x8A, 0x80 }, data))
        return true
      end

      error("Unexpected opcode " .. opcode)
    end,
    on_http = function(message)
      if message:lower():find("sec%-websocket%-accept") then
        conn_state:upgrade()
        while not UtilsWebsocketClient._message_replay_buffer:is_empty() do
          UtilsWebsocketClient:send_data(UtilsWebsocketClient._message_replay_buffer:pop())
        end
        if opts.on_upgrade then opts.on_upgrade(UtilsWebsocketClient) end
      end
    end,
  })

  function UtilsWebsocketClient:connect()
    if self._started then error("Already started") end
    self._started = true

    local stream, err = sock:connect(
      host,
      port,
      function(err)
        if err then
          if opts.on_disconnect then opts.on_disconnect(UtilsWebsocketClient) end
          error("There was an error during connection: " .. err)
        end

        sock:read_start(function(err, chunk)
          ---@cast err string?
          ---@cast chunk string?

          if err then
            if opts.on_disconnect then opts.on_disconnect(UtilsWebsocketClient) end
            error("There was an error during connection: " .. err)
          end

          conn_state:next_chunk(chunk)
        end)

        local msg = {
          "GET / HTTP/1.1\r\n",
          "Host: " .. host .. ":" .. port .. "\r\n",
          "Upgrade: websocket\r\n",
          "Connection: Upgrade\r\n",
          "Sec-WebSocket-Key: " .. base64.encode(
            WebsocketConn.generate_websocket_key()
          ) .. "\r\n",
          "Sec-WebSocket-Version: 13\r\n",
        }

        if opts.headers then
          for key, value in pairs(opts.headers) do
            table.insert(msg, key .. ": " .. value .. "\r\n")
          end
        end

        table.insert(msg, "\r\n")

        sock:write(msg)
      end
    )
    assert(not err, err)

    if opts.on_connect then opts.on_connect(UtilsWebsocketClient) end
  end

  function UtilsWebsocketClient:disconnect()
    if not self._started then error("Not started") end

    sock:write(WebsocketConn.to_frame({ 0x88, 0x80 }))
    sock:close()

    if opts.on_disconnect then opts.on_disconnect(UtilsWebsocketClient) end
  end

  function UtilsWebsocketClient:send_data(data)
    if not self._started then error("Not started") end
    if not conn_state:is_upgraded() then
      self._message_replay_buffer:append(data)
      return
    end

    local frames = WebsocketConn.data_to_frames(data, opts.frame_size, true)
    for _, frame in ipairs(frames) do
      sock:write(frame)
    end
  end

  function UtilsWebsocketClient:is_active() return self._started end

  return setmetatable(UtilsWebsocketClient, { __index = UtilsWebsocketClient, __is_class = true })
end

return M
