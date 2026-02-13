local table_utils = {}

function table_utils.deep_copy(t)
    if type(t) ~= "table" then
        return t
    end
    
    local copy = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            copy[k] = table_utils.deep_copy(v)
        else
            copy[k] = v
        end
    end
    
    return copy
end

function table_utils.merge(t1, t2)
    local result = table_utils.deep_copy(t1)
    
    for k, v in pairs(t2) do
        if type(v) == "table" and type(result[k]) == "table" then
            result[k] = table_utils.merge(result[k], v)
        else
            result[k] = v
        end
    end
    
    return result
end

function table_utils.keys(t)
    local keys = {}
    for k, _ in pairs(t) do
        table.insert(keys, k)
    end
    return keys
end

function table_utils.values(t)
    local values = {}
    for _, v in pairs(t) do
        table.insert(values, v)
    end
    return values
end

function table_utils.filter(t, f)
    local result = {}
    for k, v in pairs(t) do
        if f(v, k) then
            result[k] = v
        end
    end
    return result
end

function table_utils.map(t, f)
    local result = {}
    for k, v in pairs(t) do
        result[k] = f(v, k)
    end
    return result
end

function table_utils.reduce(t, f, init)
    local acc = init
    for k, v in pairs(t) do
        if acc == nil then
            acc = v
        else
            acc = f(acc, v, k)
        end
    end
    return acc
end

function table_utils.find(t, f)
    for k, v in pairs(t) do
        if f(v, k) then
            return v, k
        end
    end
    return nil
end

function table_utils.includes(t, value)
    for _, v in pairs(t) do
        if v == value then
            return true
        end
    end
    return false
end

function table_utils.slice(t, i, j)
    i = i or 1
    j = j or #t
    
    local result = {}
    for idx = i, j do
        table.insert(result, t[idx])
    end
    return result
end

function table_utils.reverse(t)
    local result = {}
    for i = #t, 1, -1 do
        table.insert(result, t[i])
    end
    return result
end

function table_utils.flatten(t)
    local result = {}
    
    local function _flatten(arr)
        for _, v in ipairs(arr) do
            if type(v) == "table" then
                _flatten(v)
            else
                table.insert(result, v)
            end
        end
    end
    
    _flatten(t)
    return result
end

function table_utils.group_by(t, f)
    local result = {}
    
    for _, v in ipairs(t) do
        local key = f(v)
        if not result[key] then
            result[key] = {}
        end
        table.insert(result[key], v)
    end
    
    return result
end

function table_utils.counts(t)
    local counts = {}
    for _, v in ipairs(t) do
        counts[v] = (counts[v] or 0) + 1
    end
    return counts
end

function table_utils.equals(t1, t2)
    if type(t1) ~= type(t2) then
        return false
    end
    
    if type(t1) ~= "table" then
        return t1 == t2
    end
    
    local seen = {}
    
    for k, v in pairs(t1) do
        if not table_utils.equals(v, t2[k]) then
            return false
        end
        seen[k] = true
    end
    
    for k, _ in pairs(t2) do
        if not seen[k] then
            return false
        end
    end
    
    return true
end

return table_utils
