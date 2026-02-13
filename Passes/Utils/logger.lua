local logger = {
    level = "info",
    levels = {
        debug = 1,
        info = 2,
        warn = 3,
        error = 4,
        none = 5
    }
}

local function get_time()
    return os.date("%Y-%m-%d %H:%M:%S")
end

local function should_log(level)
    return logger.levels[level] >= logger.levels[logger.level]
end

function logger.set_level(level)
    if logger.levels[level] then
        logger.level = level
    end
end

function logger.debug(...)
    if not should_log("debug") then return end
    
    local args = {...}
    local msg = table.concat(args, " ")
    io.stdout:write(string.format("[%s] [DEBUG] %s\n", get_time(), msg))
end

function logger.info(...)
    if not should_log("info") then return end
    
    local args = {...}
    local msg = table.concat(args, " ")
    io.stdout:write(string.format("[%s] [INFO] %s\n", get_time(), msg))
end

function logger.warn(...)
    if not should_log("warn") then return end
    
    local args = {...}
    local msg = table.concat(args, " ")
    io.stderr:write(string.format("[%s] [WARN] %s\n", get_time(), msg))
end

function logger.error(...)
    if not should_log("error") then return end
    
    local args = {...}
    local msg = table.concat(args, " ")
    io.stderr:write(string.format("[%s] [ERROR] %s\n", get_time(), msg))
end

function logger.log(level, ...)
    if logger[level] then
        logger[level](...)
    end
end

function logger.table(t, msg)
    msg = msg or "Table dump:"
    logger.debug(msg)
    
    for k, v in pairs(t) do
        if type(v) == "table" then
            logger.debug(string.format("  %s: table", tostring(k)))
        else
            logger.debug(string.format("  %s: %s", tostring(k), tostring(v)))
        end
    end
end

function logger.trace()
    if not should_log("debug") then return end
    
    local trace = debug and debug.traceback() or "no traceback available"
    logger.debug("Traceback:")
    for line in string.gmatch(trace, "[^\n]+") do
        logger.debug("  " .. line)
    end
end

function logger.progress(current, total, msg)
    if not should_log("info") then return end
    
    local percent = math.floor((current / total) * 100)
    msg = msg or "Progress"
    
    io.stdout:write(string.format("\r[%s] [INFO] %s: %d/%d (%d%%)", 
        get_time(), msg, current, total, percent))
    
    if current >= total then
        io.stdout:write("\n")
    end
    
    io.stdout:flush()
end

function logger.file(path, level)
    local file = io.open(path, "a")
    
    local old_debug = logger.debug
    local old_info = logger.info
    local old_warn = logger.warn
    local old_error = logger.error
    
    function logger.debug(...)
        old_debug(...)
        if should_log("debug") then
            local args = {...}
            file:write(string.format("[%s] [DEBUG] %s\n", get_time(), table.concat(args, " ")))
            file:flush()
        end
    end
    
    function logger.info(...)
        old_info(...)
        if should_log("info") then
            local args = {...}
            file:write(string.format("[%s] [INFO] %s\n", get_time(), table.concat(args, " ")))
            file:flush()
        end
    end
    
    function logger.warn(...)
        old_warn(...)
        if should_log("warn") then
            local args = {...}
            file:write(string.format("[%s] [WARN] %s\n", get_time(), table.concat(args, " ")))
            file:flush()
        end
    end
    
    function logger.error(...)
        old_error(...)
        if should_log("error") then
            local args = {...}
            file:write(string.format("[%s] [ERROR] %s\n", get_time(), table.concat(args, " ")))
            file:flush()
        end
    end
    
    return function()
        file:close()
        logger.debug = old_debug
        logger.info = old_info
        logger.warn = old_warn
        logger.error = old_error
    end
end

return logger
