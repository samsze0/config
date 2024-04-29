local bit = require("bit")
local base64 = require("utils.base64")
local utils = require("utils")
local bytes_utils = require("utils.bytes")

local nth_byte = bytes_utils.nth_byte
local bytes_to_string = bytes_utils.bytes_to_string

local M = {}

---@alias UtilsWebsocketConnStateHttpHandler fun(message: string): nil
---@alias UtilsWebsocketConnStateWsHandler fun(opcode: integer, data: string): boolean

---@class UtilsWebsocketConnState
---@field _chunk_buffer string
---@field _http_chunk string
---@field _upgraded boolean
---@field _co thread
---@field _on_ws_frame UtilsWebsocketConnStateWsHandler
---@field _on_http UtilsWebsocketConnStateHttpHandler
local UtilsWebsocketConn = {}
UtilsWebsocketConn.__index = UtilsWebsocketConn
UtilsWebsocketConn.__is_class = true

---@return UtilsWebsocketConnState
function UtilsWebsocketConn.new()
  local obj = {
    _chunk_buffer = "",
    _http_chunk = "",
    _upgraded = false,
    _co = nil,
  }
  setmetatable(obj, UtilsWebsocketConn)

  return obj
end

---@param opts { on_ws_frame: UtilsWebsocketConnStateWsHandler, on_http: UtilsWebsocketConnStateHttpHandler, unmask: boolean }
function UtilsWebsocketConn:setup(opts)
  local on_ws_frame = opts.on_ws_frame
  local on_http = opts.on_http

  self._on_ws_frame = on_ws_frame
  self._on_http = on_http

  self._co = coroutine.create(function()
    while true do
      local opcode, data = self:_get_next_frame(opts.unmask)
      if not self._on_ws_frame(opcode, data) then break end
    end
  end)
end

---@param n number
---@return string data
function UtilsWebsocketConn:_take_n_bytes_as_string(n)
  while #self._chunk_buffer < n do
    coroutine.yield()
  end
  local retrieved = self._chunk_buffer:sub(0, n)
  self._chunk_buffer = self._chunk_buffer:sub(n + 1)
  return retrieved
end

---@param n number
---@return integer ... bytes
function UtilsWebsocketConn:_take_n_bytes(n)
  local bytes = {}
  local str = self:_take_n_bytes_as_string(n)
  for i = 1, n do
    local byte = string.byte(str:sub(i, i))
    table.insert(bytes, byte)
  end
  return unpack(bytes)
end

---@param unmask boolean
---@return integer opcode, string data
function UtilsWebsocketConn:_get_next_frame(unmask)
  local b1, b2 = self:_take_n_bytes(2)

  local opcode = bit.band(b1, 0xF)
  local fin = bit.rshift(b1, 7)

  local payload_length = bit.band(b2, 0x7F)

  if payload_length == 126 then -- 16-bit length
    local b3, b4 = self:_take_n_bytes(2)
    payload_length = bit.lshift(b3, 8) + b4
  elseif payload_length == 127 then -- 64-bit length
    payload_length = 0
    local paylen_bytes = { self:_take_n_bytes(8) }
    for i = 1, 8 do
      payload_length = bit.lshift(payload_length, 8)
      payload_length = payload_length + paylen_bytes[i]
    end
  end

  local mask
  if unmask then
    mask = { self:_take_n_bytes(4) }
  end

  local data = self:_take_n_bytes_as_string(payload_length)
  if unmask then
    data = bytes_to_string(UtilsWebsocketConn.unmask_text(data, mask))
  end

  if fin == 0 then
    local _, more_data = self:_get_next_frame(unmask)
    return opcode, data .. more_data
  end

  return opcode, data
end

---@param chunk string?
function UtilsWebsocketConn:next_chunk(chunk)
  if chunk then
    if not self._upgraded then
      self._http_chunk = self._http_chunk .. chunk

      if self._http_chunk:lower():match("\r\n\r\n$") then
        self._on_http(self._http_chunk)
        self._http_chunk = ""
      end
    else
      self._chunk_buffer = self._chunk_buffer .. chunk
      local ok = coroutine.resume(self._co)
      assert(ok, debug.traceback(self._co))
    end
  end
end

-- Generate 4-bit mask
--
---@return number[]
function UtilsWebsocketConn.generate_mask()
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
function UtilsWebsocketConn.mask_text(str, mask)
  local masked = {}
  for i = 0, #str - 1 do
    local j = bit.band(i, 0x3)
    local trans = bit.bxor(nth_byte(str, i + 1), mask[j + 1])
    table.insert(masked, trans)
  end
  return masked
end

-- Unmask text (same as `mask`)
--
---@param str string
---@param mask number[]
---@return number[] bytes
function UtilsWebsocketConn.unmask_text(str, mask)
  local unmasked = {}
  for i = 0, #str - 1 do
    local j = bit.band(i, 0x3)
    local trans = bit.bxor(nth_byte(str, i + 1), mask[j + 1])
    table.insert(unmasked, trans)
  end
  return unmasked
end

---@param data string
---@param frame_size number
---@param mask boolean
---@return string[]
function UtilsWebsocketConn.data_to_frames(data, frame_size, mask)
  local should_mask = mask

  ---@type number[]
  local mask
  ---@type number[]
  local data_bytes

  if should_mask then
    mask = UtilsWebsocketConn.generate_mask()
    data_bytes = UtilsWebsocketConn.mask_text(data, mask)
  else
    data_bytes = bytes_utils.string_to_bytes(data)
  end

  local frames = {}

  local remaining_bytes = #data_bytes
  local sent_bytes = 0
  while remaining_bytes > 0 do
    local bytes_to_send = math.min(frame_size, remaining_bytes)
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

    if should_mask then
      for i = 1, 4 do
        table.insert(frame, mask[i])
      end
    end

    for i = sent_bytes + 1, sent_bytes + 1 + (bytes_to_send - 1) do
      table.insert(frame, data_bytes[i])
    end

    table.insert(frames, bytes_to_string(frame))

    sent_bytes = sent_bytes + bytes_to_send
  end

  return frames
end

---@param header number[] bytes
---@param payload string?
---@return string frame
function UtilsWebsocketConn.to_frame(header, payload)
  local frame = header

  local mask = UtilsWebsocketConn.generate_mask()
  for i = 1, #mask do
    table.insert(header, mask[i])
  end

  if payload then
    local masked = UtilsWebsocketConn.mask_text(payload, mask)
    for i = 1, #masked do
      table.insert(header, masked[i])
    end
  end

  return bytes_to_string(frame)
end

-- Generate a random 16-byte key for the websocket handshake
--
---@return number[]
function UtilsWebsocketConn.generate_websocket_key()
  local key = {}
  math.randomseed(os.time())
  for i = 0, 15 do
    table.insert(key, math.random(0, 255))
  end

  return key
end

function UtilsWebsocketConn:upgrade() self._upgraded = true end

function UtilsWebsocketConn:is_upgraded() return self._upgraded end

M.UtilsWebsocketConn = UtilsWebsocketConn

return M
