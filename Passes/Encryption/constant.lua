local Pass = require(script.Parent.pass)

local ConstantPass = {}
ConstantPass.__index = ConstantPass
setmetatable(ConstantPass, Pass)

function ConstantPass.new()
    local self = Pass.new("ConstantFold")
    setmetatable(self, ConstantPass)
    return self
end

local function foldBinary(a, op, b)
    if op == "+" then
        return a + b
    elseif op == "-" then
        return a - b
    elseif op == "*" then
        return a * b
    elseif op == "/" and b ~= 0 then
        return a / b
    end
end

function ConstantPass:run(context)
    for _, node in ipairs(context.ast or {}) do
        if node.type == "BinaryExpression" then
            if node.left.type == "NumberLiteral" and node.right.type == "NumberLiteral" then
                local result = foldBinary(node.left.value, node.operator, node.right.value)
                if result then
                    node.type = "NumberLiteral"
                    node.value = result
                    node.left = nil
                    node.right = nil
                    node.operator = nil
                end
            end
        end
    end

    return context
end

return ConstantPass
