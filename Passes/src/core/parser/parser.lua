local parser = {}
local tokenizer = require("tokenizer")
local builder = require("builder")
local grammar = require("grammar")
local precedence = require("precedence")

function parser.parse(tokens)
    local tokens = tokenizer.new(tokens)
    local ast = nil
    
    local function error(msg)
        local line, col = tokens:get_line_col()
        error(string.format("parse error at %d:%d: %s", line, col, msg))
    end
    
    local function parse_chunk()
        local statements = {}
        while not tokens:eof() and not tokens:match("keyword", "end") 
              and not tokens:match("keyword", "else") 
              and not tokens:match("keyword", "elseif")
              and not tokens:match("keyword", "until") do
            local stmt = parse_statement()
            if stmt then
                table.insert(statements, stmt)
            end
        end
        return builder.block(statements)
    end
    
    local function parse_statement()
        if tokens:match("keyword", "if") then
            return parse_if()
        elseif tokens:match("keyword", "while") then
            return parse_while()
        elseif tokens:match("keyword", "repeat") then
            return parse_repeat()
        elseif tokens:match("keyword", "for") then
            return parse_for()
        elseif tokens:match("keyword", "function") then
            return parse_function_decl()
        elseif tokens:match("keyword", "local") then
            return parse_local()
        elseif tokens:match("keyword", "return") then
            return parse_return()
        elseif tokens:match("keyword", "break") then
            tokens:next()
            return builder.break_stmt()
        elseif tokens:match("operator", "::") then
            return parse_label()
        else
            return parse_assignment_or_call()
        end
    end
    
    local function parse_if()
        local cond = parse_expr()
        tokens:expect("keyword", "then")
        local then_block = parse_chunk()
        local elseif_blocks = {}
        
        while tokens:match("keyword", "elseif") do
            local elseif_cond = parse_expr()
            tokens:expect("keyword", "then")
            local elseif_body = parse_chunk()
            table.insert(elseif_blocks, {condition = elseif_cond, body = elseif_body})
        end
        
        local else_block = nil
        if tokens:match("keyword", "else") then
            else_block = parse_chunk()
        end
        
        tokens:expect("keyword", "end")
        return builder.if_statement(cond, then_block, elseif_blocks, else_block)
    end
    
    local function parse_while()
        local cond = parse_expr()
        tokens:expect("keyword", "do")
        local body = parse_chunk()
        tokens:expect("keyword", "end")
        return builder.while_loop(cond, body)
    end
    
    local function parse_repeat()
        local body = parse_chunk()
        tokens:expect("keyword", "until")
        local cond = parse_expr()
        return builder.repeat_loop(cond, body)
    end
    
    local function parse_for()
        local name = tokens:expect("identifier")
        local var = builder.identifier(name.value)
        
        if tokens:match("operator", "=") then
            local start = parse_expr()
            tokens:expect("operator", ",")
            local end_expr = parse_expr()
            local step = nil
            
            if tokens:match("operator", ",") then
                step = parse_expr()
            end
            
            tokens:expect("keyword", "do")
            local body = parse_chunk()
            tokens:expect("keyword", "end")
            
            return builder.for_loop(var, start, end_expr, step, body)
        else
            local names = {var}
            while tokens:match("operator", ",") do
                local next_name = tokens:expect("identifier")
                table.insert(names, builder.identifier(next_name.value))
            end
            
            tokens:expect("keyword", "in")
            local explist = parse_expr_list()
            tokens:expect("keyword", "do")
            local body = parse_chunk()
            tokens:expect("keyword", "end")
            
            return builder.generic_for(names, explist, body)
        end
    end
    
    local function parse_function_decl()
        local name = parse_function_name()
        tokens:expect("operator", "(")
        local params = parse_parameter_list()
        tokens:expect("operator", ")")
        local body = parse_chunk()
        tokens:expect("keyword", "end")
        return builder.function_decl(name, params, body)
    end
    
    local function parse_local()
        if tokens:match("keyword", "function") then
            local name = tokens:expect("identifier")
            tokens:expect("operator", "(")
            local params = parse_parameter_list()
            tokens:expect("operator", ")")
            local body = parse_chunk()
            tokens:expect("keyword", "end")
            return builder.local_function(name.value, params, body)
        else
            local names = {builder.identifier(tokens:expect("identifier").value)}
            while tokens:match("operator", ",") do
                table.insert(names, builder.identifier(tokens:expect("identifier").value))
            end
            
            local values = {}
            if tokens:match("operator", "=") then
                values = parse_expr_list()
            end
            
            return builder.local_decl(names, values)
        end
    end
    
    local function parse_return()
        if tokens:match("keyword", "end") or tokens:match("keyword", "else") 
           or tokens:match("keyword", "elseif") or tokens:match("keyword", "until") then
            tokens:prev()
            return builder.return_stmt({})
        end
        
        local values = parse_expr_list()
        return builder.return_stmt(values)
    end
    
    local function parse_label()
        local name = tokens:expect("identifier")
        tokens:expect("operator", "::")
        return builder.label(name.value)
    end
    
    local function parse_assignment_or_call()
        local prefix = parse_prefix_expr()
        
        if tokens:match("operator", "=") or tokens:match("operator", ",") then
            local vars = {prefix}
            while tokens:match("operator", ",") do
                table.insert(vars, parse_prefix_expr())
            end
            tokens:expect("operator", "=")
            local values = parse_expr_list()
            return builder.assignment(vars, values)
        elseif prefix.type == "function_call" then
            return prefix
        else
            error("invalid statement")
        end
    end
    
    local function parse_function_name()
        local name = builder.identifier(tokens:expect("identifier").value)
        
        while tokens:match("operator", ".") do
            local field = tokens:expect("identifier")
            name = builder.member_expr(name, builder.identifier(field.value))
        end
        
        if tokens:match("operator", ":") then
            local method = tokens:expect("identifier")
            name = builder.index_expr(name, builder.string(method.value))
        end
        
        return name
    end
    
    local function parse_parameter_list()
        local params = {}
        
        if tokens:match("operator", ")") then
            tokens:prev()
            return params
        end
        
        if tokens:match("operator", "...") then
            table.insert(params, builder.identifier("..."))
        else
            table.insert(params, builder.identifier(tokens:expect("identifier").value))
            while tokens:match("operator", ",") do
                if tokens:match("operator", "...") then
                    table.insert(params, builder.identifier("..."))
                    break
                else
                    table.insert(params, builder.identifier(tokens:expect("identifier").value))
                end
            end
        end
        
        tokens:expect("operator", ")")
        return params
    end
    
    local function parse_expr_list()
        local exprs = {parse_expr()}
        
        while tokens:match("operator", ",") do
            table.insert(exprs, parse_expr())
        end
        
        return exprs
    end
    
    local function parse_expr()
        return parse_sub_expr(0)
    end
    
    local function parse_sub_expr(min_prec)
        local lhs = parse_unary()
        
        while true do
            local op = tokens:peek()
            if op.type ~= "operator" and op.type ~= "keyword" then
                break
            end
            
            local prec = precedence.get(op.value)
            if not prec or prec.left < min_prec then
                break
            end
            
            tokens:next()
            
            if op.value == "." then
                local field = tokens:expect("identifier")
                lhs = builder.member_expr(lhs, builder.identifier(field.value))
            elseif op.value == "[" then
                local index = parse_expr()
                tokens:expect("operator", "]")
                lhs = builder.index_expr(lhs, index)
            elseif op.value == ":" then
                local method = tokens:expect("identifier")
                tokens:expect("operator", "(")
                local args = parse_function_args()
                lhs = builder.method_call(lhs, builder.string(method.value), args)
            elseif op.value == "(" or op.type == "string" or op.type == "table" then
                tokens:prev()
                local args = parse_function_args()
                lhs = builder.function_call(lhs, args)
            else
                local rhs = parse_sub_expr(prec.right)
                lhs = builder.binary(lhs, op.value, rhs)
            end
        end
        
        return lhs
    end
    
    local function parse_unary()
        local token = tokens:peek()
        
        if token.value == "-" or token.value == "not" or token.value == "#" then
            tokens:next()
            local expr = parse_unary()
            return builder.unary(token.value, expr)
        end
        
        return parse_prefix_expr()
    end
    
    local function parse_prefix_expr()
        local token = tokens:peek()
        
        if token.type == "identifier" then
            tokens:next()
            return builder.identifier(token.value)
        elseif token.type == "number" then
            tokens:next()
            return builder.number(token.value)
        elseif token.type == "string" then
            tokens:next()
            return builder.string(token.value)
        elseif token.keyword == "true" or token.keyword == "false" then
            tokens:next()
            return builder.boolean(token.keyword == "true")
        elseif token.keyword == "nil" then
            tokens:next()
            return builder.nil()
        elseif token.value == "..." then
            tokens:next()
            return builder.vararg()
        elseif token.value == "function" then
            return parse_function_expr()
        elseif token.value == "{" then
            return parse_table_ctor()
        elseif token.value == "(" then
            tokens:next()
            local expr = parse_expr()
            tokens:expect("operator", ")")
            return expr
        else
            error("unexpected token: " .. token.value)
        end
    end
    
    local function parse_function_expr()
        tokens:expect("keyword", "function")
        tokens:expect("operator", "(")
        local params = parse_parameter_list()
        tokens:expect("operator", ")")
        local body = parse_chunk()
        tokens:expect("keyword", "end")
        return builder.function_expr(params, body)
    end
    
    local function parse_table_ctor()
        tokens:expect("operator", "{")
        local fields = {}
        
        while not tokens:match("operator", "}") do
            local field = parse_field()
            table.insert(fields, field)
            
            if not tokens:match("operator", ",") and not tokens:match("operator", ";") then
                break
            end
        end
        
        tokens:expect("operator", "}")
        return builder.table_ctor(fields)
    end
    
    local function parse_field()
        local token = tokens:peek()
        
        if token.type == "identifier" and tokens:peek(1).value == "=" then
            local name = tokens:expect("identifier")
            tokens:expect("operator", "=")
            local value = parse_expr()
            return {name = name.value, value = value}
        elseif token.value == "[" then
            tokens:next()
            local key = parse_expr()
            tokens:expect("operator", "]")
            tokens:expect("operator", "=")
            local value = parse_expr()
            return {key = key, value = value}
        else
            return {value = parse_expr()}
        end
    end
    
    local function parse_function_args()
        local token = tokens:peek()
        
        if token.type == "string" then
            tokens:next()
            return {builder.string(token.value)}
        elseif token.type == "table" then
            return {parse_table_ctor()}
        elseif token.value == "(" then
            tokens:next()
            if tokens:match("operator", ")") then
                return {}
            end
            local args = parse_expr_list()
            tokens:expect("operator", ")")
            return args
        end
    end
    
    ast = parse_chunk()
    tokens:expect("eof")
    
    return ast
end

return parser
