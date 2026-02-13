local random = {}

function random.string(len)
    len = len or 8
    local chars = {}
    local set = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"
    
    for i = 1, len do
        chars[i] = string.sub(set, math.random(1, #set), math.random(1, #set))
    end
    
    return table.concat(chars)
end

function random.number(min, max)
    min = min or 0
    max = max or 1
    return min + (max - min) * math.random()
end

function random.integer(min, max)
    return math.floor(random.number(min, max + 0.999999))
end

function random.bool()
    return math.random() > 0.5
end

function random.choice(t)
    return t[math.random(1, #t)]
end

function random.shuffle(t)
    local n = #t
    for i = n, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
    return t
end

function random.sample(t, n)
    n = n or 1
    local copy = {}
    for i = 1, #t do
        copy[i] = t[i]
    end
    
    random.shuffle(copy)
    
    local result = {}
    for i = 1, n do
        result[i] = copy[i]
    end
    
    return result
end

function random.bytes(n)
    local bytes = {}
    for i = 1, n do
        bytes[i] = string.char(math.random(0, 255))
    end
    return table.concat(bytes)
end

function random.hex(len)
    len = len or 8
    local hex = "0123456789abcdef"
    local result = {}
    
    for i = 1, len do
        result[i] = string.sub(hex, math.random(1, 16), math.random(1, 16))
    end
    
    return table.concat(result)
end

function random.weighted(weights)
    local total = 0
    for _, w in ipairs(weights) do
        total = total + w
    end
    
    local r = math.random() * total
    local sum = 0
    
    for i, w in ipairs(weights) do
        sum = sum + w
        if r <= sum then
            return i
        end
    end
    
    return #weights
end

function random.gaussian(mean, stddev)
    mean = mean or 0
    stddev = stddev or 1
    
    local u1 = math.random()
    local u2 = math.random()
    
    local z0 = math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2)
    
    return mean + z0 * stddev
end

function random.token()
    local time = tostring(os.time())
    local rand = tostring(math.random())
    local token = random.string(4) .. time .. rand .. random.string(4)
    return crypto and crypto.hash(token) or token
end

return random
