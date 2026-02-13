local vmguard = {}

local function get_vm_hash()
    local hash = 0
    local step = 1
    
    for i = 1, 100 do
        hash = hash + i * step
        step = step * 2
        if step > 1000000 then
            step = 1
        end
    end
    
    return hash
end

function vmguard.spawn(f, ...)
    local co = coroutine.create(f)
    local success, result = coroutine.resume(co, ...)
    
    if not success then
        return nil, result
    end
    
    while coroutine.status(co) ~= "dead" do
        success, result = coroutine.resume(co)
        if not success then
            return nil, result
        end
    end
    
    return result
end

function vmguard.protect_thread(co)
    if type(co) ~= "thread" then
        co = coroutine.create(co)
    end
    
    local mt = {
        __gc = function()
            while coroutine.status(co) ~= "dead" do
                coroutine.resume(co)
            end
        end
    }
    
    return setmetatable({co}, mt)[1]
end

function vmguard.isolate(f, env)
    env = env or {}
    local chunk = load(string.dump(f), "@isolated")
    setfenv(chunk, env)
    return chunk()
end

function vmguard.vm_check()
    local a = {}
    for i = 1, 1000 do
        a[i] = i * i
    end
    return get_vm_hash()
end

return vmguard
