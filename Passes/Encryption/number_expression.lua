local Pass = require(script.Parent.pass)

local NumberExpressionPass = {}
NumberExpressionPass.__index = NumberExpressionPass
setmetatable(NumberExpressionPass, Pass)

function NumberExpressionPass.new()
    local self = Pass.new("NumberExpression")
    setmetatable(self, NumberExpressionPass)
    return self
end

local function splitNumber(n)
    local a = math.random(1, n)
    local b = n - a
    return a, b
end

function NumberExpressionPass:run(context)
    for _, node in ipairs(context.ast or {}) do
        if node.type == "NumberLiteral" and node.value > 1 then
            local a, b = splitNumber(node.value)
            node.type = "BinaryExpression"
            node.operator = "+"
            node.left = { type = "NumberLiteral", value = a }
            node.right = { type = "NumberLiteral", value = b }
            node.value = nil
        end
    end

    return context
end

return NumberExpressionPass
