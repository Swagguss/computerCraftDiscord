-- client.lua
local modem = peripheral.wrap("right")
modem.open(1) -- Open channel 1 for communication

print("Welcome to the chat!")
write("Enter your username: ")
local username = read()

-- Send join message to server
modem.transmit(1, 1, {type = "join", username = username})

-- Function to display received messages
local function displayMessage(text)
    term.clear()
    term.setCursorPos(1, 1)
    print(text)
end

-- Listen for incoming messages
local function listenForMessages()
    while true do
        local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        if message.type == "chat" or message.type == "system" then
            displayMessage(message.text)
        end
    end
end

-- Start listening for messages in a parallel thread
parallel.waitForAny(listenForMessages, function()
    while true do
        write("> ")
        local text = read()
        modem.transmit(1, 1, {type = "message", text = text})
    end
end)
