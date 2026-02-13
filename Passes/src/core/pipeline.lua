local pipeline = {}

local passes = {
    -- parsing phase
    {name = "lexer", run = function(ctx) ctx:lex() end},
    {name = "parser", run = function(ctx) ctx:parse() end},
    
    -- transformation phase
    {name = "rename", run = function(ctx) 
        local r = require("transform.rename")
        ctx.ast = r.process(ctx.ast, ctx.config.rename)
    end},
    
    {name = "flatten", run = function(ctx)
        local f = require("control.flatten")
        ctx.ast = f.process(ctx.ast)
    end},
    
    {name = "opaque", run = function(ctx)
        local o = require("obfuscate.opaque")
        ctx.ast = o.insert_predicates(ctx.ast)
    end},
    
    {name = "junk", run = function(ctx)
        local j = require("obfuscate.junk")
        ctx.ast = j.inject(ctx.ast, ctx.config.junk_ratio)
    end},
    
    {name = "fakebranches", run = function(ctx)
        local f = require("control.fakebranches")
        ctx.ast = f.transform(ctx.ast)
    end},
    
    -- virtualization phase
    {name = "lifter", run = function(ctx)
        local l = require("vm.lifter")
        ctx.ir = l.ast_to_ir(ctx.ast)
    end},
    
    {name = "encoder", run = function(ctx)
        local e = require("vm.encoder")
        ctx.bytecode = e.encode(ctx.ir, ctx.config.encoding)
    end},
    
    {name = "vmwrap", run = function(ctx)
        local v = require("vm.vm")
        ctx.output = v.wrap(ctx.bytecode, ctx.config.vm)
    end},
    
    -- final protection
    {name = "antitamper", run = function(ctx)
        local a = require("protect.antitamper")
        ctx.output = a.inject(ctx.output)
    end},
    
    {name = "envlock", run = function(ctx)
        local e = require("protect.envlock")
        ctx.output = e.wrap(ctx.output)
    end},
    
    {name = "metahide", run = function(ctx)
        local m = require("transform.metahide")
        ctx.output = m.process(ctx.output)
    end},
    
    -- cleanup
    {name = "whitespace", run = function(ctx)
        local w = require("format.whitespace")
        ctx.output = w.process(ctx.output, ctx.config.whitespace)
    end},
}

function pipeline.execute(ctx)
    for _, pass in ipairs(passes) do
        if ctx.config.passes[pass.name] ~= false then
            local ok, err = xpcall(pass.run, debug.traceback, ctx)
            if not ok then
                error(string.format("pass '%s' failed: %s", pass.name, err))
            end
            ctx.stats.passes[pass.name] = true
        end
    end
end

function pipeline.register(name, func)
    table.insert(passes, {name = name, run = func})
end

function pipeline.remove(name)
    for i = #passes, 1, -1 do
        if passes[i].name == name then
            table.remove(passes, i)
        end
    end
end

return pipeline
