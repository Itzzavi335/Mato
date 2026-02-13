local Pass = require(script.Parent.pass)

local IndexPass = {}
IndexPass.__index = IndexPass
setmetatable(IndexPass, Pass)

function IndexPass.new()
    local self = Pass.new("IndexTransform")
    setmetatable(self, IndexPass)
    return self
end

local function toBracket(node)
    if node.index and node.indexType == "Dot" then
        node.indexType = "Bracket"
        node.index = {
            type = "StringLiteral",
            value = node.index
        }
    end
end

function IndexPass:run(context)
    for _, node in ipairs(context.ast or {}) do
        if node.type == "IndexExpression" then
            toBracket(node)
        end
    end

    return context
end

return IndexPass
