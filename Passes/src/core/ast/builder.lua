local builder = {}
local ast = require("ast")

function builder.program(statements)
    return ast.create_program(statements)
end

function builder.block(statements)
    return ast.create_block(statements)
end

function builder.assignment(lhs, rhs)
    return ast.create_node(ast.node_types.assignment, {
        lhs = lhs,
        rhs = rhs
    })
end

function builder.local_decl(names, values)
    return ast.create_node(ast.node_types.local_decl, {
        names = names,
        values = values or {}
    })
end

function builder.function_decl(name, params, body)
    return ast.create_node(ast.node_types.function_decl, {
        name = name,
        params = params or {},
        body = body or builder.block({})
    })
end

function builder.function_call(func, args)
    return ast.create_function_call(func, args)
end

function builder.if_statement(condition, then_block, elseif_blocks, else_block)
    return ast.create_node(ast.node_types.if_statement, {
        condition = condition,
        then_block = then_block,
        elseif_blocks = elseif_blocks or {},
        else_block = else_block
    })
end

function builder.while_loop(condition, body)
    return ast.create_node(ast.node_types.while_loop, {
        condition = condition,
        body = body
    })
end

function builder.for_loop(var, start, end_expr, step, body)
    return ast.create_node(ast.node_types.for_loop, {
        var = var,
        start = start,
        end = end_expr,
        step = step,
        body = body
    })
end

function builder.return_stmt(values)
    return ast.create_node(ast.node_types.return_stmt, {
        values = values or {}
    })
end

function builder.literal(value)
    return ast.create_literal(value)
end

function builder.identifier(name)
    return ast.create_identifier(name)
end

function builder.binary(left, op, right)
    return ast.create_binary_op(left, op, right)
end

function builder.unary(op, expr)
    return ast.create_node(ast.node_types.unary_op, {
        op = op,
        expr = expr
    })
end

function builder.table_ctor(fields)
    return ast.create_node(ast.node_types.table_ctor, {
        fields = fields or {}
    })
end

function builder.index_expr(table_expr, index)
    return ast.create_node(ast.node_types.index_expr, {
        table = table_expr,
        index = index
    })
end

function builder.string(s)
    return builder.literal(s)
end

function builder.number(n)
    return builder.literal(n)
end

function builder.boolean(b)
    return builder.literal(b)
end

function builder.nil()
    return builder.literal(nil)
end

return builder
