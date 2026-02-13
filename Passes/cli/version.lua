local version_cmd = {}

function version_cmd.run()
    local version = "1.0.0"
    local build = "2024"
    
    return string.format([[
Lua Obfuscator v%s (%s)

Components:
  Core      : 1.0.0
  CLI       : 1.0.0
  VM        : 1.0.0
  Crypto    : 1.0.0

Lua Version: 5.1
]], version, build)
end

return version_cmd
