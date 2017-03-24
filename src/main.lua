io.stdout:setvbuf "no"

suit = require "suit"
scene = scene or require "scene"
sprite = sprite or require "sprite"
tablex = tablex or require "tablex"
pretty = pretty or require "pretty"
parser = parser or require "parser"
elevator = elevator or require "elevator"
audioHandler = audioHandler or require "audioHandler"

local state = "main"
local mainTitle
local guiHand
local testSprite
local sinkBack

local bathroom
local building
local museum

local extLight
local lastScene
local enterLocked = true
local currentScene = "museum"
local followingScene = { bathroom = "museum", museum = "building" }
local process
local sceneTbl
transX, transY = 0, 0

local Menu = {
    checkMain = function(self, dt)
        if state == "main" then
            mainTitle.visible = true
            guiHand.visible = true

            local btnStart = suit.Button("Start", transX + love.graphics.getWidth() / 2 - 100, love.graphics.getHeight() / 2 + 45, 200, 30)
            local btnSettings = suit.Button("Settings", transX + love.graphics.getWidth() / 2 - 100, transY + love.graphics.getHeight() / 2 + 85, 200, 30)
            local btnCredits = suit.Button("Credits", transX + love.graphics.getWidth() / 2 - 100, transY + love.graphics.getHeight() / 2 + 125, 200, 30)
            local btnExit = suit.Button("Exit", transX + love.graphics.getWidth() / 2 - 100, transY + love.graphics.getHeight() / 2 + 165, 200, 30)

            if btnStart.hit then
                state = "start"
                bathroom:show()
                enterLocked = false
            end
            if btnSettings.hit then
                state = "settings"
            end
            if btnCredits.hit then
                state = "credits"
            end
            if btnExit.hit then
                state = "exit"
            end

            if btnStart.hovered then
                guiHand.y = love.graphics.getHeight() / 2 + 55 + transY
            elseif btnSettings.hovered then
                guiHand.y = love.graphics.getHeight() / 2 + 95 + transY
            elseif btnCredits.hovered then
                guiHand.y = love.graphics.getHeight() / 2 + 135 + transY
            elseif btnExit.hovered then
                guiHand.y = love.graphics.getHeight() / 2 + 175 + transY
            end
        end
    end,
    checkSettings = function(self, dt)
        if state == "settings" then
            local btnAirRaidSiren = suit.Button("Air Raid Siren", 10, 10, 150, 30)
            local btnBap1 = suit.Button("Bap 1", 170, 10, 150, 30)
            local btnBap2 = suit.Button("Bap 2", 330, 10, 150, 30)
            local btnBap3 = suit.Button("Bap 3", 490, 10, 150, 30)
            local btnBapDistressed = suit.Button("Bap Distressed", 10, 50, 150, 30)
            local btnFaceReassembly = suit.Button("Face Reassembly", 170, 50, 150, 30)
            local btnGrossBlink = suit.Button("Gross Blink", 330, 50, 150, 30)
            local btnHeadBang = suit.Button("Head Bang", 490, 50, 150, 30)
            local btnLick = suit.Button("Lick", 10, 90, 150, 30)

            if btnAirRaidSiren.hit then
                audioHandler["air_raid_siren"]:play()
            end
            if btnBap1.hit then
                audioHandler["bap_1"]:play()
            end
            if btnBap2.hit then
                audioHandler["bap_2"]:play()
            end
            if btnBap3.hit then
                audioHandler["bap_3"]:play()
            end
            if btnBapDistressed.hit then
                audioHandler["bap_distressed"]:play()
            end
            if btnFaceReassembly.hit then
                audioHandler["face_reassembly"]:play()
            end
            if btnGrossBlink.hit then
                audioHandler["gross_blink"]:play()
            end
            if btnHeadBang.hit then
                audioHandler["head_bang"]:play()
            end
            if btnLick.hit then
                audioHandler["Lick"]:play()
            end
        end
    end,
    checkExit = function(self, dt)
        if state == "exit" then
            mainTitle.visible = false
            guiHand.visible = false
            local lblConfirm = suit.Label("Are you sure?", transX + love.graphics.getWidth() / 2 - 40, transY + 260)
            local btnYes = suit.Button("Yes", transX + love.graphics.getWidth() / 2 - 202, transY + love.graphics.getHeight() / 2, 200, 30)
            local btnNo = suit.Button("No", transX + love.graphics.getWidth() / 2 + 2, transY + love.graphics.getHeight() / 2, 200, 30)

            if btnYes.hit then
                love.event.quit()
            end
            if btnNo.hit then
                state = "main"
            end
        end
    end,
    checkBack = function(self, dt)
        if state ~= "main" and state ~= "exit" then
            mainTitle.visible = false
            guiHand.visible = false
            if suit.Button("Back", 10, love.graphics.getHeight() - 42, 200, 30).hit then
                bathroom:clear()
                state = "main"
            end
        end
    end
}

local Scenes = {
    bathroom = function(self)
        scene:new "bathroom"
        scene:add("bathroom", "SinkBackground", sprite {
            w = 800,
            h = 600,
            imagePath = "SinkBackground.png",
            visible = false
        })
        scene:add("bathroom", "Character", sprite {
            x = love.graphics.getWidth() / 2 - 280,
            w = 510,
            h = 740,
            imagePath = "mc.png",
            visible = false
        })
        scene:add("bathroom", "Sink", sprite {
            w = 800,
            h = 600,
            imagePath = "Sink.png",
            visible = false
        })
        return setmetatable(scene.scenes.bathroom, { __index = scenes })
    end,
    museum = function(self)
        scene:new "museum"
        scene:add("museum", "appleGuy", sprite {
            x = love.graphics.getWidth() / 2 - 130,
            y = love.graphics.getHeight() / 2 - 100,
            w = 275,
            h = 220,
            imagePath = "museum_apple_guy.png",
            visible = false
        })
        scene:add("museum", "Museum", sprite {
            w = 800,
            h = 600,
            imagePath = "Museum.png",
            visible = false
        })
        return setmetatable(scenes.scenes.museum, { __index = scenes })
    end,
    building = function(self)
        scene:new "building"
        scene:add("building", "building", sprite {
            x = -700 - 26,
            y = -4500,
            w = 2460,
            h = 5120,
            imagePath = "OfficeExterior.png",
            visible = false
        })
        extLight = sprite {
            x = -33,
            y = 260,
            w = 450,
            h = 280,
            imagePath = "OfficeElevatorLighting.png",
            visible = false
        }
        scene:add("building", "ExteriorLight", sprite {
            x = -102,
            y = 340,
            w = 520,
            h = 400,
            imagePath = "OfficeEntranceLighting.png",
            visible = false
        })
        scene:add("building", "ElevatorLight", extLight)
        return setmetatable(scenes.scenes.building, { __index = scenes }), {
            { 0, -80 },
            { 0, -80 },
            { 0, -80 },
            { 0, -80 },
            { 0, -80 },
            { 0, -80 },
            { 0, -80 },
            { 0, -80 },
            { 0, -80 },
            { 0, -80 },
            { 0, -80 },
            { 0, -80 },
            { 69, 41 },
            "flipHorizontal",
            { 520, 0 },
            { 69, -40 },
            { 70, -41 },
            { 69, -40 },
            { 70, -41 },
            { 69, -40 },
            { 69, -40 },
            { 69, -40 },
            { 70, -41 },
            { 69, -40 },
            { 0, -79 },
            { 0, -80 },
            { 0, -80 },
            { 0, -80 },
            { -69, 40 },
            { -70, 41 },
            { 0, -80 },
            { 0, -80 },
            { 0, -80 },
            { 0, -80 },
            { 0, -80 },
            { 0, -80 },
            { -69, 40 },
            { -70, 41 },
            "flipHorizontal",
            { -520, 0 },
            { -69, -40 },
            { -69, -40 },
            { 0, -80 },
            { 0, -80 },
            { -69, -40 },
            { -69, -40 },
            { -69, -40 },
            { 0, 80 },
            { 0, 80 },
            { -70, -41 },
            { -70, -40 },
            { -69, -40 },
            { 0, -80 },
            { 0, -80 },
            { 0, -80 },
            { 0, -80 },
            { 0, -80 },
            { 69, 40 },
            "flipHorizontal",
            { 520, 0 },
            { 70, -40 },
            { 69, -40 },
            { 69, -40 },
            { 69, -40 },
            { 0, -80 },
            { 0, -80 },
            { 0, -80 },
            { -70, 40 },
            { -69, 40 },
            { -69, 40 },
            { 0, -80 },
            { 0, -80 },
            { 70, -40 },
            { 69, -40 },
            { 0, -80 },
            { 0, -80 },
            { -70, 41 },
            { -70, 40 },
            { -69, 40 },
            { -69, 40 },
            { -69, 40 },
            { -69, 120 },
            { -69, 40 },
            { -70, 40 },
            { 0, -80 },
            { 0, -80 },
            { 0, -80 },
            { 0, -80 },
            { 0, -80 },
            { 70, -40 },
            { 69, -40 },
            { 0, -80 },
            { 0, -80 },
            { 0, -80 },
            { 0, -80 },
            { -69, 40 },
            { -70, 40 },
            "flipHorizontal",
            { -519, -1 },
            { 0, -80 },
            { 0, -80 },
            { 0, -80 },
            "flipHorizontal",
            { 520, 0 },
            { 70, -40 },
            { 0, -80 },
            { 0, -80 },
            { 0, -80 },
            { -69, 40 },
            "flipHorizontal",
            { -520, 0 },
            { 0, -80 },
            { 0, -80 },
            "flipHorizontal",
            { 520, 0 },
            { 69, -40 },
            { 0, -80 },
            { 0, -80 },
            { 0, -80 },
        }
    end
}

function love.load()
    print("w = " .. love.graphics.getWidth() .. ", h = " .. love.graphics.getHeight())

    suit.theme.color = {
        normal = { bg = { 140, 145, 145, 170 }, fg = { 255, 255, 255 } },
        hovered = { bg = { 160, 160, 160 }, fg = { 255, 255, 255 } },
        active = { bg = { 80, 80, 80 }, fg = { 225, 225, 225 } }
    }

    bathroom = Scenes:bathroom()
    local buildingTransitions
    building, buildingTransitions = Scenes:building()
    elevator.init(building, buildingTransitions)
    museum = Scenes:museum()
    sceneTbl = { bathroom = bathroom, building = building, museum = museum }

    mainTitle = sprite { x = 25, y = 25, w = 750, h = 300, imagePath = "title.png", flipHorizontal = false }
    guiHand = sprite { x = love.graphics.getWidth() / 2 + 130, y = love.graphics.getHeight() / 2 + 55, w = 100, h = 25, imagePath = "hand.png", flipHorizontal = false }
end

function love.update(dt)
    Menu:checkMain(dt)
    Menu:checkSettings(dt)
    Menu:checkExit(dt)
    Menu:checkBack(dt)

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
        if key == "space" and not spaceLocked then --It's global because it's set in elevator.lua.
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
    love.graphics.translate(transX, transY + yOffset)
    sprite:drawSprites()
    suit.draw()
end
