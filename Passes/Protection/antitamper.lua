local antitamper = {}

local function dwrap(f)
    return function(...)
        if debug then
            return nil
        end
        return f(...)
    end
end

function antitamper.protect(env)
    env = env or _G
    local protected = {}
    
    for k, v in pairs(env) do
        if type(v) == "function" then
            protected[k] = dwrap(v)
        else
            protected[k] = v
        end
    end
    
    setmetatable(protected, {__index = env})
    return protected
end

function antitamper.checksum(data)
    local hash = 0
    for i = 1, #data do
        hash = bit32.bxor(hash, string.byte(data, i))
        hash = bit32.lshift(hash, 3) + bit32.rshift(hash, 29)
    end
    return hash
end

function antitamper.verify(func)
    if not func then return false end
    local info = debug and debug.getinfo(func, "S")
    if not info then return true end
    return info.what ~= "C" and info.linedefined ~= 0
end

return antitamper
