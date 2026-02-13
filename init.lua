local compiler = require("core.compiler")

local M = {}

function M.obfuscate(source, options)
    return compiler.compile(source, options)
end

function M.obfuscate_file(input, output, options)
    local source, err = M.read_file(input)
    if not source then return nil, err end
    
    local result, err = M.obfuscate(source, options)
    if not result then return nil, err end
    
    if output then
        return M.write_file(output, result)
    end
    
    return result
end

function M.read_file(path)
    local f, err = io.open(path, "r")
    if not f then return nil, err end
    local content = f:read("*all")
    f:close()
    return content
end

function M.write_file(path, content)
    local f, err = io.open(path, "w")
    if not f then return nil, err end
    f:write(content)
    f:close()
    return true
end

function M.version()
    return "1.0.0"
end

return M
