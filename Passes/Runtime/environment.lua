local environment = {}

function environment.new(parent)
    parent = parent or _G
    
    local env = setmetatable({}, {
        __index = parent,
        __newindex = function(t, k, v)
            if k:match("^[A-Z]") then
                error("cannot modify global: " .. k)
            end
            rawset(t, k, v)
        end
    })
    
    return env
end

function environment.sandbox(allow_io, allow_os, allow_debug)
    local env = {}
    
    local safe_math = {}
    for k, v in pairs(math) do
        if type(v) == "function" then
            safe_math[k] = v
        end
    end
    
    env.math = safe_math
    
    env.string = {
        sub = string.sub,
        gsub = string.gsub,
        find = string.find,
        match = string.match,
        gmatch = string.gmatch,
        len = string.len,
        upper = string.upper,
        lower = string.lower,
        rep = string.rep,
        reverse = string.reverse,
        char = string.char,
        byte = string.byte,
        format = string.format,
    }
    
    env.table = {
        insert = table.insert,
        remove = table.remove,
        concat = table.concat,
        sort = table.sort,
        unpack = table.unpack or unpack,
        pack = table.pack or function(...) return {...} end,
    }
    
    env.print = function(...)
        local args = {...}
        for i = 1, #args do
            args[i] = tostring(args[i])
        end
        print(table.concat(args, "\t"))
    end
    
    env.type = type
    env.tostring = tostring
    env.tonumber = tonumber
    env.pairs = pairs
    env.ipairs = ipairs
    env.next = next
    env.select = select
    env.assert = assert
    env.error = error
    env.pcall = pcall
    env.xpcall = xpcall
    env.getmetatable = getmetatable
    env.setmetatable = setmetatable
    env.rawget = rawget
    env.rawset = rawset
    env.rawequal = rawequal
    
    if allow_io then
        env.io = {
            write = io.write,
            read = io.read,
            open = function(...)
                error("io.open not allowed in sandbox")
            end,
        }
    end
    
    if allow_os then
        env.os = {
            clock = os.clock,
            date = os.date,
            time = os.time,
            difftime = os.difftime,
        }
    end
    
    if allow_debug then
        env.debug = {
            traceback = debug.traceback,
        }
    end
    
    return env
end

function environment.locked(env)
    env = env or _G
    
    local locked = {}
    for k, v in pairs(env) do
        locked[k] = v
    end
    
    local mt = {
        __index = locked,
        __newindex = function(t, k, v)
            error("attempt to modify locked environment: " .. tostring(k))
        end,
        __metatable = false,
    }
    
    return setmetatable({}, mt)
end

function environment.protected(env, whitelist)
    whitelist = whitelist or {}
    
    local proxy = {}
    
    local mt = {
        __index = function(t, k)
            if whitelist[k] then
                return env[k]
            end
            return nil
        end,
        __newindex = function(t, k, v)
            if whitelist[k] then
                env[k] = v
            else
                error("access denied: " .. tostring(k))
            end
        end,
    }
    
    return setmetatable(proxy, mt)
end

function environment.copy(env)
    env = env or _G
    
    local copy = {}
    for k, v in pairs(env) do
        if type(v) == "function" then
            copy[k] = v
        elseif type(v) == "table" then
            copy[k] = environment.copy(v)
        else
            copy[k] = v
        end
    end
    
    return copy
end

function environment.isolate(f)
    local env = environment.sandbox()
    setfenv(f, env)
    return f
end

function environment.track(env)
    env = env or _G
    
    local accessed = {}
    local modified = {}
    
    local mt = {
        __index = function(t, k)
            accessed[k] = (accessed[k] or 0) + 1
            return env[k]
        end,
        __newindex = function(t, k, v)
            modified[k] = (modified[k] or 0) + 1
            env[k] = v
        end,
    }
    
    local proxy = setmetatable({}, mt)
    
    return proxy, {
        accessed = accessed,
        modified = modified,
        report = function()
            print("=== Environment Access Report ===")
            print("\nAccessed variables:")
            for k, v in pairs(accessed) do
                print(string.format("  %s: %d times", k, v))
            end
            print("\nModified variables:")
            for k, v in pairs(modified) do
                print(string.format("  %s: %d times", k, v))
            end
        end
    }
end

return environment
