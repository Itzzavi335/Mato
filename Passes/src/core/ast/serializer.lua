local serializer = {}
local visitor = require("visitor")

local function escape_string(s)
    s = s:gsub("\\", "\\\\")
    s = s:gsub('"', '\\"')
    s = s:gsub("\n", "\\n")
    s = s:gsub("\r", "\\r")
    s = s:gsub("\t", "\\t")
    return '"' .. s .. '"'
end

function serializer.to_lua(ast, indent)
    indent = indent or 0
    local output = {}
    local indent_str = string.rep("    ", indent)
    
    local v = visitor.new({
        program = function(node)
            for _, stmt in ipairs(node.props.body or node.props.statements or {}) do
                table.insert(output, v:visit(stmt))
            end
            return table.concat(output, "\n")
        end,
        
        block = function(node)
            local block_out = {}
            for _, stmt in ipairs(node.props.statements) do
                table.insert(block_out, indent_str .. v:visit(stmt))
            end
            return table.concat(block_out, "\n")
        end,
        
        assignment = function(node)
            local lhs = node.props.lhs
            local rhs = node.props.rhs
            
            if type(lhs) == "table" and lhs[1] then
                local lhs_str = {}
                for _, id in ipairs(lhs) do
                    table.insert(lhs_str, v:visit(id))
                end
                return table.concat(lhs_str, ", ") .. " = " .. v:visit(rhs[1])
            else
                return v:visit(lhs) .. " = " .. v:visit(rhs[1])
            end
        end,
        
        local_decl = function(node)
            local names = {}
            for _, name in ipairs(node.props.names) do
                table.insert(names, v:visit(name))
            end
            
            if #node.props.values > 0 then
                local values = {}
                for _, val in ipairs(node.props.values) do
                    table.insert(values, v:visit(val))
                end
                return "local " .. table.concat(names, ", ") .. " = " .. table.concat(values, ", ")
            else
                return "local " .. table.concat(names, ", ")
            end
        end,
        
        function_decl = function(node)
            local params = {}
            for _, param in ipairs(node.props.params) do
                table.insert(params, v:visit(param))
            end
            
            local body_str = v:visit(node.props.body)
            return string.format("function %s(%s)\n%s\n%s end", 
                v:visit(node.props.name), 
                table.concat(params, ", "), 
                body_str,
                indent_str)
        end,
        
        function_call = function(node)
            local args = {}
            for _, arg in ipairs(node.props.args) do
                table.insert(args, v:visit(arg))
            end
            return v:visit(node.props.func) .. "(" .. table.concat(args, ", ") .. ")"
        end,
        
        if_statement = function(node)
            local out = {"if " .. v:visit(node.props.condition) .. " then"}
            table.insert(out, v:visit(node.props.then_block))
            
            for _, elseif_block in ipairs(node.props.elseif_blocks or {}) do
                table.insert(out, "elseif " .. v:visit(elseif_block.condition) .. " then")
                table.insert(out, v:visit(elseif_block.body))
            end
            
            if node.props.else_block then
                table.insert(out, "else")
                table.insert(out, v:visit(node.props.else_block))
            end
            
            table.insert(out, "end")
            return table.concat(out, "\n" .. indent_str)
        end,
        
        while_loop = function(node)
            return "while " .. v:visit(node.props.condition) .. " do\n" .. 
                   v:visit(node.props.body) .. "\n" .. indent_str .. "end"
        end,
        
        for_loop = function(node)
            local step = node.props.step and ", " .. v:visit(node.props.step) or ""
            return string.format("for %s = %s, %s%s do\n%s\n%s end",
                v:visit(node.props.var),
                v:visit(node.props.start),
                v:visit(node.props.end),
                step,
                v:visit(node.props.body),
                indent_str)
        end,
        
        return_stmt = function(node)
            if #node.props.values > 0 then
                local values = {}
                for _, val in ipairs(node.props.values) do
                    table.insert(values, v:visit(val))
                end
                return "return " .. table.concat(values, ", ")
            else
                return "return"
            end
        end,
        
        binary_op = function(node)
            return string.format("(%s %s %s)", 
                v:visit(node.props.left), 
                node.props.op, 
                v:visit(node.props.right))
        end,
        
        unary_op = function(node)
            return node.props.op .. " " .. v:visit(node.props.expr)
        end,
        
        literal = function(node)
            if node.props.value == nil then
                return "nil"
            elseif type(node.props.value) == "string" then
                return escape_string(node.props.value)
            else
                return tostring(node.props.value)
            end
        end,
        
        identifier = function(node)
            return node.props.name
        end,
        
        table_ctor = function(node)
            if #node.props.fields == 0 then
                return "{}"
            end
            
            local fields = {}
            for _, field in ipairs(node.props.fields) do
                if field.key then
                    table.insert(fields, "[" .. v:visit(field.key) .. "] = " .. v:visit(field.value))
                elseif field.name then
                    table.insert(fields, field.name .. " = " .. v:visit(field.value))
                else
                    table.insert(fields, v:visit(field.value))
                end
            end
            
            return "{" .. table.concat(fields, ", ") .. "}"
        end,
        
        index_expr = function(node)
            return v:visit(node.props.table) .. "[" .. v:visit(node.props.index) .. "]"
        end,
        
        member_expr = function(node)
            return v:visit(node.props.table) .. "." .. v:visit(node.props.index)
        end,
    })
    
    return v:visit(ast)
end

function serializer.to_string(ast)
    return serializer.to_lua(ast, 0)
end

function serializer.pretty(ast)
    return serializer.to_lua(ast, 0)
end

function serializer.minify(ast)
    local code = serializer.to_lua(ast, 0)
    code = code:gsub("%s+", " ")
    code = code:gsub("%s*([%(%)%{%}%=%;%,])%s*", "%1")
    return code
end

return serializer
