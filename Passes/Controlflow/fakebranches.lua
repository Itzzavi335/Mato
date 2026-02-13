local fakebranches = {}

local function always_true()
    local a = 1
    local b = 2
    local c = a + b
    local d = c - a
    return d == b
end

local function always_false()
    local a = "hello"
    local b = "world"
    local c = a .. b
    local d = #c
    return d == 0
end

function fakebranches.insert(blocks)
    local result = {}
    
    for i = 1, #blocks do
        if math.random() > 0.3 then
            if always_true() then
                table.insert(result, blocks[i])
            else
                table.insert(result, "-- dead branch")
                table.insert(result, blocks[i])
            end
        else
            if always_false() then
                table.insert(result, "-- unreachable")
            else
                table.insert(result, blocks[i])
            end
        end
    end
    
    return result
end

function fakebranches.ifelse(real, fake)
    local cond = math.random() > 0.5
    if cond then
        return real()
    else
        return fake()
    end
end

function fakebranches.switch(value, cases)
    local real = cases[value]
    local fake = cases[value + 1] or cases[1]
    
    if math.random() > 0.8 then
        return fake()
    else
        return real()
    end
end

function fakebranches.obfuscate(cond)
    local variants = {
        cond,
        "not not " .. cond,
        cond .. " and true",
        cond .. " or false",
        cond .. " == true",
        cond .. " ~= false",
        "(" .. cond .. ") ~= nil",
        cond .. " and 1 or 0 == 1",
    }
    
    return variants[math.random(#variants)]
end

return fakebranches
