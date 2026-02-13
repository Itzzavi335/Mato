local grammar = {}

grammar.rules = {
    chunk = {
        "stat*",
        "return?",
    },
    
    stat = {
        "if",
        "while",
        "repeat",
        "for",
        "function",
        "local",
        "return",
        "break",
        "label",
        "assignment",
        "call",
    },
    
    if = {
        "'if' expr 'then' chunk ('elseif' expr 'then' chunk)* ('else' chunk)? 'end'",
    },
    
    while = {
        "'while' expr 'do' chunk 'end'",
    },
    
    repeat = {
        "'repeat' chunk 'until' expr",
    },
    
    for = {
        "'for' name '=' expr ',' expr (',' expr)? 'do' chunk 'end'",
        "'for' namelist 'in' explist 'do' chunk 'end'",
    },
    
    function = {
        "'function' funcname '(' funcbody ')'",
        "'local' 'function' name '(' funcbody ')'",
        "'local' namelist ('=' explist)?",
    },
    
    return = {
        "'return' explist?",
    },
    
    break = {
        "'break'",
    },
    
    label = {
        "'::' name '::'",
    },
    
    assignment = {
        "varlist '=' explist",
    },
    
    call = {
        "prefixexp args",
        "prefixexp ':' name args",
    },
    
    expr = {
        "subexpr",
    },
    
    subexpr = {
        "unary subexpr",
        "simpleexp binop subexpr",
        "simpleexp",
    },
    
    simpleexp = {
        "number",
        "string",
        "nil",
        "true",
        "false",
        "...",
        "function",
        "table",
        "prefixexp",
    },
    
    prefixexp = {
        "name",
        "'(' expr ')'",
        "prefixexp '[' expr ']'",
        "prefixexp '.' name",
        "prefixexp args",
        "prefixexp ':' name args",
    },
    
    function_expr = {
        "'function' '(' funcbody ')'",
    },
    
    table = {
        "'{' fieldlist? '}'",
    },
    
    fieldlist = {
        "field (fieldsep field)* fieldsep?",
    },
    
    field = {
        "'[' expr ']' '=' expr",
        "name '=' expr",
        "expr",
    },
    
    fieldsep = {
        "','",
        "';'",
    },
    
    funcbody = {
        "parlist? ')' chunk 'end'",
    },
    
    parlist = {
        "namelist (',' '...')?",
        "'...'",
    },
    
    namelist = {
        "name (',' name)*",
    },
    
    explist = {
        "expr (',' expr)*",
    },
    
    varlist = {
        "var (',' var)*",
    },
    
    var = {
        "name",
        "prefixexp '[' expr ']'",
        "prefixexp '.' name",
    },
    
    funcname = {
        "name ('.' name)* (':' name)?",
    },
    
    name = {
        "identifier",
    },
    
    number = {
        "number_literal",
    },
    
    string = {
        "string_literal",
    },
}

function grammar.validate(rule, node)
    local pattern = grammar.rules[rule]
    if not pattern then
        return false, "unknown rule: " .. rule
    end
    
    return true
end

function grammar.expand(rule)
    return grammar.rules[rule] or {}
end

return grammar
