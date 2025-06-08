local modemSide
for _, side in ipairs(peripheral.getNames()) do
    local p = peripheral.wrap(side)
    if peripheral.getType(side) == "modem" and p.isWireless and p.isWireless() then
        modemSide = side
        break
    end
end

if not modemSide then
    print("No wireless modem found!")
    return
end

rednet.open(modemSide)
print("Enter the ID of the host computer (or type 'global' for all):")
local hostInput = read()
local globalMode = (hostInput == "global")
local hostId = tonumber(hostInput)

if not globalMode and not hostId then
    print("Invalid ID.")
    return
end

if globalMode then
    print("Global mode enabled. Commands will be sent to all listening hosts. Type 'exit' to quit.")
else
    print("Connected to host "..hostId..". Type 'exit' to quit.")
end

while true do
    io.write("> ")
    local cmd = read()
    if cmd == "exit" then break end

    if globalMode then
        -- Broadcast to all hosts
        rednet.broadcast(cmd, "telnet")
        -- Collect responses for a short period
        print("Waiting for responses (5s)...")
        local responses = {}
        local timer = os.startTimer(5)
        while true do
            local event, p1, p2, p3 = os.pullEvent()
            if event == "rednet_message" and p3 == "telnet" then
                print("["..p1.."]: " .. tostring(p2))
            elseif event == "timer" and p1 == timer then
                break
            end
        end
    else
        -- Single host mode
        rednet.send(hostId, cmd, "telnet")
        local senderId, response = rednet.receive("telnet", 5)
        if senderId == hostId then
            print(response)
        else
            print("No response from host.")
        end
    end
end