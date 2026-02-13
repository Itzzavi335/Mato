local medium = {
    name = "medium",
    description = "Balanced obfuscation for general use",
    
    passes = {
        rename = {locals = true, globals = true},
        flatten = true,
        opaque = true,
        junk = true,
        fakebranches = true,
        lifter = true,
        encoder = true,
        vmwrap = true,
        antitamper = true,
        envlock = true,
        metahide = true,
        whitespace = "random",
    },
    
    junk_ratio = 0.3,
    encoding = "xor",
    vm = "normal",
    
    security = {
        anti_debug = true,
        integrity_checks = true,
        environment_lock = true,
    },
    
    performance = {
        speed = "moderate",
        size = "medium",
        overhead = "medium",
    },
}

return medium
