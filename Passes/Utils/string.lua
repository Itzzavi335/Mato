local string_utils = {}

function string_utils.split(str, delim)
    delim = delim or "%s+"
    local result = {}
    
    for part in string.gmatch(str, "([^" .. delim .. "]+)") do
        table.insert(result, part)
    end
    
    return result
end

function string_utils.trim(str)
    return string.match(str, "^%s*(.-)%s*$")
end

function string_utils.escape(str)
    str = string.gsub(str, "\\", "\\\\")
    str = string.gsub(str, '"', '\\"')
    str = string.gsub(str, "\n", "\\n")
    str = string.gsub(str, "\r", "\\r")
    str = string.gsub(str, "\t", "\\t")
    return '"' .. str .. '"'
end

function string_utils.unescape(str)
    str = string.gsub(str, '^"(.*)"$', "%1")
    str = string.gsub(str, '\\"', '"')
    str = string.gsub(str, "\\\\", "\\")
    str = string.gsub(str, "\\n", "\n")
    str = string.gsub(str, "\\r", "\r")
    str = string.gsub(str, "\\t", "\t")
    return str
end

function string_utils.starts_with(str, prefix)
    return string.sub(str, 1, #prefix) == prefix
end

function string_utils.ends_with(str, suffix)
    return #str >= #suffix and string.sub(str, -#suffix) == suffix
end

function string_utils.contains(str, sub)
    return string.find(str, sub, 1, true) ~= nil
end

function string_utils.replace(str, old, new)
    return string.gsub(str, old, new, 1)
end

function string_utils.replace_all(str, old, new)
    return string.gsub(str, old, new)
end

function string_utils.reverse(str)
    local result = {}
    for i = #str, 1, -1 do
        table.insert(result, string.sub(str, i, i))
    end
    return table.concat(result)
end

function string_utils.random(len, charset)
    charset = charset or "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    len = len or 8
    
    local result = {}
    for i = 1, len do
        result[i] = string.sub(charset, math.random(1, #charset), math.random(1, #charset))
    end
    
    return table.concat(result)
end

function string_utils.obfuscate(str)
    local result = {}
    for i = 1, #str do
        result[i] = string.format("\\%d", string.byte(str, i))
    end
    return table.concat(result)
end

function string_utils.indent(str, spaces)
    spaces = spaces or 4
    local indent = string.rep(" ", spaces)
    return indent .. string.gsub(str, "\n", "\n" .. indent)
end

function string_utils.wrap(str, width)
    width = width or 80
    local result = {}
    local line = ""
    
    for word in string.gmatch(str, "%S+") do
        if #line + #word + 1 > width then
            table.insert(result, line)
            line = word
        elseif line == "" then
            line = word
        else
            line = line .. " " .. word
        end
    end
    
    if line ~= "" then
        table.insert(result, line)
    end
    
    return table.concat(result, "\n")
end

function string_utils.levenshtein(s, t)
    local m, n = #s, #t
    local d = {}
    
    for i = 0, m do
        d[i] = {[0] = i}
    end
    for j = 0, n do
        d[0][j] = j
    end
    
    for i = 1, m do
        for j = 1, n do
            local cost = string.sub(s, i, i) == string.sub(t, j, j) and 0 or 1
            d[i][j] = math.min(
                d[i-1][j] + 1,
                d[i][j-1] + 1,
                d[i-1][j-1] + cost
            )
        end
    end
    
    return d[m][n]
end

return string_utils
