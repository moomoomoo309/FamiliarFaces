io.stdout:setvbuf "no"
--TODO: Rewrite all of the IO to use love-loader
camera = camera or require "camera"
local cam = camera:new()
cam.x = -cam.w / 2
cam.y = -cam.h / 2
loadingAssets = true
loadingCallbacks = {}
local loadingProgress = 0
scene = scene or require "scene"
loader = loader or require"love-loader.love-loader"
sprite = sprite or require "sprite"
tablex = tablex or require "tablex"
pretty = pretty or require "pretty"
parser = parser or require "parser"
elevator = elevator or require "elevator"
audioHandler = audioHandler or require "audioHandler"
GUI = GUI or require "GUI"
baton = baton or require "baton.baton"
scheduler = scheduler or require "scheduler"
shine = shine or require "shine"

local lastScene
local enterLocked = true
local currentScene = "bathroom"
local followingScene = { bathroom = "museum", museum = "elevator" }
local process
local sceneTbl
local elevatorScene
effects = {}

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
    effects.desaturate = shine.desaturate()
    effects.pause = effects.desaturate:chain(effects.blur):chain(effects.vignette)

    --Tell the GUI how to start the game
    GUI.startGame = function()
        bathroom:show()
        enterLocked = false
    end

    loader.start(function()
        loadingAssets = false
        for _,v in pairs(loadingCallbacks) do
            v()
        end
        --Initialize the GUI
        GUI.init()
    end)
end

function love.update(dt)
    if loadingAssets then
        loader.update(dt)
    end
    scheduler.update(dt)
    GUI.update(dt)
end

local function moveNext()
    --Advance the scene
    lastScene = currentScene
    currentScene = followingScene[currentScene]

    --Clear the old scene
    if lastScene then
        sceneTbl[lastScene]:clear()
    end

    --Show the new scene
    sceneTbl[currentScene]:show()

    --If you switched to the elevator, unlock the spacebar so you can move the elevator.
    if currentScene == "elevator" then
        elevator.unlock()
    end
end

function love.keypressed(key, scancode, isrepeat)
    --TODO: Move controls into baton
    print(("Key=%s"):format(key))
    if not GUI.paused() and key == "return" and not enterLocked then
        moveNext()
    end
    if not GUI.paused() and elevatorScene:isVisible() then
        --spaceLocked is global because it's set in elevator.lua.
        if key == "space" and not elevator.locked() then
            elevator.start()
        end
    end
    if not GUI.paused() and key == "right" then
        local tbl
        if not process then
            process, tbl = parser.process "Script"
        end
        if not parser.locked() then
            if coroutine.status(process) ~= "dead" then
                local msg = coroutine.resume(process, tbl, process)
                if msg ~= true then
                    print(msg)
                end
            else
                print "ded"
            end
        end
    elseif key == "escape" then
        if GUI.paused() then
            GUI.unpause()
        else
            GUI.pause()
        end
    end
    GUI.keypressed(key, scancode, isrepeat)
end

local function drawGame()
    cam:draw() --Push game transformations using the camera
    sprite.drawGroup "default" --Draw all of the normal sprites.
    love.graphics.pop() --Pops any game transformations so the GUI can be drawn normally.
end

function love.draw()
    if loadingAssets then
        local w,h = love.graphics.getWidth(), love.graphics.getHeight()
        local percentLoaded = loader.loadedCount / loader.resourceCount
        local r,g,b,a = love.graphics.getColor()
        love.graphics.setColor(128,128,128,255)
        love.graphics.rectangle("fill",w*.1,h*.45,w*.8, h*.1)
        love.graphics.setColor(255,0,0,255)
        love.graphics.rectangle("fill",w*.1125,h*.4625,w*.75*percentLoaded,h*.0775)
        love.graphics.setColor(r,g,b,a)
    else
        if effects.blur.radius_h > 0 or effects.blur.radius_v > 0 then
            effects.pause:draw(drawGame)
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