-- server.lua
local modem = peripheral.wrap("right")
modem.open(1) -- Open channel 1 for incoming join requests

local clients = {}
local usernames = {}
local chatHistory = {}

print("Chat server started...")

while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    
    if message.type == "join" then
        if usernames[message.username] then
            modem.transmit(replyChannel, 1, {type = "error", text = "Username already taken."})
        else
            clients[replyChannel] = message.username
            usernames[message.username] = true
            print(message.username .. " joined the chat.")
            
            -- Send chat history to new client
            for _, chatMessage in ipairs(chatHistory) do
                modem.transmit(replyChannel, 1, {type = "chat", text = chatMessage})
            end
            
            -- Notify everyone about the new user
            local joinMessage = message.username .. " joined the chat."
            table.insert(chatHistory, joinMessage)
            for clientChannel, _ in pairs(clients) do
                modem.transmit(clientChannel, 1, {type = "chat", text = joinMessage})
            end
        end
    
    elseif message.type == "message" then
        local username = clients[replyChannel]
        if username then
            local chatMessage = username .. ": " .. message.text
            table.insert(chatHistory, chatMessage)
            print(chatMessage)
            for clientChannel, _ in pairs(clients) do
                modem.transmit(clientChannel, 1, {type = "chat", text = chatMessage})
            end
        end
    
    elseif message.type == "leave" then
        local username = clients[replyChannel]
        if username then
            usernames[username] = nil
            clients[replyChannel] = nil
            local leaveMessage = username .. " left the chat."
            table.insert(chatHistory, leaveMessage)
            print(leaveMessage)
            for clientChannel, _ in pairs(clients) do
                modem.transmit(clientChannel, 1, {type = "chat", text = leaveMessage})
            end
        end
    end
end
