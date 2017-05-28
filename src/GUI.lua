tablex = tablex or require "pl.tablex"
audioHandler = audioHandler or require "audioHandler"
scene = scene or require "scene"

local GUI
GUI = GUI or {
    actions = {},
    state = "main",
    menus = {
        mainMenu = function(self, dt)
            if GUI.state == "main" then
                GUI.sprites.mainTitle.visible = true
                GUI.sprites.guiHand.visible = true

                local btnStart = suit.Button("Start", love.graphics.getWidth() / 2 - 100, love.graphics.getHeight() / 2 + 45, 200, 30)
                local btnSettings = suit.Button("Settings", love.graphics.getWidth() / 2 - 100, love.graphics.getHeight() / 2 + 85, 200, 30)
                local btnCredits = suit.Button("Credits", love.graphics.getWidth() / 2 - 100, love.graphics.getHeight() / 2 + 125, 200, 30)
                local btnExit = suit.Button("Exit", love.graphics.getWidth() / 2 - 100, love.graphics.getHeight() / 2 + 165, 200, 30)

                if btnStart.hit then
                    GUI.state = "start"
                    GUI.actions.showBathroom()
                end
                if btnSettings.hit then
                    GUI.state = "settings"
                end
                if btnCredits.hit then
                    GUI.state = "credits"
                end
                if btnExit.hit then
                    GUI.state = "exit"
                end

                if btnStart.hovered then
                    GUI.sprites.guiHand.y = love.graphics.getHeight() / 2 + 55
                elseif btnSettings.hovered then
                    GUI.sprites.guiHand.y = love.graphics.getHeight() / 2 + 95
                elseif btnCredits.hovered then
                    GUI.sprites.guiHand.y = love.graphics.getHeight() / 2 + 135
                elseif btnExit.hovered then
                    GUI.sprites.guiHand.y = love.graphics.getHeight() / 2 + 175
                end
            end
        end,
        settingsMenu = function(self, dt)
            if GUI.state == "settings" then
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
        exitPrompt = function(self, dt)
            if GUI.state == "exit" then
                GUI.sprites.mainTitle.visible = false
                GUI.sprites.guiHand.visible = false
                local lblConfirm = suit.Label("Are you sure?", love.graphics.getWidth() / 2 - 40, 260)
                local btnYes = suit.Button("Yes", love.graphics.getWidth() / 2 - 202, love.graphics.getHeight() / 2, 200, 30)
                local btnNo = suit.Button("No", love.graphics.getWidth() / 2 + 2, love.graphics.getHeight() / 2, 200, 30)

                if btnYes.hit then
                    love.event.quit()
                end
                if btnNo.hit then
                    GUI.state = "main"
                end
            end
        end,
        backMenu = function(self, dt)
            if GUI.state ~= "main" and GUI.state ~= "exit" then
                GUI.sprites.mainTitle.visible = false
                GUI.sprites.guiHand.visible = false
                if suit.Button("Back", 10, love.graphics.getHeight() - 42, 200, 30).hit then
                    scene.clearAll()
                    GUI.state = "main"
                    currentScene = "museum"
                end
            end
        end,
    },
    update = function(dt)
        for _, v in pairs(GUI.menus) do
            v(dt)
        end
    end,
    addSprites = function(sprites)
        GUI.sprites = tablex.merge(sprites, GUI.sprites or {}, true)
    end,
    addMenu = function(menu, name)
        if type(menu) == "function" then
            if GUI.menus[name] then
                print(("Warning: Overriding menu \"%s\"!"):format(name))
            end
            GUI.menus[name] = menu
        end
    end
}

return GUI