local validator = {}
local visitor = require("visitor")

local rules = {
    program = function(node)
        return true, nil
    end,
    
    block = function(node)
        if not node.props.statements then
            return false, "block missing statements"
        end
        return true, nil
    end,
    
    assignment = function(node)
        if not node.props.lhs then
            return false, "assignment missing lhs"
        end
        if not node.props.rhs or #node.props.rhs == 0 then
            return false, "assignment missing rhs"
        end
        return true, nil
    end,
    
    local_decl = function(node)
        if not node.props.names or #node.props.names == 0 then
            return false, "local declaration missing names"
        end
        return true, nil
    end,
    
    function_decl = function(node)
        if not node.props.name then
            return false, "function declaration missing name"
        end
        if not node.props.body then
            return false, "function declaration missing body"
        end
        return true, nil
    end,
    
    function_call = function(node)
        if not node.props.func then
            return false, "function call missing function"
        end
        return true, nil
    end,
    
    if_statement = function(node)
        if not node.props.condition then
            return false, "if statement missing condition"
        end
        if not node.props.then_block then
            return false, "if statement missing then block"
        end
        return true, nil
    end,
    
    while_loop = function(node)
        if not node.props.condition then
            return false, "while loop missing condition"
        end
        if not node.props.body then
            return false, "while loop missing body"
        end
        return true, nil
    end,
    
    binary_op = function(node)
        if not node.props.left then
            return false, "binary op missing left operand"
        end
        if not node.props.right then
            return false, "binary op missing right operand"
        end
        if not node.props.op then
            return false, "binary op missing operator"
        end
        return true, nil
    end,
    
    identifier = function(node)
        if not node.props.name then
            return false, "identifier missing name"
        end
        return true, nil
    end,
    
    literal = function(node)
        return true, nil
    end,
}

function validator.validate(ast)
    local errors = {}
    
    local v = visitor.new({
        ['*'] = function(node)
            local rule = rules[node.type]
            if rule then
                local ok, err = rule(node)
                if not ok then
                    table.insert(errors, {
                        node = node,
                        type = node.type,
                        error = err
                    })
                end
            end
            return v:visit_children(node)
        end
    })
    
    v:visit(ast)
    
    if #errors > 0 then
        return false, errors
    end
    
    return true, nil
end

function validator.check_scope(ast)
    local scopes = {{}}
    local errors = {}
    
    local v = visitor.new({
        block = function(node)
            table.insert(scopes, {})
            v:visit_children(node)
            table.remove(scopes)
            return node
        end,
        
        local_decl = function(node)
            local current = scopes[#scopes]
            for _, name in ipairs(node.props.names) do
                if current[name.props.name] then
                    table.insert(errors, "variable already declared: " .. name.props.name)
                end
                current[name.props.name] = true
            end
            return node
        end,
        
        identifier = function(node)
            local found = false
            for i = #scopes, 1, -1 do
                if scopes[i][node.props.name] then
                    found = true
                    break
                end
            end
            if not found and not _G[node.props.name] then
                table.insert(errors, "variable not defined: " .. node.props.name)
            end
            return node
        end,
    })
    
    v:visit(ast)
    
    return #errors == 0, errors
end

function validator.is_valid_identifier(name)
    return type(name) == "string" and name:match("^[%a_][%w_]*$")
end

function validator.is_valid_number(n)
    return type(n) == "number" and n == n
end

function validator.is_constant(node)
    if node.type == "literal" then
        return true
    elseif node.type == "unary_op" then
        return validator.is_constant(node.props.expr)
    elseif node.type == "binary_op" then
        return validator.is_constant(node.props.left) and validator.is_constant(node.props.right)
    end
    return false
end

function validator.has_return(node)
    if node.type == "return_stmt" then
        return true
    elseif node.type == "block" then
        for _, stmt in ipairs(node.props.statements) do
            if validator.has_return(stmt) then
                return true
            end
        end
    elseif node.type == "if_statement" then
        if validator.has_return(node.props.then_block) then
            return true
        end
        for _, elseif_block in ipairs(node.props.elseif_blocks or {}) do
            if validator.has_return(elseif_block.body) then
                return true
            end
        end
        if node.props.else_block and validator.has_return(node.props.else_block) then
            return true
        end
    end
    return false
end

return validator
