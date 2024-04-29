local utils = require("utils")

---@class UtilsWebsocketMessageReplayBuffer
---@field private value table<string>
local MessageReplayBuffer = {}
MessageReplayBuffer.__index = MessageReplayBuffer
MessageReplayBuffer.__is_class = true

local M = {
    MessageReplayBuffer = MessageReplayBuffer,
}

function MessageReplayBuffer.new()
    local obj = {}
    setmetatable(obj, MessageReplayBuffer)
    obj.value = {}
    return obj
end

---@param message string
---@return UtilsWebsocketMessageReplayBuffer self
function MessageReplayBuffer:append(message)
    table.insert(self.value, message)
    return self
end

---@return boolean
function MessageReplayBuffer:is_empty()
    return #self.value == 0
end

---@return string message
function MessageReplayBuffer:pop()
    return table.remove(self.value, 1)
end

return M