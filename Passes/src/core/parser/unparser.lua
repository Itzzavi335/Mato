local unparser = {}
local tokenizer = require("tokenizer")

function unparser.to_tokens(ast)
    local tokens = {}
    
    local function add_token(type, value, line, col)
        table.insert(tokens, {
            type = type,
            value = value,
            line = line or 0,
            col = col or 0
        })
    end
    
    local function unparse_node(node)
        if node.type == "program" or node.type == "block" then
            for _, stmt in ipairs(node.props.statements or node.props.body or {}) do
                unparse_node(stmt)
            end
            
        elseif node.type == "assignment" then
            if type(node.props.lhs) == "table" and node.props.lhs[1] then
                for i, lhs in ipairs(node.props.lhs) do
                    if i > 1 then add_token("operator", ",") end
                    unparse_node(lhs)
                end
            else
                unparse_node(node.props.lhs)
            end
            add_token("operator", "=")
            for i, rhs in ipairs(node.props.rhs) do
                if i > 1 then add_token("operator", ",") end
                unparse_node(rhs)
            end
            
        elseif node.type == "local_decl" then
            add_token("keyword", "local")
            for i, name in ipairs(node.props.names) do
                if i > 1 then add_token("operator", ",") end
                unparse_node(name)
            end
            if #node.props.values > 0 then
                add_token("operator", "=")
                for i, val in ipairs(node.props.values) do
                    if i > 1 then add_token("operator", ",") end
                    unparse_node(val)
                end
            end
            
        elseif node.type == "function_decl" then
            add_token("keyword", "function")
            unparse_node(node.props.name)
            add_token("operator", "(")
            for i, param in ipairs(node.props.params) do
                if i > 1 then add_token("operator", ",") end
                unparse_node(param)
            end
            add_token("operator", ")")
            unparse_node(node.props.body)
            add_token("keyword", "end")
            
        elseif node.type == "function_call" then
            unparse_node(node.props.func)
            add_token("operator", "(")
            for i, arg in ipairs(node.props.args) do
                if i > 1 then add_token("operator", ",") end
                unparse_node(arg)
            end
            add_token("operator", ")")
            
        elseif node.type == "if_statement" then
            add_token("keyword", "if")
            unparse_node(node.props.condition)
            add_token("keyword", "then")
            unparse_node(node.props.then_block)
            for _, elseif_block in ipairs(node.props.elseif_blocks or {}) do
                add_token("keyword", "elseif")
                unparse_node(elseif_block.condition)
                add_token("keyword", "then")
                unparse_node(elseif_block.body)
            end
            if node.props.else_block then
                add_token("keyword", "else")
                unparse_node(node.props.else_block)
            end
            add_token("keyword", "end")
            
        elseif node.type == "while_loop" then
            add_token("keyword", "while")
            unparse_node(node.props.condition)
            add_token("keyword", "do")
            unparse_node(node.props.body)
            add_token("keyword", "end")
            
        elseif node.type == "for_loop" then
            add_token("keyword", "for")
            unparse_node(node.props.var)
            add_token("operator", "=")
            unparse_node(node.props.start)
            add_token("operator", ",")
            unparse_node(node.props.end)
            if node.props.step then
                add_token("operator", ",")
                unparse_node(node.props.step)
            end
            add_token("keyword", "do")
            unparse_node(node.props.body)
            add_token("keyword", "end")
            
        elseif node.type == "return_stmt" then
            add_token("keyword", "return")
            for i, val in ipairs(node.props.values) do
                if i > 1 then add_token("operator", ",") end
                unparse_node(val)
            end
            
        elseif node.type == "binary_op" then
            unparse_node(node.props.left)
            add_token("operator", node.props.op)
            unparse_node(node.props.right)
            
        elseif node.type == "unary_op" then
            add_token("operator", node.props.op)
            unparse_node(node.props.expr)
            
        elseif node.type == "literal" then
            if node.props.value == nil then
                add_token("keyword", "nil")
            elseif type(node.props.value) == "string" then
                add_token("string", '"' .. node.props.value .. '"')
            elseif type(node.props.value) == "number" then
                add_token("number", node.props.value)
            elseif type(node.props.value) == "boolean" then
                add_token("keyword", tostring(node.props.value))
            end
            
        elseif node.type == "identifier" then
            add_token("identifier", node.props.name)
            
        elseif node.type == "table_ctor" then
            add_token("operator", "{")
            for i, field in ipairs(node.props.fields) do
                if i > 1 then add_token("operator", ",") end
                if field.key then
                    add_token("operator", "[")
                    unparse_node(field.key)
                    add_token("operator", "]")
                    add_token("operator", "=")
                    unparse_node(field.value)
                elseif field.name then
                    add_token("identifier", field.name)
                    add_token("operator", "=")
                    unparse_node(field.value)
                else
                    unparse_node(field.value)
                end
            end
            add_token("operator", "}")
            
        elseif node.type == "index_expr" then
            unparse_node(node.props.table)
            add_token("operator", "[")
            unparse_node(node.props.index)
            add_token("operator", "]")
            
        elseif node.type == "member_expr" then
            unparse_node(node.props.table)
            add_token("operator", ".")
            unparse_node(node.props.index)
        end
    end
    
    unparse_node(ast)
    add_token("eof", nil)
    
    return tokens
end

function unparser.to_source(ast)
    local tokens = unparser.to_tokens(ast)
    local source_parts = {}
    
    for i, token in ipairs(tokens) do
        if token.type ~= "eof" then
            if token.type == "string" then
                table.insert(source_parts, token.value)
            elseif token.type == "number" then
                table.insert(source_parts, tostring(token.value))
            elseif token.type == "identifier" then
                table.insert(source_parts, token.value)
            elseif token.type == "keyword" then
                table.insert(source_parts, token.value)
            elseif token.type == "operator" then
                table.insert(source_parts, token.value)
            end
            
            if i < #tokens and tokens[i+1].type ~= "operator" and tokens[i+1].type ~= "eof" then
                if token.type ~= "operator" and token.value ~= "(" and token.value ~= "[" then
                    table.insert(source_parts, " ")
                end
            end
        end
    end
    
    return table.concat(source_parts)
end

return unparser
