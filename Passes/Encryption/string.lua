local Pass = require(script.Parent.pass)

local StringPass = {}
StringPass.__index = StringPass
setmetatable(StringPass, Pass)

function StringPass.new()
    local self = Pass.new("StringTransform")
    setmetatable(self, StringPass)
    return self
end

local function encode(str)
    local bytes = {}
    for i = 1, #str do
        bytes[#bytes + 1] = string.byte(str, i)
    end
    return "string.char(" .. table.concat(bytes, ",") .. ")"
end

function StringPass:run(context)
    for _, node in ipairs(context.ast or {}) do
        if node.type == "StringLiteral" then
            node.type = "RawExpression"
            node.value = encode(node.value)
        end
    end

    return context
end

return StringPass
