local DependencyResolver = {}
DependencyResolver.__index = DependencyResolver

function DependencyResolver.new(registry)
    local self = setmetatable({}, DependencyResolver)
    self.registry = registry
    return self
end

local function visit(name, registry, resolved, seen, stack)
    if resolved[name] then
        return
    end

    if seen[name] then
        error("Circular dependency detected at pass: " .. name)
    end

    seen[name] = true

    local pass = registry:get(name)
    if not pass then
        error("Unknown pass: " .. name)
    end

    local deps = pass:getDependencies()
    for i = 1, #deps do
        visit(deps[i], registry, resolved, seen, stack)
    end

    resolved[name] = true
    table.insert(stack, pass)
end

function DependencyResolver:resolve()
    local ordered = {}
    local resolved = {}
    local seen = {}

    local all = self.registry:getAll()
    for name in pairs(all) do
        visit(name, self.registry, resolved, seen, ordered)
    end

    return ordered
end

return DependencyResolver
