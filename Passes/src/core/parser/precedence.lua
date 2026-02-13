local precedence = {}

prec = {
    {op = "or", left = 1, right = 2},
    {op = "and", left = 2, right = 3},
    {op = "<", left = 3, right = 3},
    {op = ">", left = 3, right = 3},
    {op = "<=", left = 3, right = 3},
    {op = ">=", left = 3, right = 3},
    {op = "~=", left = 3, right = 3},
    {op = "==", left = 3, right = 3},
    {op = "..", left = 4, right = 3},
    {op = "+", left = 5, right = 5},
    {op = "-", left = 5, right = 5},
    {op = "*", left = 6, right = 6},
    {op = "/", left = 6, right = 6},
    {op = "%", left = 6, right = 6},
    {op = "^", left = 7, right = 6},
    {op = "#", left = 8, right = 8},
    {op = "not", left = 8, right = 8},
    {op = "-", left = 8, right = 8}, 
}

local precedence_map = {}
for _, p in ipairs(prec) do
    precedence_map[p.op] = {left = p.left, right = p.right}
end

function precedence.get(op)
    return precedence_map[op]
end

function precedence.compare(op1, op2)
    local p1 = precedence_map[op1]
    local p2 = precedence_map[op2]
    
    if not p1 or not p2 then
        return 0
    end
    
    if p1.left > p2.left then
        return 1
    elseif p1.left < p2.left then
        return -1
    else
        return 0
    end
end

function precedence.is_left_assoc(op)
    local p = precedence_map[op]
    return p and p.left >= p.right
end

function precedence.is_right_assoc(op)
    local p = precedence_map[op]
    return p and p.left < p.right
end

function precedence.binary_ops()
    local ops = {}
    for op, _ in pairs(precedence_map) do
        if op ~= "#" and op ~= "not" and op ~= "-" then
            table.insert(ops, op)
        end
    end
    return ops
end

function precedence.unary_ops()
    return {"#", "not", "-"}
end

return precedence
