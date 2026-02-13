local lite = {
    name = "lite",
    
    passes = {
        rename = true,
        flatten = false,
        opaque = false,
        junk = false,
        fakebranches = false,
        lifter = true,
        encoder = true,
        vmwrap = true,
        antitamper = false,
        envlock = false,
        metahide = false,
        whitespace = "minimal",
    },
    
    rename = {
        locals = true,
        globals = false,
        functions = true,
        prefix = "_",
    },
    
    junk = {
        ratio = 0,
        complexity = "low",
    },
    
    encoding = {
        method = "simple",
        key = "default",
        passes = 1,
    },
    
    vm = {
        type = "basic",
        optimize = true,
    },
    
    security = {
        level = "low",
        anti_debug = false,
        anti_tamper = false,
    },
}

return lite
