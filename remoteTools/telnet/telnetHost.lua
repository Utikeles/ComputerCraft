-- locks
local old_pullEvent = os.pullEvent
os.pullEvent = os.pullEventRaw

local modemSide
local monitorPresent = false
for _, side in ipairs(peripheral.getNames()) do
    local p = peripheral.wrap(side)
    if peripheral.getType(side) == "monitor" then
        monitorPresent = true
    end
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
term.clear()
term.setCursorPos(1, 1)
if turtle then
    term.setTextColor(colors.orange)
    write("<")
    term.setTextColor(colors.red)
    write("!")
    term.setTextColor(colors.orange)
    write("> This computer has been commandeered by JUICE, do not resist. <")
    term.setTextColor(colors.red)
    write("!")
    term.setTextColor(colors.orange)
    write(">")
    print()
    print()
    print([[

     __      .__              
    |__|__ __|__| ____  ____  
    |  |  |  \  |/ ___\/ __ \ 
    |  |  |  /  \  \__\  ___/ 
/\__|  |____/|__|\___  >___  >
\______|             \/    \/ 

]])
    term.setTextColor(colors.white)
else 
    term.setTextColor(colors.orange)
    write("<")
    term.setTextColor(colors.red)
    write("!")
    term.setTextColor(colors.orange)
    write("> This computer has been commandeered by JUICE, do not resist. <")
    term.setTextColor(colors.red)
    write("!")
    term.setTextColor(colors.orange)
    write(">")
    print()
    print()
    print([[
   88             88                        
   ""             ""                        
                                            
   88 88       88 88  ,adPPYba,  ,adPPYba,  
   88 88       88 88 a8"     "" a8P_____88  
   88 88       88 88 8b         8PP"""""""  
   88 "8a,   ,a88 88 "8a,   ,aa "8b,   ,aa  
   88  `"YbbdP'Y8 88  `"Ybbd8"'  `"Ybbd8"'  
  ,88                                       
888P"   
]])
    term.setTextColor(colors.white)
end

-- Simple buffer terminal object
local function makeBufferTerm()
    local buffer = {}
    local function write(text) table.insert(buffer, tostring(text)) end
    local function blit(text, fg, bg) write(text) end
    local function isColour() return term.isColour() end
    local function getTextColor() return colors.white end
    local function getBackgroundColor() return colors.black end
    local function setTextColor(_) end
    local function setBackgroundColor(_) end
    local function clear() end
    local function clearLine() end
    local function setCursorPos(_, _) end
    local function setCursorBlink(_) end
    local function getCursorPos() return 1, 1 end
    local function getSize() return 51, 19 end
    return {
        write = write,
        blit = blit,
        isColour = isColour,
        getTextColor = getTextColor,
        getBackgroundColor = getBackgroundColor,
        setTextColor = setTextColor,
        setBackgroundColor = setBackgroundColor,
        clear = clear,
        clearLine = clearLine,
        setCursorPos = setCursorPos,
        setCursorBlink = setCursorBlink,
        getCursorPos = getCursorPos,
        getSize = getSize,
        getBuffer = function() return table.concat(buffer) end
    }
end

-- Run a shell command in a fresh environment
local function runShellCommand(cmd)
    local args = {}
    for word in cmd:gmatch("%S+") do
        table.insert(args, word)
    end
    if #args == 0 then return false end
    local program = shell.resolveProgram(args[1])
    if not program then return false end
    return os.run({}, program, table.unpack(args, 2))
end

while true do
    local senderId, msg, proto = rednet.receive("telnet")
    if type(msg) == "string" then
        local out = ""
        if msg == "release" then
            out = "Host released. Program terminating."
            rednet.send(senderId, out, "telnet")
            os.pullEvent = old_pullEvent -- remove locks
            term.clear()
            term.setCursorPos(1, 1)
            term.setTextColor(colors.red)
            print("Release order received. Removing locks and terminating program...")
            sleep(3)
            term.setTextColor(colors.white)
            break
        elseif msg:sub(1,4) == "lua " then
            -- Run as Lua code
            local code = msg:sub(5)
            local func, err = load(code, "remote", "t", _ENV)
            if not func then
                out = "Compile error: " .. tostring(err)
            else
                -- Capture print output
                local buffer = {}
                local function capturePrint(...)
                    local t = {}
                    for i=1,select("#", ...) do
                        table.insert(t, tostring(select(i, ...)))
                    end
                    table.insert(buffer, table.concat(t, "\t"))
                end
                local oldPrint = print
                print = capturePrint
                local ok, result = pcall(func)
                print = oldPrint
                if not ok then
                    out = "Runtime error: " .. tostring(result)
                else
                    out = table.concat(buffer, "\n")
                    if result ~= nil then
                        out = out .. "\n(Returned: " .. tostring(result) .. ")"
                    end
                end
            end
        else
            -- Run as shell command in a fresh environment
            local bufferTerm = makeBufferTerm()
            local oldTerm = term.current()
            term.redirect(bufferTerm)
            local ok = runShellCommand(msg)
            term.redirect(oldTerm)
            out = bufferTerm.getBuffer()
            if not ok then
                out = (out or "") .. "\n[Command failed or not found]"
            end
        end
        rednet.send(senderId, out, "telnet")
    end
end