io.stdout:setvbuf "no"
--TODO: Rewrite all of the IO to use love-loader
camera = camera or require "camera"
local cam = camera:new()
cam.x = -cam.w / 2
cam.y = -cam.h / 2
scene = scene or require "scene"
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
currentScene = "museum"
local followingScene = { bathroom = "museum", museum = "elevator" }
local process
local sceneTbl
local elevatorScene
effects = {}

function love.load()
    print("w = " .. love.graphics.getWidth() .. ", h = " .. love.graphics.getHeight())

    bathroom = scene.load"bathroom"
    local elevatorTransitions
    elevatorScene = scene.load"elevator"
    elevator.init()
    local museum = scene.load"museum"
    sceneTbl = { bathroom = bathroom, elevator = elevatorScene, museum = museum }
    effects.blur = shine.boxblur()
    effects.blur.radius_v, effects.blur.radius_h = 0, 0

    effects.vignette = shine.vignette()
    effects.vignette:set("radius", .95)
    effects.vignette:set("softness", .5)
    effects.vignette:set("opacity", 0)

    effects.pause = effects.blur:chain(effects.vignette)

    GUI.startGame = function()
        bathroom:show()
        enterLocked = false
    end
    GUI.init()
end

function love.update(dt)
    GUI.update(dt)
    scheduler.update(dt)
end

local function moveNext()
    if currentScene == "museum" then
        bathroom:clear()
    end
    if lastScene then
        sceneTbl[lastScene]:clear()
    end
    sceneTbl[currentScene]:show()
    if currentScene == "elevator" then
        spaceLocked = false
        enterLocked = true
    end
    lastScene = currentScene
    currentScene = followingScene[currentScene]
end

function love.keypressed(key, scancode, isrepeat)
    print(("Key=%s"):format(key))
    if key == "return" and not enterLocked then
        moveNext()
    end
    if elevatorScene:isVisible() then
        if key == "space" and not spaceLocked then
            --spaceLocked is global because it's set in elevator.lua.
            elevator.start()
        end
    end
    if key == "right" then
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

function love.draw()
    if effects.blur.radius_h > 1.0e-6 or effects.blur.radius_v > 1.0e-6 then
        effects.pause:draw(function()
            cam:draw()
            sprite.drawGroup"default"
            love.graphics.pop() --Pops any game transformations so the GUI can be drawn normally.
        end)
    else
        cam:draw()
        sprite.drawGroup"default"
        love.graphics.pop()
    end
    GUI.draw()
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