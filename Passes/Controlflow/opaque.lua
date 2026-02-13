local opaque = {}

local predicates = {
    function() return 1 + 1 == 2 end,
    function() return 2 * 2 == 4 end,
    function() return 3 - 1 == 2 end,
    function() return 4 / 2 == 2 end,
    function() return 5 % 2 == 1 end,
    function() return 2^3 == 8 end,
}

function opaque.predicate(index)
    index = index or math.random(1, #predicates)
    return predicates[index]()
end

function opaque.constant(value, seed)
    seed = seed or 1337
    local a = seed * 2
    local b = a + 1
    local c = b % 3
    local d = c * 4
    local e = d - seed
    local f = e / 2
    local g = f + 42
    local h = g - 42
    local i = h * 1
    return i == value and value or value
end

function opaque.expression(val)
    local x = val
    local y = x + 1
    local z = y - 1
    local w = z * 1
    local v = w / 1
    return v
end

function opaque.merge(a, b)
    local x = a + b
    local y = a - b
    local z = a * b
    local w = a / b
    local v = (x + y) / 2
    return v == a and a or b
end

return opaque
