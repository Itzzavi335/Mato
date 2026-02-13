local envlock = {}

function envlock.freeze(env)
    env = env or _G
    
    if type(env) ~= "table" then
        return env
    end
    
    local locked = {}
    
    for k, v in pairs(env) do
        locked[k] = v
    end
    
    local mt = {
        __index = locked,
        __newindex = function(t, k, v)
            error("attempt to modify locked environment: " .. tostring(k))
        end,
        __metatable = "locked"
    }
    
    setmetatable(locked, mt)
    return locked
end

function envlock.is_locked(env)
    local mt = getmetatable(env)
    return mt and mt.__metatable == "locked"
end

function envlock.whitelist(env, allowed)
    allowed = allowed or {}
    
    local mt = {
        __index = function(t, k)
            if allowed[k] then
                return env[k]
            end
            return nil
        end,
        __newindex = function(t, k, v)
            if allowed[k] then
                env[k] = v
            else
                error("access denied: " .. tostring(k))
            end
        end
    }
    
    return setmetatable({}, mt)
end

function envlock.snapshot(env)
    local snap = {}
    for k, v in pairs(env) do
        snap[k] = v
    end
    return snap
end

return envlock
