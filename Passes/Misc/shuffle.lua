local shuffle = {}

function shuffle.statements(code)
    local blocks = {}
    local current = {}
    
    for line in code:gmatch("[^\r\n]+") do
        if line:match("^%s*$") then
            if #current > 0 then
                table.insert(blocks, current)
                current = {}
            end
        else
            table.insert(current, line)
        end
    end
    
    if #current > 0 then
        table.insert(blocks, current)
    end
    
    for i = 1, #blocks do
        local idx = math.random(i, #blocks)
        blocks[i], blocks[idx] = blocks[idx], blocks[i]
    end
    
    local result = {}
    for _, block in ipairs(blocks) do
        for _, line in ipairs(block) do
            table.insert(result, line)
        end
        table.insert(result, "")
    end
    
    return table.concat(result, "\n")
end

function shuffle.expressions(code)
    return code:gsub("([%+%-%*%/%%%^])", function(op)
        local ops = {"+", "-", "*", "/", "%", "^"}
        return ops[math.random(#ops)]
    end)
end

function shuffle.blocks(func)
    local info = debug and debug.getinfo(func)
    if not info then return func end
    
    return function(...)
        local order = {1,2,3,4,5}
        for i = #order, 2, -1 do
            local j = math.random(i)
            order[i], order[j] = order[j], order[i]
        end
        
        local results = {}
        for _, i in ipairs(order) do
            if i <= select("#", ...) then
                table.insert(results, select(i, ...))
            end
        end
        
        return func(unpack(results))
    end
end

function shuffle.array(tbl)
    local n = #tbl
    for i = n, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end

function shuffle.strings(code)
    return code:gsub('"([^"]*)"', function(s)
        local chars = {}
        for i = 1, #s do
            table.insert(chars, string.sub(s, i, i))
        end
        shuffle.array(chars)
        return '"' .. table.concat(chars) .. '"'
    end)
end

return shuffle
