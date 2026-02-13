local args = {}

function args.parse(arg)
    local params = {
        input = nil,
        output = nil,
        command = nil,
        profile = "medium",
        verbose = false,
        help = false,
        config = {},
    }
    
    local i = 1
    while i <= #arg do
        local a = arg[i]
        
        if a == "-h" or a == "--help" then
            params.help = true
            params.command = arg[i+1]
            return params, nil
        elseif a == "-v" or a == "--verbose" then
            params.verbose = true
        elseif a == "-o" or a == "--output" then
            i = i + 1
            params.output = arg[i]
        elseif a == "-p" or a == "--profile" then
            i = i + 1
            params.profile = arg[i]
        elseif a == "--config" then
            i = i + 1
            local k, v = arg[i]:match("([^=]+)=(.*)")
            if k and v then
                params.config[k] = v
            end
        elseif a:sub(1, 1) == "-" then
            return nil, "unknown option: " .. a
        else
            if not params.command then
                params.command = a
            elseif not params.input then
                params.input = a
            else
                return nil, "too many arguments"
            end
        end
        
        i = i + 1
    end
    
    if not params.command and not params.help then
        return nil, "no command specified"
    end
    
    return params, nil
end

function args.usage()
    return [[
Usage: lua-obfuscator <command> [input] [options]

Commands:
  obfuscate    Obfuscate a Lua file
  parse        Parse Lua file and show structure
  ast          Show AST of Lua file
  tokens       Show token stream
  version      Show version

Options:
  -o, --output FILE    Output file
  -p, --profile NAME   Obfuscation profile (lite, medium, heavy, insane)
  --config KEY=VALUE   Set config option
  -v, --verbose        Verbose output
  -h, --help           Show help
]]
end

return args
