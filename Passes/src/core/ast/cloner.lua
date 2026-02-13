local cloner = {}

local function clone_table(tbl, copies)
    if type(tbl) ~= "table" then
        return tbl
    end
    
    if copies[tbl] then
        return copies[tbl]
    end
    
    local clone = {}
    copies[tbl] = clone
    
    for k, v in pairs(tbl) do
        local kclone = clone_table(k, copies)
        local vclone = clone_table(v, copies)
        clone[kclone] = vclone
    end
    
    local mt = getmetatable(tbl)
    if mt then
        setmetatable(clone, clone_table(mt, copies))
    end
    
    return clone
end

function cloner.deep_copy(obj)
    if obj == nil then
        return nil
    end
    
    local obj_type = type(obj)
    
    if obj_type == "number" or obj_type == "string" or obj_type == "boolean" then
        return obj
    end
    
    if obj_type == "table" then
        return clone_table(obj, {})
    end
    
    if obj_type == "function" then
        return function(...)
            return obj(...)
        end
    end
    
    return obj
end

function cloner.shallow_copy(tbl)
    if type(tbl) ~= "table" then
        return tbl
    end
    
    local clone = {}
    for k, v in pairs(tbl) do
        clone[k] = v
    end
    return clone
end

function cloner.copy_ast(node)
    if not node or type(node) ~= "table" then
        return node
    end
    
    local clone = {
        type = node.type,
        props = {},
    }
    
    if node.loc then
        clone.loc = {
            start = {line = node.loc.start.line, col = node.loc.start.col},
            end = {line = node.loc.end.line, col = node.loc.end.col}
        }
    end
    
    for k, v in pairs(node.props) do
        if type(v) == "table" then
            if v.type then
                clone.props[k] = cloner.copy_ast(v)
            elseif type(v[1]) == "table" and v[1].type then
                clone.props[k] = {}
                for i, item in ipairs(v) do
                    clone.props[k][i] = cloner.copy_ast(item)
                end
            else
                clone.props[k] = cloner.shallow_copy(v)
            end
        else
            clone.props[k] = v
        end
    end
    
    return clone
end

function cloner.merge_ast(target, source)
    for k, v in pairs(source.props) do
        if type(v) == "table" and v.type then
            target.props[k] = cloner.copy_ast(v)
        elseif type(v) == "table" then
            target.props[k] = cloner.shallow_copy(v)
        else
            target.props[k] = v
        end
    end
    return target
end

return cloner
