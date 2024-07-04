-- server.lua
local modem = peripheral.wrap("right")
modem.open(1) -- Open channel 1 for communication

local clients = {}

print("Chat server started...")

while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    
    if message.type == "join" then
        clients[replyChannel] = message.username
        print(message.username .. " joined the chat.")
        modem.transmit(1, replyChannel, {type = "system", text = message.username .. " joined the chat."})
    
    elseif message.type == "message" then
        local username = clients[replyChannel]
        if username then
            local chatMessage = username .. ": " .. message.text
            print(chatMessage)
            for clientChannel, _ in pairs(clients) do
                modem.transmit(1, clientChannel, {type = "chat", text = chatMessage})
            end
        end
    end
end
