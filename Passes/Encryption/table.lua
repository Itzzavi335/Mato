local Pass = require(script.Parent.pass)

local TablePass = {}
TablePass.__index = TablePass
setmetatable(TablePass, Pass)

function TablePass.new()
    local self = Pass.new("TableTransform")
    setmetatable(self, TablePass)
    return self
end

function TablePass:run(context)
    for _, node in ipairs(context.ast or {}) do
        if node.type == "TableLiteral" then
            for i = #node.entries, 2, -1 do
                local j = math.random(1, i)
                node.entries[i], node.entries[j] = node.entries[j], node.entries[i]
            end
        end
    end

    return context
end

return TablePass
