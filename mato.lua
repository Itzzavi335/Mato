#!/usr/bin/env lua

local init = require("init")
local args = {...}

local function main()
    if #args == 0 then
        print([[Lua Obfuscator - Mato
Usage: lua mato.lua <input.lua> [output.lua]

Examples:
  lua mato.lua input.lua              # prints to stdout
  lua mato.lua input.lua output.lua   # writes to file
  lua mato.lua --help                  # show help
]])
        return
    end
    
    if args[1] == "--help" or args[1] == "-h" then
        print("Mato Obfuscator - Protect your Lua code")
        print("\nUsage: lua mato.lua <input> [output]")
        print("\nOptions:")
        print("  input           Source file to obfuscate")
        print("  output          Output file (optional)")
        print("  -h, --help      Show this help")
        print("\nExample:")
        print("  lua mato.lua test.lua test_obf.lua")
        return
    end
    
    local input = args[1]
    local output = args[2]
    
    print("🔒 Mato Obfuscator v" .. init.version())
    print("Input: " .. input)
    
    local result, err = init.obfuscate_file(input, output)
    
    if not result then
        print("❌ Error: " .. err)
        os.exit(1)
    end
    
    if output then
        print("✅ Obfuscated code written to: " .. output)
    else
        print("\n" .. result)
    end
end

main()
