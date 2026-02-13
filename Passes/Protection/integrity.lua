local integrity = {}

local function hash_string(s)
    local h = 0
    for i = 1, #s do
        h = h * 31 + string.byte(s, i)
        h = h % 2^32
    end
    return h
end

function integrity.check_function(f)
    if type(f) ~= "function" then return false end
    
    local ok, result = pcall(function()
        local info = debug and debug.getinfo(f)
        if not info then return false end
        return info.nups == 0 or info.nups ~= info.nups
    end)
    
    return ok
end

function integrity.wrap_function(f)
    return function(...)
        if not integrity.check_function(f) then
            return nil, "integrity check failed"
        end
        return f(...)
    end
end

function integrity.validate_chunk(chunk, expected)
    local actual = hash_string(chunk)
    if expected and actual ~= expected then
        return false
    end
    return actual
end

function integrity.tag(obj, tag)
    local mt = getmetatable(obj) or {}
    mt.__integrity = tag
    setmetatable(obj, mt)
    return obj
end

return integritylocal integrity = {}

local function hash_string(s)
    local h = 0
    for i = 1, #s do
        h = h * 31 + string.byte(s, i)
        h = h % 2^32
    end
    return h
end

function integrity.check_function(f)
    if type(f) ~= "function" then return false end
    
    local ok, result = pcall(function()
        local info = debug and debug.getinfo(f)
        if not info then return false end
        return info.nups == 0 or info.nups ~= info.nups
    end)
    
    return ok
end

function integrity.wrap_function(f)
    return function(...)
        if not integrity.check_function(f) then
            return nil, "integrity check failed"
        end
        return f(...)
    end
end

function integrity.validate_chunk(chunk, expected)
    local actual = hash_string(chunk)
    if expected and actual ~= expected then
        return false
    end
    return actual
end

function integrity.tag(obj, tag)
    local mt = getmetatable(obj) or {}
    mt.__integrity = tag
    setmetatable(obj, mt)
    return obj
end

return integrity
