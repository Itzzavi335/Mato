local lexer = {}

local keywords = {
    ["and"] = "and", ["break"] = "break", ["do"] = "do", ["else"] = "else",
    ["elseif"] = "elseif", ["end"] = "end", ["false"] = "false", ["for"] = "for",
    ["function"] = "function", ["if"] = "if", ["in"] = "in", ["local"] = "local",
    ["nil"] = "nil", ["not"] = "not", ["or"] = "or", ["repeat"] = "repeat",
    ["return"] = "return", ["then"] = "then", ["true"] = "true", ["until"] = "until",
    ["while"] = "while"
}

function lexer.scan(source)
    local tokens = {}
    local pos = 1
    local line = 1
    local col = 1
    local len = #source
    
    local function error(msg)
        return nil, string.format("lex error at %d:%d: %s", line, col, msg)
    end
    
    while pos <= len do
        local ch = source:sub(pos, pos)
        
        if ch == '\n' then
            line = line + 1
            col = 1
            pos = pos + 1
        elseif ch:match("%s") then
            col = col + 1
            pos = pos + 1
        elseif ch == '-' and source:sub(pos+1, pos+1) == '-' then
            local start = pos
            pos = pos + 2
            if source:sub(pos, pos) == '[' then
                local level = 0
                while source:sub(pos + level, pos + level) == '=' do
                    level = level + 1
                end
                if source:sub(pos + level, pos + level) == '[' then
                    local close = ']' .. string.rep('=', level) .. ']'
                    pos = source:find(close, pos + level + 1, true)
                    if pos then
                        pos = pos + #close
                    end
                end
            else
                pos = source:find('\n', pos) or (len + 1)
            end
            col = col + (pos - start)
        elseif ch == '"' or ch == "'" then
            local quote = ch
            local start = pos
            pos = pos + 1
            while pos <= len do
                if source:sub(pos, pos) == '\\' then
                    pos = pos + 2
                elseif source:sub(pos, pos) == quote then
                    pos = pos + 1
                    break
                else
                    pos = pos + 1
                end
            end
            local str = source:sub(start, pos - 1)
            table.insert(tokens, {type = "string", value = str, line = line, col = col})
            col = col + (pos - start)
        elseif ch:match("%d") then
            local start = pos
            while pos <= len and source:sub(pos, pos):match("[%d%.]") do
                pos = pos + 1
            end
            local num = source:sub(start, pos - 1)
            table.insert(tokens, {type = "number", value = tonumber(num), line = line, col = col})
            col = col + (pos - start)
        elseif ch:match("[a-zA-Z_]") then
            local start = pos
            while pos <= len and source:sub(pos, pos):match("[%w_]") do
                pos = pos + 1
            end
            local ident = source:sub(start, pos - 1)
            local type = keywords[ident] and "keyword" or "identifier"
            table.insert(tokens, {type = type, value = ident, line = line, col = col})
            col = col + (pos - start)
        else
            local start = pos
            local op = ch
            pos = pos + 1
            
            if op == '=' and source:sub(pos, pos) == '=' then
                op = '=='
                pos = pos + 1
            elseif op == '~' and source:sub(pos, pos) == '=' then
                op = '~='
                pos = pos + 1
            elseif op == '<' and source:sub(pos, pos) == '=' then
                op = '<='
                pos = pos + 1
            elseif op == '>' and source:sub(pos, pos) == '=' then
                op = '>='
                pos = pos + 1
            elseif op == '.' and source:sub(pos, pos) == '.' then
                op = '..'
                pos = pos + 1
            elseif op == ':' and source:sub(pos, pos) == ':' then
                op = '::'
                pos = pos + 1
            end
            
            table.insert(tokens, {type = "operator", value = op, line = line, col = col})
            col = col + (pos - start)
        end
    end
    
    table.insert(tokens, {type = "eof", value = nil, line = line, col = col})
    return tokens
end

return lexer
