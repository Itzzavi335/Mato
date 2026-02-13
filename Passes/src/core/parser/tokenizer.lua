local tokenizer = {}

function tokenizer.new(tokens)
    local self = {
        tokens = tokens,
        pos = 1,
        len = #tokens
    }
    
    function self:peek(offset)
        offset = offset or 0
        local idx = self.pos + offset
        if idx <= self.len then
            return self.tokens[idx]
        end
        return self.tokens[self.len]
    end
    
    function self:next()
        local token = self.tokens[self.pos]
        self.pos = self.pos + 1
        return token
    end
    
    function self:prev()
        self.pos = math.max(1, self.pos - 1)
        return self.tokens[self.pos]
    end
    
    function self:expect(types, values)
        if type(types) ~= "table" then
            types = {types}
        end
        
        local token = self:peek()
        local ok = false
        
        for _, t in ipairs(types) do
            if token.type == t then
                ok = true
                break
            end
        end
        
        if values then
            if type(values) ~= "table" then
                values = {values}
            end
            local val_ok = false
            for _, v in ipairs(values) do
                if token.value == v then
                    val_ok = true
                    break
                end
            end
            ok = ok and val_ok
        end
        
        if not ok then
            local expected = table.concat(types, " or ")
            error(string.format("expected %s at %d:%d, got %s", 
                expected, token.line, token.col, token.type))
        end
        
        return self:next()
    end
    
    function self:match(types, values)
        local token = self:peek()
        
        if type(types) ~= "table" then
            types = {types}
        end
        
        for _, t in ipairs(types) do
            if token.type == t then
                if values then
                    if type(values) ~= "table" then
                        values = {values}
                    end
                    for _, v in ipairs(values) do
                        if token.value == v then
                            self:next()
                            return true
                        end
                    end
                else
                    self:next()
                    return true
                end
            end
        end
        
        return false
    end
    
    function self:eof()
        return self:peek().type == "eof"
    end
    
    function self:save()
        return self.pos
    end
    
    function self:restore(pos)
        self.pos = pos
    end
    
    function self:get_line_col()
        local token = self:peek()
        return token.line, token.col
    end
    
    return self
end

function tokenizer.from_source(source)
    local lexer = require("lexer")
    local tokens = lexer.scan(source)
    return tokenizer.new(tokens)
end

return tokenizer
