local heavy = {
    name = "heavy",
    description = "Strong obfuscation with significant overhead",
    
    passes = {
        rename = {locals = true, globals = true, strings = true},
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
        whitespace = "obfuscate",
    },
    
    junk_ratio = 0.5,
    encoding = "rc4",
    vm = "mutating",
    
    security = {
        anti_debug = true,
        anti_tamper = true,
        integrity_checks = true,
        environment_lock = true,
        bytecode_encryption = true,
    },
    
    performance = {
        speed = "slow",
        size = "large",
        overhead = "high",
    },
}

return heavy
