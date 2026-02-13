local flatten = {}

function flatten.blocks(code)
    local blocks = {}
    local current = {}
    
    for line in code:gmatch("[^\r\n]+") do
        if line:match("^%s*$") then
            if #current > 0 then
                table.insert(blocks, table.concat(current, "\n"))
                current = {}
            end
        else
            table.insert(current, line)
        end
    end
    
    if #current > 0 then
        table.insert(blocks, table.concat(current, "\n"))
    end
    
    return blocks
end

function flatten.sequence(funcs)
    return function(...)
        local args = {...}
        local result
        
        for i = 1, #funcs do
            if type(funcs[i]) == "function" then
                result = funcs[i](unpack(args))
                args = {result}
            end
        end
        
        return result
    end
end

function flatten.switch(index, cases, default)
    local case = cases[index]
    if case then
        return case()
    elseif default then
        return default()
    end
    return nil
end

function flatten.assign(targets, values)
    for i = 1, #targets do
        targets[i] = values[i] or nil
    end
    return targets
end

return flatten
