local compiler = {}
local context = require("context")
local pipeline = require("pipeline")
local errors = require("errors")

local function merge_config(base, custom)
    local result = {}
    for k, v in pairs(base) do
        result[k] = v
    end
    for k, v in pairs(custom) do
        result[k] = v
    end
    return result
end

function compiler.compile(source, options)
    options = options or {}
    
    local ctx = context.new(source, options)
    
    local ok, err = xpcall(function()
        pipeline.execute(ctx)
    end, function(err)
        return errors.wrap(err, debug.traceback())
    end)
    
    if not ok then
        return nil, err
    end
    
    return ctx.output, ctx.stats
end

function compiler.compile_file(path, options)
    local file, err = io.open(path, "r")
    if not file then
        return nil, "cannot open file: " .. err
    end
    
    local source = file:read("*all")
    file:close()
    
    options = options or {}
    options.filename = path
    
    return compiler.compile(source, options)
end

function compiler.set_profile(name)
    local config = require("config")
    return config.get_profile(name)
end

function compiler.version()
    return "1.0.0"
end

return compiler
