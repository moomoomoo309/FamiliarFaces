--- The script that runs the game.
--- @script main

io.stdout:setvbuf "no"
local camera = require "camera"
local cam = camera()
cam.x = -cam.w / 2
cam.y = -cam.h / 2
loadingAssets = true
loadingCallbacks = {}

local parser = require "parser"
local scene = require "scene"
local loader = require "love-loader.love-loader"
local sprite = require "sprite"
elevator = require "elevator"
local GUI = require "GUI"
local baton = require "baton.baton"
local scheduler = require "scheduler"
local shine = require "shine"

local lastScene
local enterLocked = true
local currentScene = "bathroom"
local followingScene = { bathroom = "museum", museum = "elevator" }
local process
local sceneTbl
local elevatorScene
player = nil
script = nil
effects = {}

local defaultControls = {
    advanceScript = { "key:right", "button:a" },
    moveRight = { "key:right", "key:d", "button:dpright", "axis:leftx+" },
    moveLeft = { "key:left", "key:a", "button:dpleft", "axis:leftx-" },
    moveElevator = { "key:space", --[["key:return",]] "button:a" },
    pause = { "key:escape", "button:start" }
}

function love.load()
    --Load scenes
    local bathroom = scene.load "bathroom"
    elevatorScene = scene.load "elevator"
    local museum = scene.load "museum"
    sceneTbl = { bathroom = bathroom, elevator = elevatorScene, museum = museum }

    --Initialize post-processing effects
    effects.blur = shine.boxblur()
    effects.blur.radius_v, effects.blur.radius_h = 0, 0
    effects.vignette = shine.vignette()
    effects.vignette.opacity = 0
    effects.desaturate = shine.desaturate()
    effects.pause = effects.desaturate:chain(effects.blur):chain(effects.vignette)

    --Tell the GUI how to start the game
    GUI.startGame = function()
        bathroom:show()
        enterLocked = false
        parser.unlock()
    end

    love.graphics.setNewFont(36)
    loader.start(function()
        loadingAssets = false
        for _, v in pairs(loadingCallbacks) do
            v()
        end
        loadingCallbacks = nil
        --Initialize the GUI
        GUI.init()
    end)
    --Set up the controls
    player = baton.new(defaultControls, love.joystick.getJoysticks()[1])
end

local function moveNext()
    --Advance the scene
    lastScene = currentScene
    currentScene = followingScene[currentScene]
    if not currentScene then --Prevent the game from crashing
        return
    end

    --Clear the old scene
    if lastScene then
        sceneTbl[lastScene]:clear()
    end

    --Show the new scene
    sceneTbl[currentScene]:show()
end

local function checkControls()
    if player:pressed "pause" then
        if GUI.paused() then
            GUI.unpause()
        else
            GUI.pause()
        end
    end
    if not GUI.paused() then
        if elevatorScene:isVisible() then
            if player:pressed "moveElevator" and not elevator.locked() then
                elevator.start()
            end
        end
        if player:pressed "advanceScript" then
            if not process then
                process, script = parser.process "Script"
            end
            if not parser.locked() then
                if coroutine.status(process) ~= "dead" then
                    local success, msg = coroutine.resume(process, script, process)
                    if not success then
                        print(msg)
                    end
                else
                    print "ded"
                end
            end
        end
    end
end

function love.update(dt)
    if loadingAssets then
        loader.update(dt)
    end
    player:update(dt)
    scheduler.update(dt)
    GUI.update(dt)
    checkControls()
end

function love.keypressed(key, scancode, isrepeat)
    print(("Key=%s"):format(key))
    GUI.keypressed(key, scancode, isrepeat)
    if not GUI.paused() and key == "return" and not enterLocked then
        moveNext()
    end
end

local function drawGame()
    cam:draw() --Push game transformations using the camera
    sprite.drawGroup "default" --Draw all of the normal sprites.
    love.graphics.pop() --Pops any game transformations so the GUI can be drawn normally.
end

function love.draw()
    if loadingAssets then
        local w, h = love.graphics.getWidth(), love.graphics.getHeight()
        local percentLoaded = loader.loadedCount / loader.resourceCount
        local r, g, b = love.graphics.getColor()
        love.graphics.printf("Loading...", w * .1, h * .375, w * .9, "left")
        love.graphics.printf(("%d%%"):format(percentLoaded * 100), 0, h * .375, w * .9, "right")
        love.graphics.setColor(128, 128, 128)
        love.graphics.rectangle("fill", w * .1, h * .45, w * .8, h * .1)
        --A scissor is used here so the rectangle could easily be replaced with an image.
        love.graphics.setScissor(w * .11, h * .465, w * .78 * percentLoaded, h * .0725)

        --TODO: Replace the rectangle with something better
        love.graphics.setColor(255, 0, 0)
        love.graphics.rectangle("fill", w * .11, h * .465, w * .78, h * .0725)
        love.graphics.setColor(r, g, b)

        love.graphics.setScissor()
    else
        if effects.blur.radius_h > 0 or effects.blur.radius_v > 0 then
            effects.pause:draw(drawGame)
        elseif effects.vignette.opacity > 0 then
            effects.vignette:draw(drawGame)
        else
            drawGame()
        end
        GUI.draw()
    end
end

function love.mousepressed(x, y, button)
    GUI.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    GUI.mousereleased(x, y, button)
end

function love.textinput(text)
    GUI.textinput(text)
end

function love.mousemoved(x, y)
    GUI.mousemoved(x, y)
end