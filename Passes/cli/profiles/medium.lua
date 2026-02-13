local medium = {
    name = "medium",
    
    passes = {
        rename = true,
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
    
    rename = {
        locals = true,
        globals = true,
        functions = true,
        strings = false,
        prefix = "",
        suffix = "",
        min_length = 3,
        max_length = 8,
    },
    
    junk = {
        ratio = 0.3,
        complexity = "medium",
        insert_comments = true,
        dead_code = true,
    },
    
    opaque = {
        predicates = true,
        constants = true,
        expressions = true,
    },
    
    fakebranches = {
        count = 5,
        depth = 2,
        probability = 0.3,
    },
    
    encoding = {
        method = "xor",
        key = "random",
        passes = 2,
    },
    
    vm = {
        type = "normal",
        optimize = true,
        cache = true,
    },
    
    security = {
        level = "medium",
        anti_debug = true,
        anti_tamper = true,
        integrity_checks = true,
    },
}

return medium
