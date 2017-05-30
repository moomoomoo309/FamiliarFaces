utils = utils or require "pl.utils"
map = map or require "map"
pretty = pretty or require "pl.pretty"
scene = scene or require "scene"
audioHandler = audioHandler or require "audioHandler"
stringx = stringx or require "pl.stringx"

local function promptPlayer(tbl)
    --TODO: Implement promptPlayer properly! I pick the first choice automatically right now!
    local choices = {}
    for k in pairs(tbl) do
        choices[#choices + 1] = k
    end
    print(choices[1])
    return choices[1]
end

local commands = {
    --TODO: Implement the rest of the parser commands!
    ["+"] = function(val, tbl)
        local args = stringx.split(val:sub(3))
        assert(#args==2, ("+ requires two arguments, got %d."):format(#args))
        tbl.vars = tbl.vars or {}
        tbl.vars[args[2]] = tbl.vars[args[2]] and tbl.vars[args[2]] + tonumber(args[1]) or tonumber(args[1])
    end,
    ["-"] = function(val, tbl)
        local args = stringx.split(val:sub(3))
        assert(#args==2, ("- requires two arguments, got %d."):format(#args))
        tbl.vars = tbl.vars or {}
        tbl.vars[args[2]] = tbl.vars[args[2]] and tbl.vars[args[2]] - tonumber(args[1]) or -tonumber(args[1])
    end,
    ["/"] = function(val, tbl)
        local args = stringx.split(val:sub(3))
        assert(#args==2, ("/ requires two arguments, got %d."):format(#args))
        tbl.vars = tbl.vars or {}
        tbl.vars[args[2]] = tbl.vars[args[2]] and tbl.vars[args[2]] / tonumber(args[1]) or 0
    end,
    ["*"] = function(val, tbl)
        local args = stringx.split(val:sub(3))
        assert(#args==2, ("* requires two arguments, got %d."):format(#args))
        tbl.vars = tbl.vars or {}
        tbl.vars[args[2]] = tbl.vars[args[2]] and tbl.vars[args[2]] * tonumber(args[1]) or 0
    end,
    ["%"] = function(val, tbl)
        local args = stringx.split(val:sub(3))
        assert(#args==2, ("% requires two arguments, got %d."):format(#args))
        tbl.vars = tbl.vars or {}
        tbl.vars[args[2]] = tbl.vars[args[2]] and tbl.vars[args[2]] % tonumber(args[1]) or 0
    end,
    new = function()
        scene:clearText()
        scene:printText("", true)
    end,
    sfx = function(val)
        audioHandler.play(val:sub(5))
    end
}

local prefixes = {
    ["/r"] = function(val)
        scene:printText(val:sub(3), false, { 255, 0, 0 })
        coroutine.yield()
    end,
    ["@"] = function(val, tbl)
        local findSpace = val:find(" ", nil, true)
        local cmd = firstWord:sub(2, findSpace - 1):lower()
        print(("cmd=%s"):format(cmd))
        if commands[cmd] then
            commands[cmd](val, tbl)
        end
    end
}

local function processVal(tbl)
    if type(tbl) == "table" then
        for i = 1, #tbl do
            local val = tbl[i]
            local t = type(val)
            if t == "string" then
                for k, v in pairs(prefixes) do
                    if val:sub(1,#k) == k then
                        v(val, tbl)
                    end
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