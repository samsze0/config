-- Tweaked from:
-- https://github.com/jbyuki/instant.nvim/blob/master/lua/instant/websocket_server.lua

-- https://en.wikipedia.org/wiki/WebSocket#Protocol
-- https://en.wikipedia.org/wiki/WebSocket#Frame-based_message

local bit = require("bit")
local base64 = require("utils.base64")
local utils = require("utils")
local os_utils = require("utils.os")
local sha_utils = require("utils.sha")
local WebsocketConn = require("utils.websocket.shared").UtilsWebsocketConn
local MessageReplayBuffer = require("utils.websocket.message-replay-buffer").MessageReplayBuffer

local M = {}

---@alias UtilsWebsocketServerClientId string

---@class UtilsWebsocketServerClient
---@field conn_state UtilsWebsocketConnState
---@field sock uv_tcp_t
---@field send_data fun(self: UtilsWebsocketServerClient, data: string): nil
---@field disconnect fun(self: UtilsWebsocketServerClient): nil
---@field _message_replay_buffer UtilsWebsocketMessageReplayBuffer

---@class UtilsWebsocketServer
---@field _started boolean
---@field sock uv_tcp_t
---@field start fun(self: UtilsWebsocketServer): nil
---@field clients table<UtilsWebsocketServerClientId, UtilsWebsocketServerClient>
---@field publish fun(self: UtilsWebsocketServer, data: string): nil
---@field close fun(self: UtilsWebsocketServer): nil
---@field is_active fun(self: UtilsWebsocketServer): boolean

---@alias UtilsCreateWebsocketServerOpts { frame_size?: number, host?: string, port: number, on_client_message: (fun(client: UtilsWebsocketServerClient, message: string): nil), on_client_disconnect?: (fun(client: UtilsWebsocketServerClient): nil), on_client_connect?: (fun(client: UtilsWebsocketServerClient): nil), on_client_upgrade?: (fun(client: UtilsWebsocketServerClient): nil) }
---@param opts UtilsCreateWebsocketServerOpts
---@return UtilsWebsocketServer
M.create = function(opts)
  opts = utils.opts_extend({ frame_size = 8192, host = "127.0.0.1" }, opts)
  ---@cast opts UtilsCreateWebsocketServerOpts

  ---@type UtilsWebsocketServer
  local UtilsWebsocketServer = { ---@diagnostic disable-line: missing-fields
    _started = false,
    clients = {},
  }
  setmetatable(UtilsWebsocketServer, { __index = UtilsWebsocketServer, __is_class = true })

  function UtilsWebsocketServer:start()
    if self._started then error("Already started") end
    self._started = true

    local server = vim.loop.new_tcp()
    server:bind(opts.host, opts.port)
    self.sock = server

    local ok, err = server:listen(128, function(err)
      local sock = vim.loop.new_tcp()
      server:accept(sock)

      local client_id = utils.uuid()

      local conn_state = WebsocketConn.new()

      ---@type UtilsWebsocketServerClient
      local UtilsWebsocketServerClient =
        { ---@diagnostic disable-line: missing-fields
          conn_state = conn_state,
          sock = sock,
          _message_replay_buffer = MessageReplayBuffer.new(),
        }
      setmetatable(
        UtilsWebsocketServerClient,
        { __index = UtilsWebsocketServerClient, __is_class = true }
      )
      UtilsWebsocketServer.clients[client_id] = UtilsWebsocketServerClient

      function UtilsWebsocketServerClient:send_data(data)
        if not conn_state:is_upgraded() then
          self._message_replay_buffer:append(data)
          return
        end

        local frames = WebsocketConn.data_to_frames(data, opts.frame_size, false)
        for _, frame in ipairs(frames) do
          self.sock:write(frame)
        end
      end

      function UtilsWebsocketServerClient:disconnect()
        if not self.sock:is_closing() then
          self.sock:write(WebsocketConn.to_frame({ 0x88, 0x00 }))
        end

        UtilsWebsocketServer.clients[client_id] = nil
        self.sock:close()
        if opts.on_client_disconnect then
          opts.on_client_disconnect(UtilsWebsocketServerClient)
        end
      end

      -- TODO: periodically ping clients

      conn_state:setup({
        unmask = true,
        on_ws_frame = function(opcode, data)
          if opcode == 0x1 then -- TEXT
            opts.on_client_message(UtilsWebsocketServerClient, data)
            return true
          elseif opcode == 0x2 then -- BINARY
            error("Binary frames are not supported")
          elseif opcode == 0x8 then -- CLOSE
            UtilsWebsocketServer.clients[client_id] = nil
            sock:close()
            if opts.on_client_disconnect then
              opts.on_client_disconnect(UtilsWebsocketServerClient)
            end
            return false
          end

          error("Unexpected opcode " .. opcode)
        end,
        on_http = function(message)
          if message:find("Upgrade: websocket") then
            local websocket_key =
              message:lower():match("sec%-websocket%-key: ([^\r\n]+)")

            if not websocket_key then
              error("Invalid or missing websocket key")
            end

            sock:write({
              "HTTP/1.1 101 Switching Protocols\r\n",
              "Upgrade: websocket\r\n",
              "Connection: Upgrade\r\n",
              "Sec-WebSocket-Accept: " .. base64.encode(
                sha_utils.sha1(base64.decode(websocket_key))
              ) .. "\r\n",
              "Sec-WebSocket-Protocol: chat\r\n",
              "\r\n",
            })

            conn_state:upgrade()
            while not UtilsWebsocketServerClient._message_replay_buffer:is_empty() do
              UtilsWebsocketServerClient:send_data(UtilsWebsocketServerClient._message_replay_buffer:pop())
            end
            if opts.on_client_upgrade then
              opts.on_client_upgrade(UtilsWebsocketServerClient)
            end
          end
        end,
      })

      sock:read_start(function(err, chunk)
        ---@cast err string?
        ---@cast chunk string?

        if err then
          -- TODO: create custom data structure for ServerClientMap
          UtilsWebsocketServer.clients[client_id] = nil
          if opts.on_client_disconnect then
            opts.on_client_disconnect(UtilsWebsocketServerClient)
          end
          error("There was an error during connection: " .. err)
        end

        conn_state:next_chunk(chunk)
      end)
    end)

    assert(ok, err)
  end

  function UtilsWebsocketServer:publish(data)
    if not self._started then error("Not started") end

    for _, client in pairs(self.clients) do
      client:send_data(data)
    end
  end

  function UtilsWebsocketServer:close()
    if not self._started then error("Not started") end

    for _, client in pairs(self.clients) do
      client:disconnect()
    end

    self.sock:close()
  end

  function UtilsWebsocketServer:is_active() return self._started end

  return UtilsWebsocketServer
end

return M
