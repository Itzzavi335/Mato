local Pass = {}
Pass.__index = Pass

function Pass.new(name)
    local self = setmetatable({}, Pass)
    self.name = name or "UnnamedPass"
    self.dependencies = {}
    return self
end

function Pass:getName()
    return self.name
end

function Pass:addDependency(passName)
    if type(passName) == "string" then
        table.insert(self.dependencies, passName)
    end
end

function Pass:getDependencies()
    local list = {}
    for i = 1, #self.dependencies do
        list[i] = self.dependencies[i]
    end
    return list
end

function Pass:run(context)
    return context
end

return Pass
