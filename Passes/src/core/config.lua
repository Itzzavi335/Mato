local config = {}

config.profiles = {
    fast = {
        name = "fast",
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
        junk_ratio = 0,
        encoding = "simple",
        vm = "basic",
        rename = {locals = true, globals = false},
    },
    
    normal = {
        name = "normal",
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
        junk_ratio = 0.3,
        encoding = "xor",
        vm = "normal",
        rename = {locals = true, globals = true},
    },
    
    max = {
        name = "max",
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
            whitespace = "obfuscate",
        },
        junk_ratio = 0.7,
        encoding = "aes",
        vm = "mutating",
        rename = {locals = true, globals = true},
    },
}

function config.get_profile(name)
    return config.profiles[name] or config.profiles.normal
end

function config.merge(profile, custom)
    profile = profile or "normal"
    custom = custom or {}
    
    local base = config.get_profile(profile)
    local result = {}
    
    for k, v in pairs(base) do
        result[k] = v
    end
    
    for k, v in pairs(custom) do
        if type(v) == "table" and type(result[k]) == "table" then
            for k2, v2 in pairs(v) do
                result[k][k2] = v2
            end
        else
            result[k] = v
        end
    end
    
    return result
end

function config.register_profile(name, settings)
    config.profiles[name] = settings
end

return config
