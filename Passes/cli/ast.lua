local ast_cmd = {}
local lexer = require("core.lexer")
local parser = require("core.parser")
local fs = require("utils.fs")
local logger = require("utils.logger")

function ast_cmd.run(params)
    if not params.input then
        return nil, "no input file specified"
    end
    
    logger.info("generating AST for:", params.input)
    
    local source = fs.read(params.input)
    if not source then
        return nil, "cannot read input file"
    end
    
    local tokens = lexer.scan(source)
    local ast = parser.parse(tokens)
    
    return dump_ast(ast, 0)
end

function dump_ast(node, depth)
    if type(node) ~= "table" or not node.type then
        return tostring(node)
    end
    
    local indent = string.rep("  ", depth)
    local out = {}
    
    table.insert(out, indent .. node.type)
    
    for k, v in pairs(node.props or {}) do
        if type(v) == "table" then
            if v.type then
                table.insert(out, indent .. "  " .. k .. ":")
                table.insert(out, dump_ast(v, depth + 2))
            elseif v[1] and type(v[1]) == "table" and v[1].type then
                table.insert(out, indent .. "  " .. k .. ":")
                for i, item in ipairs(v) do
                    table.insert(out, indent .. "    [" .. i .. "]")
                    table.insert(out, dump_ast(item, depth + 3))
                end
            else
                table.insert(out, indent .. "  " .. k .. ": " .. table_to_string(v))
            end
        else
            table.insert(out, indent .. "  " .. k .. ": " .. tostring(v))
        end
    end
    
    return table.concat(out, "\n")
end

function table_to_string(t)
    if #t == 0 then
        return "{}"
    end
    
    local parts = {}
    for i, v in ipairs(t) do
        parts[i] = tostring(v)
    end
    
    return "{" .. table.concat(parts, ", ") .. "}"
end

return ast_cmd
