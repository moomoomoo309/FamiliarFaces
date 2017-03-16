utils = utils or require "pl.utils"
map = map or require "map"
pretty = pretty or require "pl.pretty"
scenes = scenes or require "scenes"
transX, transY = transX, transY --To tell IntelliJ this is intentional global "creation"

local function promptPlayer(tbl)
    local choices = {}
    for k in pairs(tbl) do
        choices[#choices + 1] = k
    end
    print(choices[1])
    return choices[1]
end

local good = 0
local commands = {
    ["+1"]=function() good=good+1 end,
    ["-1"]=function() good=good-1 end,

}

local function processVal(tbl)
    if type(tbl) == "table" then
        for i = 1, #tbl do
            print(i)
            local val = tbl[i]
            local t = type(val)
            if t == "string" then
                local firstChar = val:sub(1, 1)
                local firstWord = val:sub(0, val:find(" ", nil, true) or #val)
                if firstChar == "@" then
                    local cmd = firstWord:sub(1)
                    if commands[cmd] then
                        commands[cmd]()
                    end
                elseif firstWord:lower() == "*sfx" then
                    local findSpace = val:find(" ", nil, true)
                    if findSpace then
                        love.audio.play(val:sub(findSpace + 1))
                    end
                elseif val:sub(0, 2) == "/r" then
                    transX, transY = scenes:printText(val:sub(3), false)
                else
                    transX, transY = scenes:printText(val, false)
                end
                coroutine.yield()
            elseif t == "table" then
                local choice = promptPlayer(val)
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