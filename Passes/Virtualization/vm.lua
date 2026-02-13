local vm = {}

function vm.new(bytecode, env)
    local self = {
        stack = {},
        env = env or _G,
        pc = 1,
        bytecode = bytecode,
        registers = {},
    }
    
    function self:push(val)
        table.insert(self.stack, val)
    end
    
    function self:pop()
        return table.remove(self.stack)
    end
    
    function self:execute()
        while self.pc <= #self.bytecode do
            local op = self.bytecode[self.pc]
            self.pc = self.pc + 1
            
            if op[1] == "load" then
                self.registers[op[2]] = op[3]
            elseif op[1] == "call" then
                local func = self.registers[op[2]]
                local args = {}
                for i = 1, op[3] do
                    table.insert(args, self:pop())
                end
                local results = {func(unpack(args))}
                for i = 1, #results do
                    self:push(results[i])
                end
            elseif op[1] == "add" then
                local a = self.registers[op[2]]
                local b = self.registers[op[3]]
                self.registers[op[4]] = a + b
            elseif op[1] == "jmp" then
                self.pc = op[2]
            end
        end
    end
    
    return self
end

function vm.from_string(code, env)
    local f = loadstring(code)
    setfenv(f, env or _G)
    return {
        func = f,
        env = env or _G,
        run = function(self, ...)
            return self.func(...)
        end
    }
end

function vm.sandbox(code)
    local env = {}
    local func = loadstring(code)
    setfenv(func, env)
    return func
end

return vm
