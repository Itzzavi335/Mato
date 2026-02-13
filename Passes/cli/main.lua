#!/usr/bin/env lua

local args = require("cli.args")
local commands = {
    obfuscate = require("cli.commands.obfuscate"),
    parse = require("cli.commands.parse"),
    ast = require("cli.commands.ast"),
    tokens = require("cli.commands.tokens"),
    version = require("cli.commands.version"),
}
local help = require("cli.help")
local logger = require("utils.logger")

local function main()
    local params, err = args.parse(arg)
    
    if err then
        logger.error(err)
        os.exit(1)
    end
    
    if params.help or not params.command then
        help.show(params.command)
        os.exit(0)
    end
    
    local cmd = commands[params.command]
    if not cmd then
        logger.error("unknown command: " .. params.command)
        help.show()
        os.exit(1)
    end
    
    local ok, result = pcall(cmd.run, params)
    
    if not ok then
        logger.error("command failed:", result)
        os.exit(1)
    end
    
    if result and type(result) == "string" then
        print(result)
    end
    
    os.exit(0)
end

main()
