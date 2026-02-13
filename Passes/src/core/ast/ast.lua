local ast = {}

ast.node_types = {
    program = "program",
    block = "block",
    statement = "statement",
    expression = "expression",
    assignment = "assignment",
    local_decl = "local_decl",
    function_decl = "function_decl",
    function_call = "function_call",
    if_statement = "if_statement",
    while_loop = "while_loop",
    repeat_loop = "repeat_loop",
    for_loop = "for_loop",
    return_stmt = "return_stmt",
    break_stmt = "break_stmt",
    binary_op = "binary_op",
    unary_op = "unary_op",
    literal = "literal",
    identifier = "identifier",
    table_ctor = "table_ctor",
    index_expr = "index_expr",
    member_expr = "member_expr",
    comment = "comment",
}

function ast.create_node(type, props)
    props = props or {}
    return setmetatable({
        type = type,
        loc = props.loc or nil,
        props = props,
    }, {
        __tostring = function(node)
            return string.format("<ast.%s at %p>", node.type, node)
        end
    })
end

function ast.is_node(obj)
    return type(obj) == "table" and obj.type ~= nil
end

function ast.validate(node)
    if not ast.node_types[node.type] then
        return false, "invalid node type: " .. tostring(node.type)
    end
    return true
end

function ast.create_program(body)
    return ast.create_node(ast.node_types.program, {body = body or {}})
end

function ast.create_block(statements)
    return ast.create_node(ast.node_types.block, {statements = statements or {}})
end

function ast.create_identifier(name)
    return ast.create_node(ast.node_types.identifier, {name = name})
end

function ast.create_literal(value)
    return ast.create_node(ast.node_types.literal, {value = value})
end

function ast.create_binary_op(left, op, right)
    return ast.create_node(ast.node_types.binary_op, {
        left = left,
        op = op,
        right = right
    })
end

function ast.create_function_call(func, args)
    return ast.create_node(ast.node_types.function_call, {
        func = func,
        args = args or {}
    })
end

return ast
