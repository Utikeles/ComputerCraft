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
write("Enter protocol name: ")
local protocol = read()

while true do
    write("> ")
    local cmd = read()
    if cmd == "exit" then break end
    rednet.broadcast(cmd, protocol)
end