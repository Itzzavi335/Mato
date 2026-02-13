local lite = {
    name = "lite",
    description = "Fast obfuscation with minimal overhead",
    
    passes = {
        rename = {locals = true, globals = false},
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
    
    junk_ratio = 0,
    encoding = "simple",
    vm = "basic",
    
    security = {
        anti_debug = false,
        integrity_checks = false,
        environment_lock = false,
    },
    
    performance = {
        speed = "fast",
        size = "small",
        overhead = "low",
    },
}

return lite
