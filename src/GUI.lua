require "gooi"
tablex = tablex or require "pl.tablex"
audioHandler = audioHandler or require "audioHandler"
scene = scene or require "scene"

local GUI
GUI = GUI or {
    actions = {},
    currentMenu = "main",
    menus = {
        main = {
            widgets = {},
            sprites = {},
            init = function()
                local self = GUI.menus.main
                local w, h = love.graphics.getWidth(), love.graphics.getHeight()
                self.sprites.mainTitle = sprite {
                    x = 25,
                    y = 25,
                    w = love.graphics.getWidth() - 50,
                    h = love.graphics.getHeight() / 2 - 25,
                    filterMax = "linear",
                    filterMin = "linear",
                    imagePath = "assets/title.png",
                }
                self.sprites.guiHand = sprite {
                    x = love.graphics.getWidth() / 2 + 130,
                    y = love.graphics.getHeight() / 2 + 55,
                    w = 100,
                    h = 25,
                    filterMax = "linear",
                    filterMin = "linear",
                    imagePath = "assets/hand.png",
                }


                self.widgets.btnStart = gooi.newButton("Start",
                w / 2 - 100,
                h / 2 + 45,
                200,
                30)
                :onRelease(function()
                    GUI.changeMenu "game"
                    GUI.actions.showBathroom()
                end)
                :onHover(function()
                    self.sprites.guiHand.y = love.graphics.getHeight() / 2 + 55
                end)

                self.widgets.btnSettings = gooi.newButton("Settings", w / 2 - 100, h / 2 + 85, 200, 30)
                :onRelease(function()
                    GUI.changeMenu "settings"
                end)
                :onHover(function()
                    self.sprites.guiHand.y = love.graphics.getHeight() / 2 + 95
                end)

                self.widgets.btnCredits = gooi.newButton("Credits", w / 2 - 100, h / 2 + 125, 200, 30)
                :onRelease(function()
                    GUI.changeMenu "credits"
                end)
                :onHover(function()
                    self.sprites.guiHand.y = love.graphics.getHeight() / 2 + 135
                end)

                self.widgets.btnExit = gooi.newButton("Exit", w / 2 - 100, h / 2 + 165, 200, 30)
                :onRelease(function()
                    GUI.changeMenu "exit"
                end)
                :onHover(function()
                    self.sprites.guiHand.y = love.graphics.getHeight() / 2 + 175
                end)
            end,
        }, settings = {
            widgets = {},
            sprites = {},
            init = function()
                local self = GUI.menus.settings
                self.widgets.btnAirRaidSiren = gooi.newButton("Air Raid Siren", 10, 10, 150, 30)
                :onRelease(function()
                    audioHandler["air_raid_siren"]:play()
                end)
                self.widgets.btnBap1 = gooi.newButton("Bap 1", 170, 10, 150, 30)
                :onRelease(function()
                    audioHandler["bap_1"]:play()
                end)
                self.widgets.btnBap2 = gooi.newButton("Bap 2", 330, 10, 150, 30)
                :onRelease(function()
                    audioHandler["bap_2"]:play()
                end)
                self.widgets.btnBap3 = gooi.newButton("Bap 3", 490, 10, 150, 30)
                :onRelease(function()
                    audioHandler["bap_3"]:play()
                end)
                self.widgets.btnBapDistressed = gooi.newButton("Bap Distressed", 10, 50, 150, 30)
                :onRelease(function()
                    audioHandler["bap_distressed"]:play()
                end)
                self.widgets.btnFaceReassembly = gooi.newButton("Face Reassembly", 170, 50, 150, 30)
                :onRelease(function()
                    audioHandler["face_reassembly"]:play()
                end)
                self.widgets.btnGrossBlink = gooi.newButton("Gross Blink", 330, 50, 150, 30)
                :onRelease(function()
                    audioHandler["gross_blink"]:play()
                end)
                self.widgets.btnHeadBang = gooi.newButton("Head Bang", 490, 50, 150, 30)
                :onRelease(function()
                    audioHandler["head_bang"]:play()
                end)
                self.widgets.btnLick = gooi.newButton("Lick", 10, 90, 150, 30)
                :onRelease(function()
                    audioHandler["lick"]:play()
                end)
            end
        },
        exit = {
            widgets = {},
            sprites = {},
            init = function()
                if GUI.currentMenu == "exit" then
                    GUI.sprites.mainTitle.visible = false
                    GUI.sprites.guiHand.visible = false
                    local lblConfirm = suit.Label("Are you sure?", love.graphics.getWidth() / 2 - 40, 260)
                    local btnYes = suit.Button("Yes", love.graphics.getWidth() / 2 - 202, love.graphics.getHeight() / 2, 200, 30)
                    local btnNo = suit.Button("No", love.graphics.getWidth() / 2 + 2, love.graphics.getHeight() / 2, 200, 30)

                    if btnYes.hit then
                        love.event.quit()
                    end
                    if btnNo.hit then
                        GUI.changeMenu "main"
                    end
                end
            end,
        },
        back = {
            widgets = {},
            sprites = {},
            init = function(self, dt)
                if GUI.currentMenu ~= "main" and GUI.currentMenu ~= "exit" then
                    GUI.sprites.mainTitle.visible = false
                    GUI.sprites.guiHand.visible = false
                    if suit.Button("Back", 10, love.graphics.getHeight() - 42, 200, 30).hit then
                        scene.clearAll()
                        GUI.changeMenu "main"
                        currentScene = "museum"
                    end
                end
            end,
        },
        credits = {
            widgets = {},
            sprites = {},
            init = function()
                --TODO: Credits
            end
        },
        game = {
            widgets = {},
            sprites = {},
            init = function()
                --Start the game
            end
        }
    },
    update = gooi.update,
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
    end,
    changeMenu = function(menuName)
        if menuName ~= GUI.currentMenu then
            local currentMenu = GUI.menus[GUI.currentMenu]
            for _, v2 in pairs(currentMenu.sprites) do
                v2.visible = false
            end
            for _, v2 in pairs(currentMenu.widgets) do
                v2.visible = false
            end
        end
        GUI.currentMenu = menuName
        local newMenu = GUI.menus[menuName]
        assert(GUI.menus[menuName],("Menu name \"%s\" not found."):format(menuName))
        if next(newMenu.widgets) or next(newMenu.sprites) then
            for _, v in pairs(newMenu.widgets) do
                v.visible = true
            end
            for _, v in pairs(newMenu.sprites) do
                v.visible = true
            end
        else
            GUI.menus[menuName].init()
        end
    end,
    init = function()
        GUI.changeMenu(GUI.currentMenu)
    end,
    draw = gooi.draw,
    mousepressed = function()
        gooi.pressed()
    end,
    mousereleased = function()
        gooi.released()
    end,
    textinput = gooi.textinput,
    keypressed = gooi.keypressed,
    keyreleased = gooi.keyreleased,
    mousemoved = gooi.mousemoved
}

return GUI