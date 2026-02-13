local encoder = {}
local op = require("opcode")

function encoder.chunk(func)
    local info = debug and debug.getinfo(func)
    if not info then
        return nil
    end
    
    local bytecode = string.dump(func)
    return bytecode
end

function encoder.number(n)
    local bytes = {}
    local negative = n < 0
    n = math.abs(n)
    
    while n > 0 do
        table.insert(bytes, n % 256)
        n = math.floor(n / 256)
    end
    
    if negative then
        bytes[#bytes] = bytes[#bytes] | 0x80
    end
    
    return string.char(unpack(bytes))
end

function encoder.string(s)
    local len = #s
    local data = {string.char(len % 256, math.floor(len / 256))}
    
    for i = 1, len do
        table.insert(data, string.char(string.byte(s, i) ~ 0x42))
    end
    
    return table.concat(data)
end

function encoder.instruction(i)
    local opcode = i[1]
    local args = i[2] or {}
    
    local encoded = {string.char(opcode)}
    
    for _, arg in ipairs(args) do
        if type(arg) == "number" then
            table.insert(encoded, encoder.number(arg))
        elseif type(arg) == "string" then
            table.insert(encoded, encoder.string(arg))
        end
    end
    
    return table.concat(encoded)
end

function encoder.program(instructions)
    local data = {}
    for _, i in ipairs(instructions) do
        table.insert(data, encoder.instruction(i))
    end
    return table.concat(data)
end

return encoder
