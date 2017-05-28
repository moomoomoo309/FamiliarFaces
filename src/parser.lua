utils = utils or require "pl.utils"
map = map or require "map"
pretty = pretty or require "pl.pretty"
scene = scene or require "scene"
audioHandler = audioHandler or require "audioHandler"

transX, transY = transX, transY --To tell IntelliJ this is intentional global "creation"

local function promptPlayer(tbl)
    --TODO: Implement promptPlayer properly! I pick the first choice automatically right now!
    local choices = {}
    for k in pairs(tbl) do
        choices[#choices + 1] = k
    end
    print(choices[1])
    return choices[1]
end

local good = 0
local commands = {
    --TODO: Implement the rest of the parser commands!
    ["+1"] = function() good = good + 1 end,
    ["-1"] = function() good = good - 1 end,
    new = function() scene:clearText() scene:printText("", true) end
}

local function processVal(tbl)
    if type(tbl) == "table" then
        for i = 1, #tbl do
            local val = tbl[i]
            local t = type(val)
            if t == "string" then
                local findSpace = val:find(" ", nil, true)
                local firstChar = val:sub(1, 1)
                local firstWord = val:sub(0, findSpace and findSpace - 1 or #val)
                if firstChar == "@" then
                    local cmd = firstWord:sub(2)
                    print(("cmd=%s"):format(cmd))
                    if commands[cmd] then
                        commands[cmd]()
                    end
                elseif firstWord:lower() == "*sfx" then
                    if findSpace then
                        audioHandler.play(val:sub(findSpace + 1))
                    end
                elseif val:sub(0, 2) == "/r" then
                    transX, transY = scene:printText(val:sub(3), false, {255,0,0})
                    coroutine.yield()
                elseif #val > 0 then
                    transX, transY = scene:printText(val, false)
                    coroutine.yield()
                end
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