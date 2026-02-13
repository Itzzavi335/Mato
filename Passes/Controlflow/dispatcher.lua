local dispatcher = {}

function dispatcher.new(handlers)
    local mt = {}
    
    function mt:dispatch(id, ...)
        local handler = handlers[id]
        if handler then
            return handler(...)
        end
        return nil, "no handler for id: " .. tostring(id)
    end
    
    function mt:register(id, handler)
        handlers[id] = handler
    end
    
    function mt:unregister(id)
        handlers[id] = nil
    end
    
    return setmetatable({}, {
        __index = mt,
        __call = function(_, id, ...)
            return mt.dispatch({}, id, ...)
        end
    })
end

function dispatcher.table(ops)
    return function(op, ...)
        local func = ops[op]
        if func then
            return func(...)
        end
        error("unknown operation: " .. tostring(op))
    end
end

function dispatcher.chain(...)
    local dispatchers = {...}
    
    return function(id, ...)
        for i = 1, #dispatchers do
            local ok, result = pcall(dispatchers[i], id, ...)
            if ok and result ~= nil then
                return result
            end
        end
        return nil
    end
end

function dispatcher.cache(d)
    local cache = {}
    
    return function(id, ...)
        if cache[id] then
            return cache[id](...)
        end
        
        local result = d(id, ...)
        if type(result) == "function" then
            cache[id] = result
        end
        
        return result
    end
end

return dispatcher
