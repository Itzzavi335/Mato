local tokens_cmd = {}
local lexer = require("core.lexer")
local fs = require("utils.fs")
local logger = require("utils.logger")

function tokens_cmd.run(params)
    if not params.input then
        return nil, "no input file specified"
    end
    
    logger.info("tokenizing:", params.input)
    
    local source = fs.read(params.input)
    if not source then
        return nil, "cannot read input file"
    end
    
    local tokens = lexer.scan(source)
    
    return dump_tokens(tokens)
end

function dump_tokens(tokens)
    local out = {}
    local line_width = 4
    
    table.insert(out, "=== Token Stream ===")
    table.insert(out, string.format("%s | %-15s | %s", 
        string.rep(" ", line_width - 1), "Type", "Value"))
    table.insert(out, string.rep("-", 50))
    
    for i, token in ipairs(tokens) do
        local line_num = token.line or 1
        local line_str = string.format("%" .. line_width .. "d", line_num)
        local type_str = token.type or "unknown"
        local value_str = token.value and tostring(token.value) or ""
        
        if token.type == "string" then
            value_str = '"' .. value_str .. '"'
        end
        
        table.insert(out, string.format("%s | %-15s | %s", 
            line_str, type_str, value_str))
    end
    
    return table.concat(out, "\n")
end

return tokens_cmd
