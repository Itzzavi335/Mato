local heavy = {
    name = "heavy",
    
    passes = {
        rename = true,
        flatten = {maximal = true},
        opaque = {all = true},
        junk = {aggressive = true},
        fakebranches = {multiple = true},
        lifter = true,
        encoder = {multiple = true},
        vmwrap = {advanced = true},
        antitamper = {aggressive = true},
        envlock = {deep = true},
        metahide = {all = true},
        integrity = true,
        whitespace = "obfuscate",
    },
    
    rename = {
        locals = true,
        globals = true,
        functions = true,
        strings = true,
        prefix = "",
        suffix = "",
        min_length = 1,
        max_length = 4,
        use_unicode = true,
    },
    
    junk = {
        ratio = 0.6,
        complexity = "high",
        insert_comments = true,
        dead_code = true,
        unreachable_code = true,
        nested_blocks = true,
    },
    
    opaque = {
        predicates = {complex = true},
        constants = {encrypted = true},
        expressions = {nested = true},
        count = 20,
    },
    
    fakebranches = {
        count = 15,
        depth = 4,
        probability = 0.5,
        nested = true,
    },
    
    encoding = {
        method = "rc4",
        key = "dynamic",
        passes = 3,
        obfuscate_strings = true,
    },
    
    vm = {
        type = "mutating",
        optimize = false,
        cache = true,
        instruction_set = "custom",
    },
    
    security = {
        level = "high",
        anti_debug = {all = true},
        anti_tamper = {aggressive = true},
        integrity_checks = {continuous = true},
        environment_lock = true,
        bytecode_encryption = true,
    },
}

return heavy
