-- Don't touch if you don't know what your doing.

local opcode = {
    -- stack operations
    PUSH = 1,
    POP = 2,
    DUP = 3,
    SWAP = 4,
    
    -- arithmetic
    ADD = 10,
    SUB = 11,
    MUL = 12,
    DIV = 13,
    MOD = 14,
    POW = 15,
    
    -- comparison
    EQ = 20,
    LT = 21,
    GT = 22,
    LE = 23,
    GE = 24,
    
    -- control flow
    JMP = 30,
    JZ = 31,
    JNZ = 32,
    CALL = 33,
    RET = 34,
    
    -- variables
    LOAD = 40,
    STORE = 41,
    LOADK = 42,
    
    -- tables
    NEWTABLE = 50,
    GETTABLE = 51,
    SETTABLE = 52,
    
    -- misc
    MOVE = 60,
    LEN = 61,
    CONCAT = 62,
    NOT = 63,
    NOP = 64,
}

local names = {}
for k, v in pairs(opcode) do
    names[v] = k
end

function opcode.name(code)
    return names[code] or "UNKNOWN"
end

function opcode.encode(op)
    if type(op) == "string" then
        return opcode[op] or 0
    end
    return op
end

function opcode.decode(num)
    return names[num] or num
end

function opcode.is_jump(code)
    return code == opcode.JMP or code == opcode.JZ or code == opcode.JNZ
end

return opcode
