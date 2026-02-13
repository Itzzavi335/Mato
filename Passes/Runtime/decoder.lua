local decoder = {}

function decoder.decode_bytecode(data, key)
    if key then
        data = decoder.xor_decrypt(data, key)
    end
    
    local func, err = loadstring(data)
    if not func then
        return nil, err
    end
    
    return func
end

function decoder.decode_chunk(chunk, env)
    env = env or {}
    
    local function decode_block(block)
        local result = {}
        local i = 1
        
        while i <= #block do
            local b = string.byte(block, i)
            local op = b % 32
            local len = math.floor(b / 32)
            
            if op == 0 then
                local str_len = len
                local str = string.sub(block, i + 1, i + str_len)
                table.insert(result, {type = "string", value = str})
                i = i + str_len + 1
            elseif op == 1 then
                local num = 0
                for j = 1, len do
                    num = num * 256 + string.byte(block, i + j)
                end
                table.insert(result, {type = "number", value = num})
                i = i + len + 1
            elseif op == 2 then
                table.insert(result, {type = "nil", value = nil})
                i = i + 1
            elseif op == 3 then
                table.insert(result, {type = "boolean", value = true})
                i = i + 1
            elseif op == 4 then
                table.insert(result, {type = "boolean", value = false})
                i = i + 1
            end
        end
        
        return result
    end
    
    local decoded = decode_block(chunk)
    local func_parts = {}
    
    for _, item in ipairs(decoded) do
        if item.type == "string" then
            table.insert(func_parts, item.value)
        elseif item.type == "number" then
            table.insert(func_parts, tostring(item.value))
        elseif item.type == "nil" then
            table.insert(func_parts, "nil")
        elseif item.type == "boolean" then
            table.insert(func_parts, tostring(item.value))
        end
    end
    
    local code = table.concat(func_parts)
    local func, err = loadstring(code, "@decoded")
    
    if not func then
        return nil, err
    end
    
    setfenv(func, env)
    return func
end

function decoder.xor_decrypt(data, key)
    local key_len = #key
    local result = {}
    
    for i = 1, #data do
        local byte = string.byte(data, i)
        local key_byte = string.byte(key, ((i - 1) % key_len) + 1)
        result[i] = string.char(bit32.bxor(byte, key_byte))
    end
    
    return table.concat(result)
end

function decoder.base64_decode(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = string.gsub(data, '[^' .. b .. '=]', '')
    
    return (data:gsub('.', function(x)
        if x == '=' then return '' end
        local r, f = '', (b:find(x) - 1)
        for i = 6, 1, -1 do
            r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and '1' or '0')
        end
        return r
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if #x ~= 8 then return '' end
        local c = 0
        for i = 1, 8 do
            c = c + (x:sub(i, i) == '1' and 2 ^ (8 - i) or 0)
        end
        return string.char(c)
    end))
end

function decoder.decode_header(data)
    local magic = string.sub(data, 1, 4)
    if magic ~= "\27Lua" then
        return nil, "invalid magic number"
    end
    
    local version = string.byte(data, 5)
    local format = string.byte(data, 6)
    local endian = string.byte(data, 7)
    local int_size = string.byte(data, 8)
    local size_t_size = string.byte(data, 9)
    local instr_size = string.byte(data, 10)
    local number_size = string.byte(data, 11)
    
    return {
        version = version,
        format = format,
        endian = endian,
        int_size = int_size,
        size_t_size = size_t_size,
        instr_size = instr_size,
        number_size = number_size
    }
end

return decoder
