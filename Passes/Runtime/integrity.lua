local integrity = {}

local function hash_string(s)
    local h = 0
    for i = 1, #s do
        h = h * 31 + string.byte(s, i)
        h = h % 2^31
    end
    return h
end

function integrity.sign(chunk, key)
    key = key or "default_key"
    local data = chunk .. key
    return hash_string(data)
end

function integrity.verify(chunk, signature, key)
    key = key or "default_key"
    local expected = integrity.sign(chunk, key)
    return expected == signature
end

function integrity.check_function(f)
    if type(f) ~= "function" then
        return false, "not a function"
    end
    
    local info = debug and debug.getinfo(f)
    if not info then
        return false, "cannot get function info"
    end
    
    if info.what == "C" then
        return false, "C function cannot be verified"
    end
    
    if info.linedefined == 0 then
        return false, "dynamically generated function"
    end
    
    return true
end

function integrity.check_bytecode(f)
    local info = debug and debug.getinfo(f)
    if not info then return false end
    
    local bytecode = string.dump(f)
    local hash = hash_string(bytecode)
    
    return hash
end

function integrity.wrap_function(f, signature)
    return function(...)
        if not integrity.check_function(f) then
            error("integrity check failed: function modified")
        end
        
        if signature then
            local current = integrity.check_bytecode(f)
            if current ~= signature then
                error("integrity check failed: bytecode modified")
            end
        end
        
        return f(...)
    end
end

function integrity.hash_file(path)
    local file, err = io.open(path, "rb")
    if not file then
        return nil, err
    end
    
    local data = file:read("*all")
    file:close()
    
    return hash_string(data)
end

function integrity.checksum(data)
    local sum = 0
    for i = 1, #data do
        sum = sum + string.byte(data, i)
        sum = sum % 65536
    end
    return sum
end

function integrity.validate_chunk(chunk)
    local marker = string.sub(chunk, 1, 4)
    if marker ~= "\27Lua" then
        return false, "invalid chunk format"
    end
    
    local sum_pos = #chunk - 3
    if sum_pos < 5 then
        return false, "chunk too small"
    end
    
    local stored_sum = 0
    for i = 0, 3 do
        stored_sum = stored_sum * 256 + string.byte(chunk, sum_pos + i)
    end
    
    local data = string.sub(chunk, 1, sum_pos - 1)
    local computed_sum = integrity.checksum(data)
    
    return computed_sum == stored_sum
end

function integrity.protect(f)
    local signature = integrity.check_bytecode(f)
    local wrapped = integrity.wrap_function(f, signature)
    
    local mt = {
        __call = function(_, ...)
            return wrapped(...)
        end,
        __tostring = function()
            return "function: protected"
        end
    }
    
    return setmetatable({}, mt)
end

return integrity
