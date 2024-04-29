local websocket_client = require("utils.websocket.client")
local websocket_server = require("utils.websocket.server")

local port = 89209

local server = websocket_server.create({
  port = port,
  on_client_message = function (client, message)
    print("Server received message: " .. message)
    client:send_data("Hello from server. Reply of " .. message)
  end
})
server:start()

local client = websocket_client.create("127.0.0.1", port, {
  on_message = function(client, message)
    print("Client received message: " .. message)
  end,
  on_connect = function(client)
    print("Client connected")
    client:send_data("Hello from client")
  end
})
client:connect()

client:send_data("Hello from client 1")
client:send_data("Hello from client 2")
client:send_data("Hello from client 3")