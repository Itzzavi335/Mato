local metahide = {}

function metahide.table(tbl)
    local proxy = {}
    local meta = {
        __index = function(_, k)
            return tbl[k]
        end,
        __newindex = function(_, k, v)
            tbl[k] = v
        end,
        __metatable = "hidden"
    }
    return setmetatable(proxy, meta)
end

function metahide.function(func)
    local proxy = function(...)
        return func(...)
    end
    
    if debug and debug.setmetatable then
        debug.setmetatable(proxy, {
            __metatable = "function hidden"
        })
    end
    
    return proxy
end

function metahide.string(s)
    local proxy = s
    local meta = {
        __index = function(_, k)
            return string[k]
        end,
        __metatable = "string hidden"
    }
    return setmetatable(proxy, meta)
end

function metahide.environment(env)
    env = env or _G
    local hidden = {}
    
    for k, v in pairs(env) do
        if type(v) == "table" then
            hidden[k] = metahide.table(v)
        elseif type(v) == "function" then
            hidden[k] = metahide.function(v)
        else
            hidden[k] = v
        end
    end
    
    local mt = {
        __index = hidden,
        __newindex = hidden,
        __metatable = "environment hidden"
    }
    
    return setmetatable({}, mt)
end

function metahide.metatable(obj)
    local old_mt = getmetatable(obj)
    
    local new_mt = {
        __index = function(t, k)
            if k == "metatable" then
                return nil
            end
            if old_mt and old_mt.__index then
                return old_mt.__index(t, k)
            end
            return rawget(t, k)
        end,
        __metatable = "locked"
    }
    
    return setmetatable(obj, new_mt)
end

function metahide.all(obj)
    local obj_type = type(obj)
    
    if obj_type == "table" then
        return metahide.table(obj)
    elseif obj_type == "function" then
        return metahide.function(obj)
    elseif obj_type == "string" then
        return metahide.string(obj)
    elseif obj_type == "thread" then
        return obj
    end
    
    return obj
end

return metahide
