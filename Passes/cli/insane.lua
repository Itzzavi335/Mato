local insane = {
    name = "insane",
    description = "Maximum protection, minimal performance consideration",
    
    passes = {
        rename = {locals = true, globals = true, strings = true, functions = true},
        flatten = {maximal = true},
        opaque = {predicates = true, constants = true},
        junk = {ratio = 0.8, complexity = "high"},
        fakebranches = {multiple = true, nested = true},
        lifter = {optimize = false},
        encoder = {multiple_passes = true},
        vmwrap = {polymorphic = true},
        antitamper = {aggressive = true},
        envlock = {deep = true},
        metahide = {all = true},
        integrity = {continuous = true},
        whitespace = "none",
    },
    
    junk_ratio = 0.8,
    encoding = "aes+rc4",
    vm = "polymorphic",
    
    security = {
        anti_debug = {all = true},
        anti_tamper = {aggressive = true},
        integrity_checks = {continuous = true},
        environment_lock = {deep = true},
        bytecode_encryption = {multiple = true},
        self_modifying = true,
        virtualization = {full = true},
    },
    
    performance = {
        speed = "very slow",
        size = "massive",
        overhead = "extreme",
    },
}

return insane
