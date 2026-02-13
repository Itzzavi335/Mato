local context = {}

function context.new(source, options)
    local self = {
        source = source,
        options = options or {},
        config = require("config").merge(options.profile),
        
        ast = nil,
        ir = nil,
        tokens = nil,
        bytecode = nil,
        output = nil,
        
        symbols = {},
        strings = {},
        numbers = {},
        
        stats = {
            start_time = os.clock(),
            end_time = nil,
            passes = {},
            original_size = #source,
            final_size = nil,
        },
        
        env = options.env or {},
        filename = options.filename or "string",
        line = 1,
        col = 1,
    }
    
    function self:lex()
        local lexer = require("lexer")
        self.tokens = lexer.scan(self.source)
    end
    
    function self:parse()
        local parser = require("parser")
        self.ast = parser.parse(self.tokens)
    end
    
    function self:add_symbol(name, info)
        self.symbols[name] = info
    end
    
    function self:get_symbol(name)
        return self.symbols[name]
    end
    
    function self:error(msg, level)
        level = level or 2
        local info = debug.getinfo(level, "Sl")
        local line = info.currentline
        error(string.format("%s:%d: %s", self.filename, line, msg))
    end
    
    function self:finish()
        self.stats.end_time = os.clock()
        self.stats.final_size = #self.output
        self.stats.time = self.stats.end_time - self.stats.start_time
    end
    
    return self
end

function context.from_file(path)
    local file = io.open(path, "r")
    if not file then return nil end
    local source = file:read("*all")
    file:close()
    return context.new(source, {filename = path})
end

return context
