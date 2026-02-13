local Registry = {}
Registry.__index = Registry

function Registry.new()
    local self = setmetatable({}, Registry)
    self._passes = {}
    return self
end

function Registry:register(pass)
    if not pass or not pass.getName then
        return
    end

    local name = pass:getName()
    self._passes[name] = pass
end

function Registry:get(name)
    return self._passes[name]
end

function Registry:getAll()
    local result = {}
    for name, pass in pairs(self._passes) do
        result[name] = pass
    end
    return result
end

function Registry:has(name)
    return self._passes[name] ~= nil
end

return Registry
