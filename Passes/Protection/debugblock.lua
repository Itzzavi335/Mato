local debugblock = {}

local blocklist = {
    "debug",
    "hook",
    "trace",
    "probe",
    "inspect"
}

function debugblock.check()
    local blocked = false
    
    for _, v in pairs(blocklist) do
        if rawget(_G, v) then
            blocked = true
        end
    end
    
    if debug then
        local threads = {}
        local mt = getmetatable(debug)
        if mt and mt.__gc then
            blocked = true
        end
    end
    
    return not blocked
end

function debugblock.run(f, ...)
    if not debugblock.check() then
        return nil, "debugger detected"
    end
    
    local old_debug = debug
    debug = nil
    
    local results = {pcall(f, ...)}
    
    debug = old_debug
    
    if not results[1] then
        return nil, results[2]
    end
    
    return select(2, unpack(results))
end

function debugblock.hook_check()
    local status = pcall(function()
        local a = 1
        local b = 2
        local c = a + b
        return c == 3
    end)
    return status
end

return debugblock
