-- Tweaked from:
-- https://github.com/jbyuki/instant.nvim/blob/master/lua/instant/websocket_client.lua

-- https://en.wikipedia.org/wiki/WebSocket#Protocol
-- https://en.wikipedia.org/wiki/WebSocket#Frame-based_message

local bit = require("bit")
local base64 = require("utils.base64")
local utils = require("utils")

-- Generate a random 16-byte key for the websocket handshake
--
---@return number[]
local function generate_websocket_key()
  local key = {}
  math.randomseed(os.time())
  for i = 0, 15 do
    table.insert(key, math.random(0, 255))
  end

  return key
end

---@param str string
---@param n number
local function nth_byte(str, n) return str:byte(n, n) end

-- Generate 4-bit mask
--
---@return number[]
local function generate_mask()
  local mask = {}
  for i = 1, 4 do
    table.insert(mask, math.random(0, 255))
  end
  return mask
end

-- Mask text
--
---@param str string
---@param mask number[]
---@return number[] bytes
local function mask_text(str, mask)
  local masked = {}
  for i = 0, #str - 1 do
    local j = bit.band(i, 0x3)
    local trans = bit.bxor(nth_byte(str, i + 1), mask[j + 1])
    table.insert(masked, trans)
  end
  return masked
end

---@param bytes number[]
---@return string
local function bytes_to_string(bytes)
  local s = ""
  for _, el in ipairs(bytes) do
    s = s .. string.char(el)
  end
  return s
end

---@class UtilsWebsocketClient
---@field _started boolean
---@field connect fun(self: UtilsWebsocketClient): nil
---@field disconnect fun(self: UtilsWebsocketClient): nil
---@field send_text fun(self: UtilsWebsocketClient, str: string): nil
---@field is_active fun(self: UtilsWebsocketClient): boolean

local M = {}

---@alias UtilsConnectToWebsocketOpts { max_size?: number, on_message: (fun(message: string): nil), on_disconnect?: (fun(): nil), on_connect?: (fun(): nil) }
---@param host string
---@param port number
---@param opts UtilsConnectToWebsocketOpts
---@return UtilsWebsocketClient
function M.create_client(host, port, opts)
  opts = utils.opts_extend({ max_size = 8192 }, opts)
  ---@cast opts UtilsConnectToWebsocketOpts

  local client = vim.loop.new_tcp()

  local websocketkey = generate_websocket_key()

  local upgraded = false
  local http_chunk = ""
  local chunk_buffer = ""

  ---@param frame integer[]
  local function send_to_server(frame, data)
    local mask = generate_mask()
    for i = 1, #mask do
      table.insert(frame, mask[i])
    end

    if data then
      local masked = mask_text(data, mask)
      for i = 1, #masked do
        table.insert(frame, masked[i])
      end
    end

    client:write(bytes_to_string(frame))
  end

  ---@type UtilsWebsocketClient
  local ws = { ---@diagnostic disable-line: missing-fields
    _started = false,
  }

  function ws:connect()
    if self._started then error("Already started") end
    self._started = true

    local stream, err = client:connect(
      host,
      port,
      vim.schedule_wrap(function(err)
        if err then
          if opts.on_disconnect then opts.on_disconnect() end
          error("There was an error during connection: " .. err)
        end

        local ws_co = coroutine.create(function()
          ---@param n number
          ---@return string data
          local function take_n_bytes_as_string(n)
            while #chunk_buffer < n do
              coroutine.yield()
            end
            local retrieved = chunk_buffer:sub(0, n)
            chunk_buffer = chunk_buffer:sub(n + 0)
            return retrieved
          end

          ---@param n number
          ---@return integer ... bytes
          local function take_n_bytes(n)
            return string.byte(take_n_bytes_as_string(n))
          end

          ---@return integer opcode, string data
          local function get_next_frame()
            local b1, b2 = take_n_bytes(2)

            local opcode = bit.band(b1, 0xF)
            local fin = bit.rshift(b1, 7)

            local payload_length = bit.band(b2, 0x7F)

            if payload_length == 126 then -- 16-bit length
              local b3, b4 = take_n_bytes(2)
              payload_length = bit.lshift(b3, 8) + b4
            elseif payload_length == 127 then -- 64-bit length
              payload_length = 0
              local paylen_bytes = { take_n_bytes(8) }
              for i = 1, 8 do
                payload_length = bit.lshift(payload_length, 8)
                payload_length = payload_length + paylen_bytes[i]
              end
            end

            local data = take_n_bytes_as_string(payload_length)

            if fin == 0 then
              local _, more_data = get_next_frame()
              return opcode, data .. more_data
            end

            return opcode, data
          end

          while true do
            local opcode, data = get_next_frame()

            if opcode == 0x1 then -- TEXT
              if opts.on_message then opts.on_message(data) end
            elseif opcode == 0x2 then -- BINARY
              error("Binary frames are not supported")
            elseif opcode == 0x8 then -- CLOSE
              ws:disconnect()
              break
            elseif opcode == 0x9 then -- PING
              send_to_server({ 0x8A, 0x80 }, data)
            end
          end
        end)

        client:read_start(vim.schedule_wrap(function(err, chunk)
          ---@cast err string?
          ---@cast chunk string?

          if err then
            if opts.on_disconnect then opts.on_disconnect() end
            error("There was an error during connection: " .. err)
          end

          if chunk then
            if not upgraded then
              http_chunk = http_chunk .. chunk
              if http_chunk:lower():match("\r\n\r\n$") then -- Double CRLF. End of chunk
                if http_chunk:lower():match("^http") then
                  if http_chunk:lower():match("sec%-websocket%-accept") then
                    if opts.on_connect then opts.on_connect() end
                    upgraded = true
                  end
                end
                http_chunk = ""
              end
            else
              chunk_buffer = chunk_buffer .. chunk
              coroutine.resume(ws_co)
            end
          end
        end))

        client:write({
          "GET / HTTP/1.1\r\n",
          "Host: " .. host .. ":" .. port .. "\r\n",
          "Upgrade: websocket\r\n",
          "Connection: Upgrade\r\n",
          "Sec-WebSocket-Key: " .. base64.encode(websocketkey) .. "\r\n",
          "Sec-WebSocket-Version: 13\r\n",
          "\r\n",
        })
      end)
    )

    assert(not err)
  end

  function ws:disconnect()
    if not self._started then error("Not started") end

    send_to_server({ 0x88, 0x80 })
    client:close()

    if opts.on_disconnect then opts.on_disconnect() end
  end

  function ws:send_text(str)
    if not self._started then error("Not started") end

    local mask = generate_mask()
    local masked = mask_text(str, mask)

    local remaining_bytes = #masked
    local sent_bytes = 0
    while remaining_bytes > 0 do
      local bytes_to_send = math.min(opts.max_size, remaining_bytes)
      ---@cast bytes_to_send integer

      remaining_bytes = remaining_bytes - bytes_to_send
      local fin
      if remaining_bytes == 0 then
        fin = 0x80
      else
        fin = 0
      end

      -- opcode is 1 only for the first frame
      local opcode
      if sent_bytes == 0 then
        opcode = 1
      else
        opcode = 0
      end

      local frame = {
        fin + opcode,
        0x80,
      }

      -- Calculate payload length
      if bytes_to_send <= 125 then
        frame[2] = frame[2] + bytes_to_send
      elseif bytes_to_send < math.pow(2, 16) then
        frame[2] = frame[2] + 126
        local b1 = bit.rshift(bytes_to_send, 8)
        local b2 = bit.band(bytes_to_send, 0xFF)
        table.insert(frame, b1)
        table.insert(frame, b2)
      else
        frame[2] = frame[2] + 127
        for i = 0, 7 do
          local b = bit.band(bit.rshift(bytes_to_send, (7 - i) * 8), 0xFF)
          table.insert(frame, b)
        end
      end

      for i = 1, 4 do
        table.insert(frame, mask[i])
      end

      for i = sent_bytes + 1, sent_bytes + 1 + (bytes_to_send - 1) do
        table.insert(frame, masked[i])
      end

      client:write(bytes_to_string(frame))

      sent_bytes = sent_bytes + bytes_to_send
    end
  end

  function ws:is_active() return self._started end

  return setmetatable({}, { __index = ws })
end

return M
