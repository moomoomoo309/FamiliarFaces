--- A module allowing scripts of dialogue to be parsed.
--- @module parser


local scene = require "scene"
local audioHandler = require "audioHandler"
local stringx = require "pl.stringx"


local locked = true
local parser = {}

--- Prompts the player for input between dialogue options.
--- @tparam table tbl The script
--- @tparam coroutine process The coroutine the parser is running from.
--- @treturn string The choice the player picked.
local function promptPlayer(tbl, process)
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
        local btn = gooi.newButton(k):onRelease(function(self)
            choice = choices[self.text]
            clearButtons()
            coroutine.resume(process)
        end)
        btn.x = love.graphics.getWidth() / 2 - btn.w / 2
        btn.y = love.graphics.getHeight() / 2 - btn.h * 1.05 * (#buttons - #choices / 2)
        buttons[#buttons + 1] = btn
    end
    repeat
        coroutine.yield() -- Until a choice is picked, don't go back to processVal.
    until choice
    return choice
end

--- Contains all commands recognized by the parser.
--- @see processLine
local commands = {
    new = function()
        scene:clearText()
        scene:printText("", true)
    end, --- Clears the screen of text.
    sfx = function(val)
        --parser.lock()
        audioHandler.play(val:sub(6) --[[, parser.unlock]])
    end, --- Plays the sound with the given name.
    ["end"] = function()
        --TODO: Implement end command
    end, --- Ends the game.
    scene = function(scenes)
        scenes = stringx.split(scenes:sub(8), ",")
        scene:clearAll()
        for i = 1, #scenes do
            scene.show(scenes[i])
        end
    end, --- Switches to the given scene(s).
    store = function(val, tbl)
        local varName, value = unpack(stringx.split(val, " "))
        tbl.vars[varName] = tonumber(value) or value
    end, --- Stores the given value at the given name, coercing it to a number if possible.
    add = function(val, tbl)
        local varName, value = unpack(stringx.split(val, " "))
        value = tonumber(value)
        assert(varName, "You need a value to add to!")
        assert(value, "You need a number to add to the value.")
        assert(tbl.vars[varName], ("No variable with the name %s found."):format(varName))
        tbl.vars[varName] = tbl.vars[varName] + value
    end, --- Adds to the given variable name the given amount.
    subtract = function(val, tbl)
        local varName, value = unpack(stringx.split(val, " "))
        assert(varName, "You need a value to subtract from!")
        assert(value, "You need a number to subtract from the value.")
        assert(tbl.vars[varName], ("No variable with the name %s found."):format(varName))
        tbl.vars[varName] = tbl.vars[varName] - value
    end, --- Subtracts from the given variable name the given amount.
    auto = function(val, tbl)
        parser.processLine(val:sub(7), false, true)
    end --- Processes the line, but does not yield.
}

--- Contains any prefixes recognized by the parser.
--- @see processLine
local prefixes = {
    ["/r"] = function(val, _, noYield)
        assert(type(val) == "string", ("String expected, got %s."):format(type(val)))
        scene:printText(val:sub(3), false, { 255, 0, 0 })
        if not noYield then
            coroutine.yield()
        end
    end,
    ["/t{"] = function(val, _, noYield)
        local findClosingBrace = val:find("}", 4, true)
        assert(findClosingBrace, "The color table must be closed with a closing brace!")
        local color = stringx.split(val:sub(3, val:find("}", 4, true)), ",")
        assert(type(color) == "table", ("Table expected, got %s."):format(type(color)))
        assert(#color == 3 or #color == 4, ("Length of color table must be 3 or 4, was %d."):format(#color))
        scene:printText(val:sub(findClosingBrace + 1), false, color)
        if not noYield then
            coroutine.yield()
        end
    end,
    ["/t#"] = function(val, _, noYield)
        local color = tonumber("0x" .. val:sub(4, 12))
        local alpha = color and true or false
        color = color or tonumber("0x" .. val:sub(4, 10))
        assert(color, ("Could not parse #%s as hex string"):format(val:sub(4, (alpha and 12 or 10))))
        scene:printText(val:sub(alpha and 12 or 10), false, { tonumber("0x" .. val:sub(4, 6)), tonumber("0x" .. val:sub(6, 8)), tonumber("0x" .. val:sub(8, 10)), alpha and tonumber("0x" .. val:sub(10, 12)) or nil })
        if not noYield then
            coroutine.yield()
        end
    end,
    ["@"] = function(val, tbl, noYield)
        local findSpace = val:find(" ", nil, true)
        local firstWord = val:sub(1, findSpace and findSpace - 1 or #val)
        local cmd = firstWord:sub(2):lower()
        assert(commands[cmd], ("Unrecognized command: \"%s\" from string \"%s\""):format(cmd, val))
        commands[cmd](val, tbl, noYield)
    end
}

--- Processes a string from the script.
--- @tparam string val The string to process
--- @tparam table tbl The table containing the script.
--- @tparam boolean noYield Makes the coroutine not yield, so it processes another line.
--- @return nil
function parser.processLine(val, tbl, noYield)
    assert(type(val) == "string", ("Expected string, got %s."):format(type(val)))
    local prefixed = false
    for k, v in pairs(prefixes) do
        if val:sub(1, #k) == k then
            v(val, tbl, noYield)
            prefixed = true
            break
        end
    end
    if not prefixed then
        --No prefix was recognized, so just put the text on the screen.
        scene:printText(val, false)
        if not noYield then
            coroutine.yield()
        end
    end
end

--- Processes the next value in the script.
--- @tparam table tbl The script.
--- @tparam coroutine process The coroutine the parser is being run from.
--- @tparam boolean noYield Makes the coroutine not yield, so it processes another line.
--- @return nil
function parser.processVal(tbl, process, noYield)
    if type(tbl) == "table" then
        tbl.vars = tbl.vars or {}
        for i = 1, #tbl do
            local val = tbl[i]
            local t = type(val)
            if t == "string" then
                parser.processLine(val, tbl, noYield)
            elseif t == "table" then
                parser.processVal(promptPlayer(val, process), process, noYield)
            elseif t == "function" then
                parser.processVal(val(val, tbl), process, noYield)
            end
        end
    end
end

--- Locks the parser.
--- @return nil
function parser.lock()
    locked = true
end

--- Unlocks the parser.
--- @return nil
function parser.unlock()
    locked = false
end

--- Returns whether the parser is locked or not.
--- @return Whether the parser is locked or not.
function parser.locked()
    return locked
end

--- Processes the file at the given path using require(). Returns a coroutine to the parser and the table it's reading from, or false if it is unsuccessful.
--- @tparam string path The path to the file to parse.
--- @treturn coroutine,table|false A coroutine to the parser and the table it's reading from, or false if it is unsuccessful.
function parser.process(path)
    local processTbl = require(path)
    if type(processTbl) == "table" then
        return coroutine.create(parser.processVal), processTbl
    else
        return false
    end
end

return parser