local rename = {}

local function random_string(len)
    local chars = {}
    local set = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"
    for i = 1, len do
        chars[i] = string.sub(set, math.random(1, #set), math.random(1, #set))
    end
    return table.concat(chars)
end

function rename.variables(code)
    local env = setmetatable({}, {__index = _G})
    local func = loadstring(code)
    setfenv(func, env)
    
    local mapping = {}
    local counter = 0
    
    for k, v in pairs(env) do
        if type(v) ~= "function" and type(k) == "string" and not mapping[k] then
            counter = counter + 1
            mapping[k] = "_" .. string.format("%x", counter)
        end
    end
    
    local result = code
    for old, new in pairs(mapping) do
        result = result:gsub("%f[%a_]" .. old .. "%f[%A_]", new)
    end
    
    return result
end

function rename.functions(code)
    local funcs = {}
    local counter = 1000
    
    for name in code:gmatch("function%s+(%w+)%s*%(") do
        if not funcs[name] then
            counter = counter + 1
            funcs[name] = "f" .. counter
        end
    end
    
    for name in code:gmatch("local%s+function%s+(%w+)%s*%(") do
        if not funcs[name] then
            counter = counter + 1
            funcs[name] = "l" .. counter
        end
    end
    
    local result = code
    for old, new in pairs(funcs) do
        result = result:gsub("%f[%a_]" .. old .. "%f[%A_]", new)
    end
    
    return result
end

function rename.locals(code)
    local lines = {}
    for line in code:gmatch("[^\r\n]+") do
        line = line:gsub("local%s+(%w+)", function(name)
            return "local " .. random_string(6)
        end)
        table.insert(lines, line)
    end
    return table.concat(lines, "\n")
end

function rename.all(code)
    code = rename.functions(code)
    code = rename.variables(code)
    code = rename.locals(code)
    return code
end

return rename
