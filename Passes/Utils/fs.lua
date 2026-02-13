local fs = {}

function fs.read(path)
    local file, err = io.open(path, "r")
    if not file then
        return nil, err
    end
    
    local content = file:read("*all")
    file:close()
    
    return content
end

function fs.write(path, content)
    local file, err = io.open(path, "w")
    if not file then
        return false, err
    end
    
    file:write(content)
    file:close()
    
    return true
end

function fs.append(path, content)
    local file, err = io.open(path, "a")
    if not file then
        return false, err
    end
    
    file:write(content)
    file:close()
    
    return true
end

function fs.exists(path)
    local file = io.open(path, "r")
    if file then
        file:close()
        return true
    end
    return false
end

function fs.is_dir(path)
    local ok, err = os.execute('test -d "' .. path .. '"')
    return ok
end

function fs.mkdir(path)
    return os.execute('mkdir -p "' .. path .. '"')
end

function fs.rm(path)
    return os.execute('rm -rf "' .. path .. '"')
end

function fs.list(path)
    local handle = io.popen('ls -a "' .. path .. '"')
    local result = handle:read("*all")
    handle:close()
    
    local files = {}
    for file in string.gmatch(result, "[^\n]+") do
        if file ~= "." and file ~= ".." then
            table.insert(files, file)
        end
    end
    
    return files
end

function fs.copy(src, dst)
    return os.execute('cp -r "' .. src .. '" "' .. dst .. '"')
end

function fs.move(src, dst)
    return os.execute('mv "' .. src .. '" "' .. dst .. '"')
end

function fs.stat(path)
    local handle = io.popen('stat "' .. path .. '" 2>/dev/null')
    local result = handle:read("*all")
    handle:close()
    
    if result == "" then
        return nil
    end
    
    return {
        path = path,
        exists = true
    }
end

function fs.tmpfile()
    local name = "/tmp/lua_" .. tostring(math.random()) .. "_" .. tostring(os.time())
    return name
end

function fs.each_line(path)
    local file = io.open(path, "r")
    if not file then
        return function() return nil end
    end
    
    return function()
        local line = file:read()
        if not line then
            file:close()
        end
        return line
    end
end

function fs.basename(path)
    path = string.gsub(path, "\\", "/")
    return string.match(path, "([^/]+)$")
end

function fs.dirname(path)
    path = string.gsub(path, "\\", "/")
    return string.match(path, "^(.*)/") or "."
end

function fs.join(...)
    local parts = {...}
    return table.concat(parts, "/")
end

return fs
