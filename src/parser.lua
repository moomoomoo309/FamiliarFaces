utils = utils or require "pl.utils"
map = map or require "map"
pretty = pretty or require "pl.pretty"
scenes = scenes or require "scenes"


local function strip(s)
    local spaceFree = s:gsub(" ", "")
    if #spaceFree <= 1 then
        return spaceFree
    end
    return s:sub(s:find(spaceFree:sub(0, 1), nil, true), -s:reverse():find(spaceFree:sub(-1), nil, true))
end

local commands = {}

local function getFromIndices(...)
    return select("#", ...) >= 3 and tablex.get((...)[select(2, ...)], select(3, ...)) or (...)[select(2, ...)]
end

local function promptPlayer(tbl)
    local choices = {}
    for k in pairs(tbl) do
        choices[#choices + 1] = k
    end
    print(choices[1])
    return choices[1]
end

local good = 0

local function processVal(tbl)
    if type(tbl) == "table" then
        for i = 1, #tbl do
            print(i)
            local val = tbl[i]
            local t = type(val)
            if t == "string" then
                if val:sub(1, 1) ~= "@" then
                    print(val)
                else
                    local cmd = val:sub(1, val:find(" ", nil, true) or #val)
                    if commands[cmd] then
                        commands[cmd]()
                    end
                end
                coroutine.yield()
            elseif t == "table" then
                local choice = promptPlayer(val)
                print(pretty.write(val[choice]))
                processVal(val[choice])
            elseif t == "function" then
                processVal(val(good))
            end
        end
    end
end

local process = function(path)
    local processTbl = require(path)
    if type(processTbl) == "table" then
        return coroutine.create(processVal), processTbl
    else
        return false
    end
end

return { process = process }