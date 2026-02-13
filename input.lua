local function add(a, b)
    return a + b
end

local function subtract(a, b)
    return a - b
end

local function multiply(a, b)
    return a * b
end

local function divide(a, b)
    if b == 0 then
        error("division by zero")
    end
    return a / b
end

local calculator = {
    add = add,
    sub = subtract,
    mul = multiply,
    div = divide
}

function calculator.run(op, x, y)
    if op == "add" then
        return calculator.add(x, y)
    elseif op == "sub" then
        return calculator.sub(x, y)
    elseif op == "mul" then
        return calculator.mul(x, y)
    elseif op == "div" then
        return calculator.div(x, y)
    else
        error("unknown operation: " .. op)
    end
end

local result = calculator.run("add", 10, 5)
print("10 + 5 =", result)

result = calculator.run("mul", 6, 7)
print("6 * 7 =", result)
