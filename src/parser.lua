utils = utils or require "pl.utils"
map = map or require "map"
pretty = pretty or require "pl.pretty"
scene = scene or require "scene"
audioHandler = audioHandler or require "audioHandler"
stringx = stringx or require "pl.stringx"

local function promptPlayer(tbl, process)
    --TODO: Implement promptPlayer properly! I pick the first choice automatically right now!
    local choices = {}
    for k, v in pairs(tbl) do
        if v then
            choices[k] = v
        end
    end
    local buttons = {}
    local function clearButtons()
        for i = 1, #buttons do
            buttons[i].visible = false
            buttons[i] = nil
        end
        buttons = nil
    end
    local choice
    for k in pairs(choices) do
        buttons[#buttons + 1] = gooi.newButton(k,
        love.graphics.getWidth() / 2 - 50,
        love.graphics.getHeight() / 2 - 10 - 25 * (#buttons - #choices / 2),
        100,
        20)
        :onRelease(function(self)
            choice = choices[self.text]
            clearButtons()
            coroutine.resume(process)
        end)
    end
    repeat
        coroutine.yield() -- Until a choice is picked, don't go back to processVal.
    until choice
    return choice
end

local commands = {
    --TODO: Implement the rest of the parser commands!
    new = function()
        scene:clearText()
        scene:printText("", true)
    end,
    sfx = function(val)
        audioHandler.play(val:sub(5))
    end,
    ["end"] = function()
        --TODO: Implement end command
    end
}

local prefixes = {
    ["/r"] = function(val)
        scene:printText(val:sub(3), false, { 255, 0, 0 })
        coroutine.yield()
    end,
    ["@"] = function(val, tbl)
        local findSpace = val:find(" ", nil, true)
        local firstWord = val:sub(1, findSpace and findSpace - 1 or #val)
        local cmd = firstWord:sub(2):lower()
        print(("cmd=%s"):format(cmd))
        if commands[cmd] then
            commands[cmd](val, tbl)
        end
    end
}

local function processVal(tbl, process)
    pretty.dump(tbl)
    if type(tbl) == "table" then
        tbl.vars = tbl.vars or {}
        for i = 1, #tbl do
            local val = tbl[i]
            local t = type(val)
            if t == "string" then
                local prefixed = false
                for k, v in pairs(prefixes) do
                    if val:sub(1, #k) == k then
                        v(val, tbl)
                        prefixed = true
                        break
                    end
                end
                if not prefixed then
                    --No prefix was recognized, so just put the text on the screen.
                    scene:printText(val, false)
                    coroutine.yield()
                end
            elseif t == "table" then
                processVal(promptPlayer(val, process), process)
            elseif t == "function" then
                processVal(val(val, tbl), process)
            end
        end
    end
end

local process = function(path, process)
    local processTbl = require(path)
    if type(processTbl) == "table" then
        return coroutine.create(processVal), processTbl
    else
        return false
    end
end

return { process = process }