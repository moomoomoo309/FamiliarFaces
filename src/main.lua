io.stdout:setvbuf "no"

camera = camera or require "camera"
suit = require "suit"
scene = scene or require "scene"
scenes = scenes or require "scenes"
sprite = sprite or require "sprite"
tablex = tablex or require "tablex"
pretty = pretty or require "pretty"
parser = parser or require "parser"
elevator = elevator or require "elevator"
audioHandler = audioHandler or require "audioHandler"
GUI = GUI or require "GUI"
functools = functools or require "functools"

local mainTitle
local guiHand

local bathroom
local building
local museum

local lastScene
local enterLocked = true
currentScene = "museum"
local followingScene = { bathroom = "museum", museum = "building" }
local process
local sceneTbl
updateFunctions = {}
transX, transY = 0, 0
local cam = camera:new{
    w=love.graphics.getWidth(),
    h=love.graphics.getHeight(),
}
cam.x = -cam.w/2
cam.y = -cam.h/2


function love.load()
    print("w = " .. love.graphics.getWidth() .. ", h = " .. love.graphics.getHeight())

    suit.theme.color = {
        normal = { bg = { 140, 145, 145, 170 }, fg = { 255, 255, 255 } },
        hovered = { bg = { 160, 160, 160 }, fg = { 255, 255, 255 } },
        active = { bg = { 80, 80, 80 }, fg = { 225, 225, 225 } }
    }

    bathroom = scenes:bathroom()
    local buildingTransitions
    building, buildingTransitions = scenes:building()
    elevator.init(building, buildingTransitions)
    museum = scenes:museum()
    sceneTbl = { bathroom = bathroom, building = building, museum = museum }

    mainTitle = sprite {
        x = 25,
        y = 25,
        w = 750,
        h = 300,
        imagePath = "assets/title.png",
        flipHorizontal = false
    }
    guiHand = sprite {
        x = love.graphics.getWidth() / 2 + 130,
        y = love.graphics.getHeight() / 2 + 55,
        w = 100,
        h = 25,
        imagePath = "assets/hand.png",
        flipHorizontal = false,
    }
    GUI.addSprites { mainTitle = mainTitle, guiHand = guiHand }
    GUI.actions.showBathroom = function()
        bathroom:show()
        enterLocked = false
    end
    GUI.actions.clearBathroom = functools.partial(bathroom.clear, bathroom)
end

function love.update(dt)
    cam:update()
    GUI.update(dt)

    for _, v in pairs(updateFunctions) do
        v(dt)
    end
end

local function moveNext()
    if currentScene == "museum" then
        bathroom:clear()
    end
    if lastScene then
        sceneTbl[lastScene]:clear()
    end
    sceneTbl[currentScene]:show()
    if currentScene == "building" then
        spaceLocked = false
        enterLocked = true
    end
    lastScene = currentScene
    currentScene = followingScene[currentScene]
end

function love.keypressed(key, scancode, isrepeat)
    --    print(("Key=%s"):format(key))
    if key == "return" and not enterLocked then
        moveNext()
    end
    if building:isVisible() then
        if key == "space" and not spaceLocked then
            --It's global because it's set in elevator.lua.
            elevator.start()
        end
    end
    if key == "right" then
        local tbl
        if not process then
            process, tbl = parser.process "Script"
        end
        if coroutine.status(process) ~= "dead" then
            print(coroutine.resume(process, tbl))
        else
            print "ded"
        end
    end
end

function love.draw()
    cam:draw()
    sprite:drawAll()
    love.graphics.pop()
    suit.draw()
end
