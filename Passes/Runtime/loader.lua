local loader = {}

function loader.load_bytecode(data)
    local func, err = loadstring(data)
    if not func then
        return nil, "failed to load bytecode: " .. tostring(err)
    end
    return func
end

function loader.load_protected(data, env)
    env = env or {}
    local chunk, err = loadstring(data, "@protected")
    if not chunk then
        return nil, err
    end
    
    setfenv(chunk, env)
    
    local ok, result = pcall(chunk)
    if not ok then
        return nil, result
    end
    
    return result
end

function loader.load_vm(code, vm_handler)
    local env = {vm = vm_handler}
    setmetatable(env, {__index = _G})
    
    local func, err = loadstring(code, "@vmcode")
    if not func then
        return nil, err
    end
    
    setfenv(func, env)
    return func
end

function loader.load_sandboxed(code, allowed_globals)
    allowed_globals = allowed_globals or {}
    local env = {}
    
    for _, name in ipairs(allowed_globals) do
        env[name] = _G[name]
    end
    
    env.print = function(...)
        local args = {...}
        for i = 1, #args do
            args[i] = tostring(args[i])
        end
        print(table.concat(args, "\t"))
    end
    
    env.string = {sub = string.sub, len = string.len, gsub = string.gsub}
    env.table = {insert = table.insert, remove = table.remove, concat = table.concat}
    env.math = {random = math.random, floor = math.floor, ceil = math.ceil}
    
    local func, err = loadstring(code, "@sandbox")
    if not func then
        return nil, err
    end
    
    setfenv(func, env)
    return func
end

function loader.load_remote(url, callback)
    if not socket and not http then
        return nil, "no network support"
    end
    
    local handler = socket and socket.http or http.request
    
    local ok, result = pcall(function()
        return handler(url)
    end)
    
    if not ok then
        return nil, result
    end
    
    local func, err = loader.load_protected(result)
    if callback then
        callback(func, err)
    end
    
    return func, err
end

function loader.create_loader(env)
    return function(code)
        return loader.load_protected(code, env)
    end
end

return loader
