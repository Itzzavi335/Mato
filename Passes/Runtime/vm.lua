local vm = {}

function vm.new(bytecode, env)
    local self = {
        stack = {},
        env = env or {},
        pc = 1,
        bytecode = bytecode,
        registers = {},
        callstack = {},
        flags = {eq = false, lt = false, gt = false},
    }
    
    function self:push(v)
        table.insert(self.stack, v)
    end
    
    function self:pop()
        return table.remove(self.stack)
    end
    
    function self:popn(n)
        local result = {}
        for i = 1, n do
            result[i] = self:pop()
        end
        return result
    end
    
    function self:pushn(t)
        for i = 1, #t do
            self:push(t[i])
        end
    end
    
    function self:fetch()
        local instr = self.bytecode[self.pc]
        self.pc = self.pc + 1
        return instr
    end
    
    function self:run()
        while self.pc <= #self.bytecode do
            local instr = self:fetch()
            local op = instr[1]
            local a = instr[2]
            local b = instr[3]
            local c = instr[4]
            
            if op == "move" then
                self.registers[a] = self.registers[b]
            elseif op == "loadk" then
                self.registers[a] = c
            elseif op == "loadbool" then
                self.registers[a] = b == 1
            elseif op == "loadnil" then
                self.registers[a] = nil
                self.registers[b] = nil
            elseif op == "add" then
                self.registers[a] = self.registers[b] + self.registers[c]
            elseif op == "sub" then
                self.registers[a] = self.registers[b] - self.registers[c]
            elseif op == "mul" then
                self.registers[a] = self.registers[b] * self.registers[c]
            elseif op == "div" then
                self.registers[a] = self.registers[b] / self.registers[c]
            elseif op == "mod" then
                self.registers[a] = self.registers[b] % self.registers[c]
            elseif op == "pow" then
                self.registers[a] = self.registers[b] ^ self.registers[c]
            elseif op == "unm" then
                self.registers[a] = -self.registers[b]
            elseif op == "not" then
                self.registers[a] = not self.registers[b]
            elseif op == "len" then
                self.registers[a] = #self.registers[b]
            elseif op == "concat" then
                local result = ""
                for i = b, c do
                    result = result .. tostring(self.registers[i])
                end
                self.registers[a] = result
            elseif op == "jmp" then
                self.pc = self.pc + a
            elseif op == "eq" then
                self.flags.eq = self.registers[b] == self.registers[c]
                if self.flags.eq then
                    self.pc = self.pc + a
                end
            elseif op == "lt" then
                self.flags.lt = self.registers[b] < self.registers[c]
                if self.flags.lt then
                    self.pc = self.pc + a
                end
            elseif op == "le" then
                self.flags.le = self.registers[b] <= self.registers[c]
                if self.flags.le then
                    self.pc = self.pc + a
                end
            elseif op == "test" then
                if not self.registers[a] then
                    self.pc = self.pc + b
                end
            elseif op == "call" then
                local func = self.registers[a]
                local args = {}
                for i = 1, b - 1 do
                    args[i] = self.registers[a + i]
                end
                
                local results = {func(unpack(args))}
                for i = 1, c do
                    self.registers[a + i - 1] = results[i]
                end
            elseif op == "return" then
                return unpack(self.registers, a, a + b - 1)
            elseif op == "newtable" then
                self.registers[a] = {}
            elseif op == "settable" then
                self.registers[a][self.registers[b]] = self.registers[c]
            elseif op == "gettable" then
                self.registers[a] = self.registers[b][self.registers[c]]
            elseif op == "setglobal" then
                self.env[self.registers[b]] = self.registers[a]
            elseif op == "getglobal" then
                self.registers[a] = self.env[self.registers[b]]
            elseif op == "closure" then
                self.registers[a] = function(...)
                    local closure_vm = vm.new(self.bytecode, self.env)
                    closure_vm.registers = self.registers
                    return closure_vm:run(...)
                end
            end
        end
    end
    
    return self
end

function vm.execute(bytecode, env)
    local v = vm.new(bytecode, env)
    return v:run()
end

function vm.wrap(bytecode, env)
    return function(...)
        return vm.execute(bytecode, env, ...)
    end
end

function vm.serialize(func)
    local info = debug and debug.getinfo(func)
    if not info then return nil end
    
    local bytecode = string.dump(func)
    local vm_code = [[
        local vm = require("vm")
        local env = getfenv(2)
        local bytecode = "]] .. bytecode:gsub("\\(%d+)", "\\%1") .. [["
        return vm.wrap(bytecode, env)
    ]]
    
    return loadstring(vm_code)()
end

return vm
