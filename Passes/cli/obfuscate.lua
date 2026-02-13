local obfuscate = {}
local compiler = require("core.compiler")
local logger = require("utils.logger")
local fs = require("utils.fs")

function obfuscate.run(params)
    if not params.input then
        return nil, "no input file specified"
    end
    
    logger.info("obfuscating:", params.input)
    logger.info("profile:", params.profile)
    
    local source = fs.read(params.input)
    if not source then
        return nil, "cannot read input file: " .. params.input
    end
    
    local config = {
        profile = params.profile,
        verbose = params.verbose,
    }
    
    for k, v in pairs(params.config) do
        config[k] = v
    end
    
    local output, err = compiler.compile(source, config)
    if not output then
        return nil, "compilation failed: " .. tostring(err)
    end
    
    if params.output then
        local ok, err = fs.write(params.output, output)
        if not ok then
            return nil, "cannot write output: " .. tostring(err)
        end
        logger.info("written to:", params.output)
    else
        print(output)
    end
    
    return "obfuscation complete"
end

return obfuscate
