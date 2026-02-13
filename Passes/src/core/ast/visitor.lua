local visitor = {}

function visitor.new(handlers)
    handlers = handlers or {}
    
    local self = {
        handlers = handlers,
        stack = {},
    }
    
    function self:visit(node, ...)
        if not node or type(node) ~= "table" or not node.type then
            return node
        end
        
        table.insert(self.stack, node)
        
        local handler = self.handlers[node.type] or self.handlers['*']
        local result
        
        if handler then
            result = handler(node, self, ...)
        else
            result = self:visit_children(node, ...)
        end
        
        table.remove(self.stack)
        
        return result
    end
    
    function self:visit_children(node, ...)
        if node.type == "program" or node.type == "block" then
            local statements = node.props.statements or node.props.body
            if statements then
                for i, stmt in ipairs(statements) do
                    statements[i] = self:visit(stmt, ...)
                end
            end
            
        elseif node.type == "if_statement" then
            node.props.condition = self:visit(node.props.condition, ...)
            node.props.then_block = self:visit(node.props.then_block, ...)
            for i, block in ipairs(node.props.elseif_blocks or {}) do
                node.props.elseif_blocks[i] = self:visit(block, ...)
            end
            if node.props.else_block then
                node.props.else_block = self:visit(node.props.else_block, ...)
            end
            
        elseif node.type == "while_loop" or node.type == "repeat_loop" then
            node.props.condition = self:visit(node.props.condition, ...)
            node.props.body = self:visit(node.props.body, ...)
            
        elseif node.type == "for_loop" then
            node.props.start = self:visit(node.props.start, ...)
            node.props.end = self:visit(node.props.end, ...)
            if node.props.step then
                node.props.step = self:visit(node.props.step, ...)
            end
            node.props.body = self:visit(node.props.body, ...)
            
        elseif node.type == "assignment" or node.type == "local_decl" then
            if node.props.rhs then
                for i, expr in ipairs(node.props.rhs) do
                    node.props.rhs[i] = self:visit(expr, ...)
                end
            end
            
        elseif node.type == "function_call" then
            node.props.func = self:visit(node.props.func, ...)
            for i, arg in ipairs(node.props.args) do
                node.props.args[i] = self:visit(arg, ...)
            end
            
        elseif node.type == "binary_op" then
            node.props.left = self:visit(node.props.left, ...)
            node.props.right = self:visit(node.props.right, ...)
            
        elseif node.type == "unary_op" then
            node.props.expr = self:visit(node.props.expr, ...)
            
        elseif node.type == "index_expr" or node.type == "member_expr" then
            node.props.table = self:visit(node.props.table, ...)
            node.props.index = self:visit(node.props.index, ...)
        end
        
        return node
    end
    
    function self:get_parent()
        return self.stack[#self.stack - 1]
    end
    
    function self:get_ancestor(n)
        return self.stack[#self.stack - n]
    end
    
    function self:get_depth()
        return #self.stack
    end
    
    return self
end

function visitor.visit_all(root, handlers)
    local v = visitor.new(handlers)
    return v:visit(root)
end

function visitor.replace(node, handlers)
    local v = visitor.new({
        ['*'] = function(n, visitor)
            local handler = handlers[n.type]
            if handler then
                return handler(n, visitor)
            end
            return n
        end
    })
    return v:visit(node)
end

return visitor
