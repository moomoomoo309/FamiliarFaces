io.stdout:setvbuf "no"

suit = require "suit"
scene = scenes or require "scenes"
sprite = sprite or require "sprite"
animation = animation or require "animation"
tablex = tablex or require "tablex"
pretty = pretty or require "pretty"
parser = parser or require "parser"

local width = love.graphics.getWidth
local height = love.graphics.getHeight

local state = "main"
local mainTitle
local guiHand
local testSprite
local sinkBack

local bathroom
local building
local museum

local extLight
local updateFunctions = {}
local transitions = {
    12,
    1,
    10,
    4,
    2,
    6,
    2,
    3,
    2,
    3,
    2,
    3,
    5,
    1,
    5,
    3,
    3,
    2,
    2,
    2,
    8,
    5,
    2,
    4,
    3,
    3,
    1,
    1,
    3,
    1,
    1,
    2,
    1,
    1,
    3,
    3
}
local buildingTranslations
local camIndex = 1
local deltaX, deltaY = 0, 0
local i = 1
local stopElevatorLight
local t
local currentTransition = {}
local transitionIndex = 1
local nextTarget
local spaceLocked = false
local nextDelta = 0
local lastScene, enterLocked
local currentScene = "museum"
local followingScene = { bathroom = "museum", museum = "building" }
local previousScene = { building = "museum", museum = "bathroom" }
local process
local sceneTbl
transX, transY = 0, 0


local sndBnk = {}

local snd = {
    ["air_raid_siren"] = ".wav",
    ["bap_1"] = ".wav",
    ["bap_2"] = ".wav",
    ["bap_3"] = ".wav",
    ["bap_distressed"] = ".wav",
    ["face_reassembly"] = ".wav",
    ["gross_blink"] = ".mp3",
    ["head_bang"] = ".mp3",
    ["Lick"] = ".mp3"
}

for k, v in pairs(snd) do
    sndBnk[k] = love.audio.newSource(k .. v, "static")
end

local Menu = {
    checkMain = function(self, dt)
        if state == "main" then
            mainTitle.visible = true
            guiHand.visible = true

            local btnStart = suit.Button("Start", transX + width() / 2 - 100, height() / 2 + 45, 200, 30)
            local btnSettings = suit.Button("Settings", transX + width() / 2 - 100, transY + height() / 2 + 85, 200, 30)
            local btnCredits = suit.Button("Credits", transX + width() / 2 - 100, transY + height() / 2 + 125, 200, 30)
            local btnExit = suit.Button("Exit", transX + width() / 2 - 100, transY + height() / 2 + 165, 200, 30)

            if btnStart.hit then
                state = "start"
                bathroom:show()
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
                guiHand.y = height() / 2 + 55 + transY
            elseif btnSettings.hovered then
                guiHand.y = height() / 2 + 95 + transY
            elseif btnCredits.hovered then
                guiHand.y = height() / 2 + 135 + transY
            elseif btnExit.hovered then
                guiHand.y = height() / 2 + 175 + transY
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
                sndBnk["air_raid_siren"]:play()
            end
            if btnBap1.hit then
                sndBnk["bap_1"]:play()
            end
            if btnBap2.hit then
                sndBnk["bap_2"]:play()
            end
            if btnBap3.hit then
                sndBnk["bap_3"]:play()
            end
            if btnBapDistressed.hit then
                sndBnk["bap_distressed"]:play()
            end
            if btnFaceReassembly.hit then
                sndBnk["face_reassembly"]:play()
            end
            if btnGrossBlink.hit then
                sndBnk["gross_blink"]:play()
            end
            if btnHeadBang.hit then
                sndBnk["head_bang"]:play()
            end
            if btnLick.hit then
                sndBnk["Lick"]:play()
            end
        end
    end,
    checkExit = function(self, dt)
        if state == "exit" then
            mainTitle.visible = false
            guiHand.visible = false
            local lblConfirm = suit.Label("Are you sure?", transX + width() / 2 - 40, transY + 260)
            local btnYes = suit.Button("Yes", transX + width() / 2 - 202, transY + height() / 2, 200, 30)
            local btnNo = suit.Button("No", transX + width() / 2 + 2, transY + height() / 2, 200, 30)

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
            if suit.Button("Back", 10, height() - 42, 200, 30).hit then
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
            x = width() / 2 - 280,
            w = 510,
            h = 740,
            imagePath = "mc13.png",
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
            x = width() / 2 - 130,
            y = height() / 2 - 100,
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

local function lerp(start, stop, percent)
    return (stop - start) * math.min(0, math.max(percent, 1)) + start
end

local function cerp(start, stop, percent)
    local f = (1 - math.cos(percent * math.pi)) * .5
    return start * (1 - f) + stop * f
end

local function moveElevatorLight()
    if type(buildingTranslations[i]) == "table" then
        extLight.x = extLight.x + buildingTranslations[i][1]
        extLight.y = extLight.y + buildingTranslations[i][2]
    elseif buildingTranslations[i] == "flipHorizontal" then
        extLight.flipHorizontal = not extLight.flipHorizontal
        i = i + 1
        extLight.x = extLight.x + buildingTranslations[i][1]
        extLight.y = extLight.y + buildingTranslations[i][2]
    end
    i = i + 1
end

local function elevatorRise(dt)
    if #currentTransition > 0 then
        transX = currentTransition[1] + cerp(currentTransition[1], currentTransition[2], t) - currentTransition[2]
        transY = currentTransition[3] + cerp(currentTransition[3], currentTransition[4], t) - currentTransition[4]
        local currNumSteps = -(currentTransition[5] - 1) * (currentTransition[2] - currentTransition[1] > 0 and (transX - currentTransition[1]) / (currentTransition[2] - currentTransition[1]) or (transY - currentTransition[3]) / (currentTransition[4] - currentTransition[3]))
        if currNumSteps >= nextTarget and currNumSteps ~= 0 then
            moveElevatorLight()
            nextTarget = nextTarget + 1
        end
        t = t - dt / currentTransition[6]
        if t <= 0 then
            t = 1
            moveElevatorLight()
            stopElevatorLight()
        end
    end
end

function stopElevatorLight()
    spaceLocked = transitionIndex >= #transitions
    for k, v in pairs(updateFunctions) do
        if v == elevatorRise then
            table.remove(updateFunctions, k)
        end
    end
    camIndex = camIndex + currentTransition[5]
    transitionIndex = transitionIndex + 1
    currentTransition = {}
end

local function startElevatorLight()
    spaceLocked = true
    if transitionIndex >= #transitions then
        return
    end
    deltaX, deltaY = nextDelta, 0
    nextDelta = 0
    local i = camIndex
    local offset = 0
    while true do
        if buildingTranslations[i] == "flipHorizontal" then
            if transitionIndex == 25 or transitionIndex == 30 then
                deltaX = deltaX + (extLight.flipHorizontal and 520 or -520)
            end
            if i - camIndex <= 3 then
                print((extLight.flipHorizontal and 520 or -520))
                nextDelta = extLight.flipHorizontal and 520 or -520
            end
            if i == camIndex + transitions[transitionIndex] + offset then
                camIndex = camIndex + 1
                break
            end
            i = i + 1
            offset = offset + 1
        end
        deltaX = deltaX + buildingTranslations[i][1]
        deltaY = deltaY + buildingTranslations[i][2]
        if i == camIndex + transitions[transitionIndex] + offset then
            deltaX = deltaX - buildingTranslations[i][1]
            deltaY = deltaY - buildingTranslations[i][2]
            break
        end
        i = i + 1
    end
    updateFunctions[#updateFunctions + 1] = elevatorRise
    currentTransition = { transX, transX + deltaX, transY, transY + deltaY, transitions[transitionIndex], .25 + transitions[transitionIndex] / 8 }
    nextTarget = 0
    t = 1
end

function love.load()
    print("w = " .. width() .. ", h = " .. height())

    suit.theme.color = {
        normal = { bg = { 140, 145, 145, 170 }, fg = { 255, 255, 255 } },
        hovered = { bg = { 160, 160, 160 }, fg = { 255, 255, 255 } },
        active = { bg = { 80, 80, 80 }, fg = { 225, 225, 225 } }
    }

    bathroom = Scenes:bathroom()
    building, buildingTranslations = Scenes:building()
    museum = Scenes:museum()
    sceneTbl = { bathroom = bathroom, building = building, museum = museum }

    mainTitle = sprite { x = 25, y = 25, w = 750, h = 300, imagePath = "title.png", flipHorizontal = false }
    guiHand = sprite { x = width() / 2 + 130, y = height() / 2 + 55, w = 100, h = 25, imagePath = "hand.png", flipHorizontal = false }
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
        scene[lastScene]:clear()
    end
    scene[currentScene]:show()
    if currentScene == "building" then
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
    if building:visible() then
        if key == "space" and not spaceLocked then
            startElevatorLight()
        end
    end
    if key == "right" then
        local tbl
        if not process then
            process, tbl = parser.process "Script" --proc is there because otherwise, tbl wouldn't be local.
        end
        if coroutine.status(process) ~= "dead" then
            print(coroutine.resume(process, tbl))
        else
            print "ded"
        end
    end
end

function love.draw()
    love.graphics.translate(transX, transY)
    sprite:drawSprites()
    suit.draw()
end
