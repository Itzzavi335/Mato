local help = {}

local help_text = [[
Lua Obfuscator - Command Line Interface

Usage: lua-obfuscator <command> [input] [options]

Commands:
  obfuscate    Obfuscate a Lua file
    Examples:
      lua-obfuscator obfuscate script.lua
      lua-obfuscator obfuscate script.lua -o output.lua
      lua-obfuscator obfuscate script.lua -p heavy -v

  parse        Parse Lua file and show structure
    Examples:
      lua-obfuscator parse script.lua
      lua-obfuscator parse script.lua -v

  ast          Show AST of Lua file
    Examples:
      lua-obfuscator ast script.lua

  tokens       Show token stream
    Examples:
      lua-obfuscator tokens script.lua

  version      Show version information

Options:
  -o, --output FILE    Output file (default: stdout)
  -p, --profile NAME   Obfuscation profile (lite, medium, heavy, insane)
                       default: medium
  --config KEY=VALUE   Set specific config option
  -v, --verbose        Enable verbose output
  -h, --help [cmd]     Show this help or help for specific command

Profiles:
  lite         Fast obfuscation, minimal overhead
  medium       Balanced obfuscation for general use
  heavy        Strong obfuscation, significant overhead
  insane       Maximum protection, extreme overhead

Examples:
  # Basic obfuscation
  lua-obfuscator obfuscate script.lua -o script_obf.lua

  # Heavy obfuscation with verbose output
  lua-obfuscator obfuscate script.lua -p heavy -v

  # Parse and analyze
  lua-obfuscator parse script.lua

  # Show token stream
  lua-obfuscator tokens script.lua

  # Show AST
  lua-obfuscator ast script.lua

  # Custom configuration
  lua-obfuscator obfuscate script.lua --config junk_ratio=0.5 --config vm=mutating

For more information, visit: https://github.com/yourrepo/lua-obfuscator
]]

function help.show(command)
    if command then
        print(help.for_command(command))
    else
        print(help_text)
    end
end

function help.for_command(cmd)
    local cmd_help = {
        obfuscate = [[
Command: obfuscate
Description: Obfuscate a Lua file with various protection techniques

Usage: lua-obfuscator obfuscate <input> [options]

Arguments:
  input                  Lua source file to obfuscate

Options:
  -o, --output FILE      Output file (default: stdout)
  -p, --profile NAME     Obfuscation profile (lite, medium, heavy, insane)
  --config KEY=VALUE     Set specific config option
  -v, --verbose          Show detailed progress

Profiles:
  lite    - Fast, minimal protection
  medium  - Balanced protection (default)
  heavy   - Strong protection, larger output
  insane  - Maximum protection, extreme overhead

Examples:
  lua-obfuscator obfuscate script.lua
  lua-obfuscator obfuscate script.lua -o out.lua -p heavy
  lua-obfuscator obfuscate script.lua --config junk_ratio=0.5 -v
]],

        parse = [[
Command: parse
Description: Parse Lua file and display structural information

Usage: lua-obfuscator parse <input> [options]

Arguments:
  input                  Lua source file to parse

Options:
  -v, --verbose          Show detailed information

Example:
  lua-obfuscator parse script.lua
]],

        ast = [[
Command: ast
Description: Display Abstract Syntax Tree of Lua file

Usage: lua-obfuscator ast <input>

Arguments:
  input                  Lua source file

Example:
  lua-obfuscator ast script.lua
]],

        tokens = [[
Command: tokens
Description: Display token stream from lexical analysis

Usage: lua-obfuscator tokens <input>

Arguments:
  input                  Lua source file

Example:
  lua-obfuscator tokens script.lua
]],

        version = [[
Command: version
Description: Show version information

Usage: lua-obfuscator version

Example:
  lua-obfuscator version
]],
    }
    
    return cmd_help[cmd] or help_text
end

return help
