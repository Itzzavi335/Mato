local insane = {
    name = "insane",
    
    passes = {
        rename = {maximal = true},
        flatten = {complete = true},
        opaque = {maximum = true},
        junk = {insane = true},
        fakebranches = {infinite = true},
        lifter = {full = true},
        encoder = {polymorphic = true},
        vmwrap = {polymorphic = true},
        antitamper = {paranoid = true},
        envlock = {absolute = true},
        metahide = {total = true},
        integrity = {continuous = true},
        selfmodify = true,
        whitespace = "none",
    },
    
    rename = {
        locals = {all = true, random = true},
        globals = {all = true, random = true},
        functions = {all = true, random = true},
        strings = {encrypt = true, random = true},
        prefix = {random = true},
        suffix = {random = true},
        min_length = 0,
        max_length = 2,
        use_unicode = true,
        use_control_chars = true,
    },
    
    junk = {
        ratio = 0.9,
        complexity = "insane",
        insert_comments = {random = true},
        dead_code = {multiple = true},
        unreachable_code = {nested = true},
        nested_blocks = {infinite = true},
        self_modifying = true,
    },
    
    opaque = {
        predicates = {complex = true, nested = true},
        constants = {encrypted = true, dynamic = true},
        expressions = {nested = true, recursive = true},
        count = 999,
        depth = 99,
    },
    
    fakebranches = {
        count = 99,
        depth = 99,
        probability = 0.9,
        nested = true,
        recursive = true,
        polymorphic = true,
    },
    
    encoding = {
        method = "aes-256",
        key = "quantum",
        passes = 10,
        obfuscate_strings = {all = true},
        encrypt_bytecode = true,
        multi_layer = true,
    },
    
    vm = {
        type = "polymorphic",
        optimize = false,
        cache = false,
        instruction_set = "random",
        mutate_each_run = true,
        virtualization = "full",
    },
    
    security = {
        level = "maximum",
        anti_debug = {all = true, aggressive = true},
        anti_tamper = {paranoid = true},
        integrity_checks = {continuous = true, recursive = true},
        environment_lock = {absolute = true},
        bytecode_encryption = {multiple = true, quantum = true},
        self_modifying = {continuous = true},
        anti_analysis = {all = true},
        anti_dump = true,
        anti_hook = true,
    },
    
    performance = {
        speed = "unusable",
        size = "infinite",
        overhead = "extreme",
        notes = "may cause system instability",
    },
}

return insane
