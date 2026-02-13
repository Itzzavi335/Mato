local errors = {}

local error_types = {
    syntax = {code = 1, msg = "syntax error"},
    parse = {code = 2, msg = "parse error"},
    compile = {code = 3, msg = "compilation error"},
    runtime = {code = 4, msg = "runtime error"},
    memory = {code = 5, msg = "memory error"},
    io = {code = 6, msg = "io error"},
    config = {code = 7, msg = "configuration error"},
    pass = {code = 8, msg = "pass error"},
}

function errors.new(err_type, message, info)
    err_type = error_types[err_type] or error_types.compile
    
    local err = {
        type = err_type,
        message = message,
        info = info or {},
        time = os.time(),
    }
    
    setmetatable(err, {
        __tostring = function(e)
            local parts = {
                string.format("[%s] %s", e.type.msg, e.message)
            }
            if e.info.line then
                table.insert(parts, string.format(" at line %d", e.info.line))
            end
            if e.info.file then
                table.insert(parts, string.format(" in %s", e.info.file))
            end
            return table.concat(parts)
        end
    })
    
    return err
end

function errors.wrap(err, traceback)
    local wrapped = {
        original = err,
        traceback = traceback,
        message = tostring(err),
    }
    
    wrapped.__tostring = function()
        return string.format("%s\n%s", wrapped.message, wrapped.traceback)
    end
    
    return setmetatable({}, {
        __tostring = function() return wrapped:__tostring() end
    })
end

function errors.handle(err, ctx)
    local err_str = tostring(err)
    
    if ctx and ctx.filename then
        err_str = string.format("%s: %s", ctx.filename, err_str)
    end
    
    if ctx and ctx.stats then
        ctx.stats.error = err_str
    end
    
    io.stderr:write(err_str .. "\n")
    
    return false, err_str
end

function errors.is_type(err, err_type)
    return type(err) == "table" and err.type == error_types[err_type]
end

return errors
