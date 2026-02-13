local parse_cmd = {}
local lexer = require("core.lexer")
local parser = require("core.parser")
local fs = require("utils.fs")
local logger = require("utils.logger")

function parse_cmd.run(params)
    if not params.input then
        return nil, "no input file specified"
    end
    
    logger.info("parsing:", params.input)
    
    local source = fs.read(params.input)
    if not source then
        return nil, "cannot read input file"
    end
    
    local tokens = lexer.scan(source)
    local ast = parser.parse(tokens)
    
    local result = {
        file = params.input,
        size = #source,
        lines = select(2, source:gsub("\n", "\n")) + 1,
        tokens = #tokens - 1,
        nodes = count_nodes(ast),
    }
    
    return format_output(result, params.verbose)
end

function count_nodes(node)
    if type(node) ~= "table" or not node.type then
        return 0
    end
    
    local count = 1
    for _, v in pairs(node.props or {}) do
        if type(v) == "table" then
            if v.type then
                count = count + count_nodes(v)
            elseif v[1] and type(v[1]) == "table" then
                for _, item in ipairs(v) do
                    count = count + count_nodes(item)
                end
            end
        end
    end
    
    return count
end

function format_output(data, verbose)
    local out = {}
    table.insert(out, "=== Parse Results ===")
    table.insert(out, string.format("File: %s", data.file))
    table.insert(out, string.format("Size: %d bytes", data.size))
    table.insert(out, string.format("Lines: %d", data.lines))
    table.insert(out, string.format("Tokens: %d", data.tokens))
    table.insert(out, string.format("AST Nodes: %d", data.nodes))
    
    return table.concat(out, "\n")
end

return parse_cmd
