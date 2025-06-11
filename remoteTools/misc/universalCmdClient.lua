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

::start::

rednet.open(modemSide)
write("Enter protocol name: ")
local protocol = read()

local cmdList = {}
local i = 1

while true do
    write("> ")
    term.setCursorBlink(true)
    local input = ""
    local historyIndex = i
    local xPrompt, yPrompt = term.getCursorPos()
    while true do
        local event, param = os.pullEvent()
        if event == "char" then
            input = input .. param
            write(param)
        elseif event == "key" then
            if param == keys.enter then
                print()
                break
            elseif param == keys.up then
                if historyIndex > 1 and cmdList[historyIndex - 1] then
                    local _, y = term.getCursorPos()
                    term.setCursorPos(1, y)
                    term.clearLine()
                    historyIndex = historyIndex - 1
                    input = cmdList[historyIndex]
                    write("> " .. input)
                end
            elseif param == keys.down then
                local _, y = term.getCursorPos()
                term.setCursorPos(1, y)
                term.clearLine()
                if cmdList[historyIndex + 1] then
                    historyIndex = historyIndex + 1
                    input = cmdList[historyIndex]
                    write("> " .. input)
                else
                    historyIndex = i
                    input = ""
                    write("> ")
                end
            elseif param == keys.backspace then
                if #input > 0 then
                    input = input:sub(1, -2)
                    local x, y = term.getCursorPos()
                    term.setCursorPos(x - 1, y)
                    write(" ")
                    term.setCursorPos(x - 1, y)
                end
            end
        end
    end
    term.setCursorBlink(false)
    cmdList[i] = input
    if input == "exit" then cmdList = {} break end
    rednet.broadcast(input, protocol)
    i = i + 1
end

goto start
