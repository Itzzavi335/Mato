local transformer = {}
local visitor = require("visitor")
local cloner = require("cloner")

function transformer.transform(ast, rules)
    local v = visitor.new({
        ['*'] = function(node, v)
            for pattern, replacement in pairs(rules) do
                if node.type == pattern then
                    local result = replacement(node, v)
                    if result ~= nil then
                        return result
                    end
                end
            end
            return v:visit_children(node)
        end
    })
    
    return v:visit(cloner.deep_copy(ast))
end

function transformer.replace(ast, target_type, replacement)
    return transformer.transform(ast, {
        [target_type] = function(node)
            return replacement
        end
    })
end

function transformer.rewrite_binary(ast, ops)
    return transformer.transform(ast, {
        binary_op = function(node)
            local left = node.props.left
            local right = node.props.right
            local op = node.props.op
            
            if ops[op] then
                return ops[op](left, right)
            end
            return node
        end
    })
end

function transformer.flatten_block(ast)
    return transformer.transform(ast, {
        block = function(node)
            local statements = {}
            for _, stmt in ipairs(node.props.statements) do
                if stmt.type == "block" then
                    for _, inner in ipairs(stmt.props.statements) do
                        table.insert(statements, inner)
                    end
                else
                    table.insert(statements, stmt)
                end
            end
            node.props.statements = statements
            return node
        end
    })
end

function transformer.remove_dead_code(ast)
    local reachable = true
    
    return transformer.transform(ast, {
        if_statement = function(node)
            if node.props.condition.type == "literal" and node.props.condition.props.value == false then
                return node.props.else_block or ast.create_block({})
            end
            return node
        end,
        
        while_loop = function(node)
            if node.props.condition.type == "literal" and node.props.condition.props.value == false then
                return ast.create_block({})
            end
            return node
        end,
        
        return_stmt = function(node)
            reachable = false
            return node
        end,
        
        ['*'] = function(node)
            if not reachable then
                return nil
            end
            return node
        end
    })
end

function transformer.inline_functions(ast, funcs)
    return transformer.transform(ast, {
        function_call = function(node)
            local func = node.props.func
            if func.type == "identifier" and funcs[func.props.name] then
                local inline_func = funcs[func.props.name]
                local args = node.props.args
                
                for i, param in ipairs(inline_func.params) do
                    if args[i] then
                        ast = transformer.replace(ast, param, args[i])
                    end
                end
                
                return inline_func.body
            end
            return node
        end
    })
end

return transformer
