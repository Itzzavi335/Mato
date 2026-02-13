local lifter = {}

function lifter.function_to_ast(func)
    local info = debug and debug.getinfo(func)
    if not info then
        return nil
    end
    
    local ast = {
        type = "function",
        name = info.name or "(anonymous)",
        params = {},
        body = {},
        upvalues = {},
    }
    
    if debug and debug.getupvalue then
        local i = 1
        while true do
            local name, value = debug.getupvalue(func, i)
            if not name then break end
            table.insert(ast.upvalues, {name = name, value = value})
            i = i + 1
        end
    end
    
    return ast
end

function lifter.bytecode_to_ast(bytecode)
    local func = loadstring(bytecode)
    return lifter.function_to_ast(func)
end

function lifter.ast_to_bytecode(ast)
    local chunks = {}
    
    table.insert(chunks, "function(")
    for i, param in ipairs(ast.params) do
        if i > 1 then table.insert(chunks, ",") end
        table.insert(chunks, param)
    end
    table.insert(chunks, ")\n")
    
    for _, node in ipairs(ast.body) do
        table.insert(chunks, lifter.node_to_string(node))
        table.insert(chunks, "\n")
    end
    
    table.insert(chunks, "end")
    
    return table.concat(chunks)
end

function lifter.node_to_string(node)
    if node.type == "call" then
        return node.func .. "(" .. table.concat(node.args, ",") .. ")"
    elseif node.type == "assign" then
        return node.var .. "=" .. node.value
    elseif node.type == "return" then
        return "return " .. (node.value or "")
    else
        return "-- unknown node type"
    end
end

function lifter.constant_propagation(ast)
    local constants = {}
    
    local function traverse(node)
        if node.type == "assign" and type(node.value) == "number" then
            constants[node.var] = node.value
        end
        
        if constants[node.var] and node.type == "variable" then
            return {type = "number", value = constants[node.var]}
        end
        
        return node
    end
    
    return traverse(ast)
end

return lifter
