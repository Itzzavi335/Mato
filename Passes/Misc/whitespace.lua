local whitespace = {}

function whitespace.remove(code)
    local lines = {}
    for line in code:gmatch("[^\r\n]+") do
        line = line:gsub("^%s+", "")
        line = line:gsub("%s+$", "")
        line = line:gsub("%s+", " ")
        table.insert(lines, line)
    end
    return table.concat(lines, "\n")
end

function whitespace.random(code)
    local result = {}
    for line in code:gmatch("[^\r\n]+") do
        local indent = string.rep(" ", math.random(0, 8))
        line = line:gsub("^%s*", indent)
        
        line = line:gsub("(%b())", function(p)
            return p:gsub("%s+", string.rep(" ", math.random(0, 3)))
        end)
        
        line = line:gsub("=", " " .. string.rep(" ", math.random(0, 2)) .. "=" .. string.rep(" ", math.random(0, 2)) .. " ")
        
        table.insert(result, line)
    end
    return table.concat(result, "\n" .. string.rep(" ", math.random(0, 4)))
end

function whitespace.minimal(code)
    code = code:gsub("%-%-[^\n]*", "")
    code = code:gsub("%s+", " ")
    code = code:gsub("%s*([%(%)%{%}%=%;%,])%s*", "%1")
    code = code:gsub(";+", ";")
    return code
end

function whitespace.preserve_strings(code)
    local strings = {}
    local counter = 0
    
    code = code:gsub('"([^"]*)"', function(s)
        counter = counter + 1
        strings[counter] = '"' .. s .. '"'
        return "__STR" .. counter .. "__"
    end)
    
    code = whitespace.remove(code)
    
    code = code:gsub("__STR(%d+)__", function(n)
        return strings[tonumber(n)]
    end)
    
    return code
end

function whitespace.obfuscate(code)
    local lines = {}
    for line in code:gmatch("[^\r\n]+") do
        if math.random() > 0.3 then
            line = string.rep(" ", math.random(0, 10)) .. line
        end
        if math.random() > 0.5 then
            line = line .. "  "
        end
        table.insert(lines, line)
    end
    return table.concat(lines, "\n" .. string.rep(" ", math.random(0, 5)))
end

return whitespace
