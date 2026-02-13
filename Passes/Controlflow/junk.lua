local junk = {}

local function nop()
end

local function waste()
    local a = 123
    local b = 456
    local c = a + b
    local d = c - a
    local e = d * 2
    local f = e / 2
    return f == b
end

function junk.insert(code)
    local junk_lines = {
        'local _ = math.random(1000)',
        'local a = "deadbeef"',
        'local b = #a',
        'local c = string.reverse(a)',
        'local d = string.upper(c)',
        'local _ = os.clock()',
        'local _ = table.pack(1,2,3,4,5)',
        'local x = 123 * 456',
        'local y = x / 123',
        'local z = y + 789',
    }
    
    local lines = {}
    for line in code:gmatch("[^\r\n]+") do
        table.insert(lines, line)
        if math.random() > 0.7 then
            table.insert(lines, junk_lines[math.random(#junk_lines)] .. " -- junk")
        end
    end
    
    return table.concat(lines, "\n")
end

function junk.variable(name)
    local prefixes = {"tmp", "temp", "t", "x", "y", "z", "a", "b", "c", "foo", "bar", "baz"}
    local suffixes = {"_", "_tmp", "_temp", "_local", "_var", "1", "2", "3"}
    
    if math.random() > 0.5 then
        return prefixes[math.random(#prefixes)] .. "_" .. name
    else
        return name .. suffixes[math.random(#suffixes)]
    end
end

function junk.condition(cond)
    local alts = {
        cond,
        "not not " .. cond,
        cond .. " == true",
        cond .. " ~= false",
        "(" .. cond .. ") == true",
        "type(" .. cond .. ") == 'boolean' and " .. cond,
    }
    return alts[math.random(#alts)]
end

return junk
