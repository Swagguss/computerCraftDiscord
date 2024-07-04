-- client.lua
local modem = peripheral.wrap("right")
modem.open(1) -- Open channel 1 for communication

local chatHistory = {}

local function promptUsername()
    while true do
        term.clear()
        term.setCursorPos(1, 1)
        print("Welcome to the chat!")
        write("Enter your username: ")
        local username = read()

        -- Send join message to server
        modem.transmit(1, 1, {type = "join", username = username})

        -- Wait for server response
        local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        if message.type == "error" then
            print(message.text)
            sleep(2)
        else
            return username
        end
    end
end

local username = promptUsername()

-- Function to display chat history
local function displayChatHistory()
    term.clear()
    term.setCursorPos(1, 1)
    for _, message in ipairs(chatHistory) do
        print(message)
    end
end

-- Listen for incoming messages
local function listenForMessages()
    while true do
        local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        if message.type == "chat" then
            table.insert(chatHistory, message.text)
            displayChatHistory()
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
