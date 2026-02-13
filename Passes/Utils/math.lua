local math_utils = {}

function math_utils.clamp(x, min, max)
    return math.max(min, math.min(max, x))
end

function math_utils.lerp(a, b, t)
    return a + (b - a) * t
end

function math_utils.map(x, in_min, in_max, out_min, out_max)
    return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

function math_utils.round(x)
    return math.floor(x + 0.5)
end

function math_utils.sign(x)
    if x > 0 then return 1
    elseif x < 0 then return -1
    else return 0 end
end

function math_utils.factorial(n)
    if n <= 1 then return 1 end
    return n * math_utils.factorial(n - 1)
end

function math_utils.gcd(a, b)
    while b ~= 0 do
        a, b = b, a % b
    end
    return math.abs(a)
end

function math_utils.lcm(a, b)
    return math.abs(a * b) / math_utils.gcd(a, b)
end

function math_utils.is_prime(n)
    if n <= 1 then return false end
    if n <= 3 then return true end
    if n % 2 == 0 or n % 3 == 0 then return false end
    
    local i = 5
    while i * i <= n do
        if n % i == 0 or n % (i + 2) == 0 then
            return false
        end
        i = i + 6
    end
    
    return true
end

function math_utils.fibonacci(n)
    if n <= 1 then return n end
    
    local a, b = 0, 1
    for i = 2, n do
        a, b = b, a + b
    end
    return b
end

function math_utils.mean(t)
    local sum = 0
    for _, v in ipairs(t) do
        sum = sum + v
    end
    return sum / #t
end

function math_utils.median(t)
    local sorted = {}
    for _, v in ipairs(t) do
        table.insert(sorted, v)
    end
    table.sort(sorted)
    
    local n = #sorted
    if n % 2 == 1 then
        return sorted[(n + 1) / 2]
    else
        return (sorted[n / 2] + sorted[n / 2 + 1]) / 2
    end
end

function math_utils.variance(t)
    local m = math_utils.mean(t)
    local sum = 0
    
    for _, v in ipairs(t) do
        sum = sum + (v - m) ^ 2
    end
    
    return sum / #t
end

function math_utils.stddev(t)
    return math.sqrt(math_utils.variance(t))
end

function math_utils.entropy(t)
    local total = 0
    for _, v in ipairs(t) do
        total = total + v
    end
    
    local entropy = 0
    for _, v in ipairs(t) do
        local p = v / total
        if p > 0 then
            entropy = entropy - p * math.log(p)
        end
    end
    
    return entropy
end

function math_utils.random_in_range(min, max)
    return min + math.random() * (max - min)
end

function math_utils.random_int_in_range(min, max)
    return math.floor(min + math.random() * (max - min + 1))
end

return math_utils
