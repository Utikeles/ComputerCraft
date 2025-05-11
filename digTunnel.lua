function createHook(message)
    local DiscordHook = require("DiscordHook")
    local webhook = --WEBHOOK URL
    local success, hook = DiscordHook.createWebhook(webhook)
    hook.send(message, "Journaled Universal Intelligent Computing Environment", "https://raw.githubusercontent.com/numikFRKI/numikFRKI/refs/heads/main/assets/juice%20asci.png")
    if not success then
    error("error: " .. hook)
    end
end

function digTunnel(length,escapeEnabled)
    if ((length*3)>turtle.getFuelLevel()) then
        print("<!> Not enough fuel to complete tunnel <!>")
        print("Continuing anyway, will autostop...")
    end
    for i = 1, length do
        local success, data = turtle.inspect()
        local success2, data2 = turtle.inspectUp()
        if (escapeEnabled) then
            if (success and data.name == "minecraft:lava") or (success2 and data2.name == "minecraft:lava") then
                escapeLava()
                break
            end
        end
        -- Dig forward and move forward
        while turtle.detect() do
            turtle.dig()
        end
        turtle.forward()

        -- Dig up to make the tunnel 2 blocks tall
        while turtle.detectUp() do
            turtle.digUp()
        end

        -- Dig bottom left block
        turtle.turnLeft()
        while turtle.detect() do
            turtle.dig()
        end

        -- Dig bottom right block
        turtle.turnRight()
        turtle.turnRight()
        while turtle.detect() do
            turtle.dig()
        end

        -- Move up and dig top right block
        turtle.up()
        while turtle.detect() do
            turtle.dig()
        end

        -- Dig top left block
        turtle.turnLeft()
        success, data = turtle.inspect()
        success2, data2 = turtle.inspectUp()
        if (escapeEnabled) then
            if (success and data.name == "minecraft:lava") or (success2 and data2.name == "minecraft:lava") then
                escapeLava()
                break
            end
        end
        turtle.turnLeft()
        while turtle.detect() do
            turtle.dig()
        end

        -- Return to original position & orientation
        turtle.turnRight()
        turtle.down()
    end
end

function escapeLava()
    local success, data = turtle.inspect()
    local success2, data2 = turtle.inspectUp()
    while (success and data.name == "minecraft:lava") or (success2 and data2.name == "minecraft:lava") do
        for i=1,6,1 do
            turtle.back()
        end
        os.sleep(1)
        success, data = turtle.inspect()
        success2, data2 = turtle.inspectUp()
    end
end

--[[ Main program
-- //<!> MAIN <!>\\            
]]

local args = {...}
local escapeEnabled = false


for i,v in ipairs(args) do
    -- Escape lava argument
    if v=="-e" then
        escapeEnabled = true
        print("Escape enabled")
    end

    -- Tunnel length argument
    if tonumber(v) then
        if tonumber(v) < 0 then
            print("Invalid length. Please enter a positive number.")
        else
            Length = tonumber(v)
        end
    end

    -- Help argument
    if v=="-h" then
        print("HELP PAGE:\nEnter a number after the function to declare tunnel length.\n-h : Displays this help page.\n-e : Enables the escape lava feature.")
    end

    if not(v=="-h") or not(v=="-e") or not(tonumber(v)) then
        print("Invalid arguments! Printing help page...\n\n")
        print("HELP PAGE:\nEnter a number after the function to declare tunnel length.\n-h : Displays this help page.\n-e : Enables the escape lava feature.")
        Length=0
    end

    if i == #args then
        digTunnel(Length,escapeEnabled)
    end
end
