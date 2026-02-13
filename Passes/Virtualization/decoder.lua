local decoder = {}
local op = require("opcode")

function decoder.chunk(bytecode)
    local func = loadstring(bytecode)
    return func
end

function decoder.number(bytes, pos)
    pos = pos or 1
    local n = 0
    local shift = 0
    local byte = string.byte(bytes, pos)
    
    while byte and byte ~= 0 do
        n = n + (byte & 0x7F) * (2^shift)
        shift = shift + 7
        pos = pos + 1
        byte = string.byte(bytes, pos)
    end
    
    return n, pos
end

function decoder.string(bytes, pos)
    pos = pos or 1
    local len = string.byte(bytes, pos)
    pos = pos + 1
    
    local s = {}
    for i = 1, len do
        local byte = string.byte(bytes, pos)
        table.insert(s, string.char(byte ~ 0x42))
        pos = pos + 1
    end
    
    return table.concat(s), pos
end

function decoder.instruction(bytes, pos)
    pos = pos or 1
    local opcode = string.byte(bytes, pos)
    pos = pos + 1
    
    local args = {}
    
    if op.is_jump(opcode) then
        local target, newpos = decoder.number(bytes, pos)
        args[1] = target
        pos = newpos
    elseif opcode == op.LOADK then
        local val, newpos = decoder.string(bytes, pos)
        args[1] = val
        pos = newpos
    end
    
    return {opcode, args}, pos
end

function decoder.program(bytes)
    local instructions = {}
    local pos = 1
    
    while pos <= #bytes do
        local inst, newpos = decoder.instruction(bytes, pos)
        table.insert(instructions, inst)
        pos = newpos
    end
    
    return instructions
end

return decoder
