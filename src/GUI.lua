require "gooi"
tablex = tablex or require "pl.tablex"
audioHandler = audioHandler or require "audioHandler"
scene = scene or require "scene"
scheduler = scheduler or require "scheduler"

component.style.bgColor = { 140, 145, 145, 170 }

--TODO: Settings Menu
local paused = false
local cancelPause
local borderX, borderY = 10, 10
local btnWidth, btnHeight = 185, 30
local btnBack = gooi.newButton("Back", borderX, love.graphics.getHeight() - borderY - btnHeight, btnWidth, btnHeight)
:onRelease(function()
    GUI.changeMenu "main"
end)
btnBack.visible = false

local GUI
GUI = GUI or {
    currentMenu = "main",
    menus = {
        main = {
            widgets = {},
            sprites = {},
            init = function(self)
                local font = love.graphics.newFont(love.window.toPixels(24))
                local w, h = love.graphics.getWidth(), love.graphics.getHeight()
                local btnWidth, btnHeight = 400, 55
                local oldStyle = component.style
                gooi.setStyle{ font = font }
                self.sprites.mainTitle = sprite {
                    x = borderX,
                    y = borderY,
                    w = w - 2 * borderX,
                    h = h / 2 - borderY,
                    filterMax = "linear",
                    filterMin = "linear",
                    imagePath = "assets/title.png",
                    group = "GUI"
                }
                self.widgets.btnStart = gooi.newButton("Start",
                w / 2 - btnWidth / 2,
                h / 2 + borderY * 2,
                btnWidth,
                btnHeight)
                :onRelease(function()
                    GUI.changeMenu "game"
                    GUI.startGame()
                end)
                :onHover(function()
                    self.sprites.guiHand.x = self.widgets.btnStart.x + self.widgets.btnStart.w + borderX
                    self.sprites.guiHand.y = self.widgets.btnStart.y
                end)

                self.widgets.btnSoundboard = gooi.newButton(
                "Soundboard",
                w / 2 - btnWidth / 2,
                h / 2 + btnHeight + borderY * 3,
                btnWidth,
                btnHeight)
                :onRelease(function()
                    GUI.changeMenu "soundboard"
                end)
                :onHover(function()
                    self.sprites.guiHand.x = self.widgets.btnSoundboard.x + self.widgets.btnSoundboard.w + borderX
                    self.sprites.guiHand.y = self.widgets.btnSoundboard.y
                end)

                self.widgets.btnCredits = gooi.newButton(
                "Credits",
                w / 2 - btnWidth / 2,
                h / 2 + btnHeight * 2 + borderY * 4,
                btnWidth,
                btnHeight)
                :onRelease(function()
                    GUI.changeMenu "credits"
                end)
                :onHover(function()
                    self.sprites.guiHand.x = self.widgets.btnCredits.x + self.widgets.btnCredits.w + borderX
                    self.sprites.guiHand.y = self.widgets.btnCredits.y
                end)

                self.widgets.btnExit = gooi.newButton(
                "Exit",
                w / 2 - btnWidth / 2,
                h / 2 + btnHeight * 3 + borderY * 5,
                btnWidth,
                btnHeight)
                :onRelease(function()
                    gooi.confirm("Are you sure?", love.event.quit)
                end)
                :onHover(function()
                    self.sprites.guiHand.x = self.widgets.btnExit.x + self.widgets.btnStart.w + borderX
                    self.sprites.guiHand.y = self.widgets.btnExit.y
                end)
                self.sprites.guiHand = sprite {
                    x = self.widgets.btnStart.x + self.widgets.btnStart.w + borderX,
                    y = self.widgets.btnStart.y,
                    w = (w - btnWidth) / 2,
                    h = btnHeight + borderY / 2,
                    filterMax = "linear",
                    filterMin = "linear",
                    imagePath = "assets/hand.png",
                    group = "GUI"
                }
                gooi.setStyle(oldStyle)
            end,
        }, soundboard = {
            widgets = {},
            sprites = {},
            init = function(self)
                self.widgets.btnAirRaidSiren = gooi.newButton("Air Raid Siren", borderX, borderY, btnWidth, btnHeight)
                :onRelease(function()
                    audioHandler.play "air_raid_siren"
                end)
                self.widgets.btnBap1 = gooi.newButton("Bap 1", borderX * 2 + btnWidth, borderY, btnWidth, btnHeight)
                :onRelease(function()
                    audioHandler.play "bap_1"
                end)
                self.widgets.btnBap2 = gooi.newButton("Bap 2", borderX * 3 + btnWidth * 2, borderY, btnWidth, btnHeight)
                :onRelease(function()
                    audioHandler.play "bap_2"
                end)
                self.widgets.btnBap3 = gooi.newButton("Bap 3", borderX * 4 + btnWidth * 3, borderY, btnWidth, btnHeight)
                :onRelease(function()
                    audioHandler.play "bap_3"
                end)
                self.widgets.btnBapDistressed = gooi.newButton("Bap Distressed", borderX, borderY * 2 + btnHeight, btnWidth, btnHeight)
                :onRelease(function()
                    audioHandler.play "bap_distressed"
                end)
                self.widgets.btnFaceReassembly = gooi.newButton("Face Reassembly", borderX * 2 + btnWidth, borderY * 2 + btnHeight, btnWidth, btnHeight)
                :onRelease(function()
                    audioHandler.play "face_reassembly"
                end)
                self.widgets.btnGrossBlink = gooi.newButton("Gross Blink", borderX * 3 + btnWidth * 2, borderY * 2 + btnHeight, btnWidth, btnHeight)
                :onRelease(function()
                    audioHandler.play "gross_blink"
                end)
                self.widgets.btnHeadBang = gooi.newButton("Head Bang", borderX * 4 + btnWidth * 3, borderY * 2 + btnHeight, btnWidth, btnHeight)
                :onRelease(function()
                    audioHandler.play "head_bang"
                end)
                self.widgets.btnLick = gooi.newButton("Lick", borderX, borderY * 3 + btnHeight * 2, btnWidth, btnHeight)
                :onRelease(function()
                    audioHandler.play "lick"
                end)
                self.widgets.btnBack = btnBack
                btnBack.visible = true
            end
        },
        credits = {
            widgets = {},
            sprites = {},
            init = function(self)
                --TODO: Credits
                self.widgets.btnBack = btnBack
                btnBack.visible = true
            end
        },
        game = {
            widgets = {},
            sprites = {},
            init = function()
            end
        },
        pause = {
            widgets = {},
            sprites = {},
            init = function(self)
                local w, h = love.graphics.getWidth(), love.graphics.getHeight()
                local btnWidth, btnHeight = w*.8, h*.075
                local font = love.graphics.newFont(love.window.toPixels(24))
                local oldStyle = component.style
                gooi.setStyle{ font = font }
                self.widgets.btnResume = gooi.newButton("Resume", w*.1, h*.35, btnWidth, btnHeight)
                :onRelease(GUI.unpause)
                self.widgets.btnSettings = gooi.newButton("Settings", w*.1, h*.45, btnWidth, btnHeight)
                :onRelease(function()
                    GUI.changeMenu"settings"
                end)
                self.widgets.btnQuit = gooi.newButton("Quit", w*.1, h*.55, btnWidth, btnHeight)
                :onRelease(function()
                    GUI.changeMenu"main"
                    scene.clearAll()
                    GUI.unpause()
                end)
                gooi.setStyle(oldStyle)
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
    showMenu = function(menuName)
        local newMenu = GUI.menus[menuName]
        assert(newMenu, ("Menu name \"%s\" not found."):format(menuName))
        if next(newMenu.widgets) or next(newMenu.sprites) then
            for _, v in pairs(newMenu.widgets) do
                v.visible = true
            end
            for _, v in pairs(newMenu.sprites) do
                v.visible = true
            end
        else
            newMenu:init()
        end
    end,
    hideMenu = function(menuName)
        local currentMenu = GUI.menus[menuName]
        for _, v2 in pairs(currentMenu.widgets) do
            v2.visible = false
        end
        for _, v2 in pairs(currentMenu.sprites) do
            v2.visible = false
        end
    end,
    changeMenu = function(menuName)
        if menuName == "pause" then
            error("Cannot switch to the pause menu via changeMenu! Use pause or unpause instead!")
        end
        GUI.hideMenu(GUI.currentMenu)
        GUI.currentMenu = menuName
        GUI.showMenu(menuName)
    end,
    init = function()
        for k,v in pairs(GUI.menus) do
            v:init()
            GUI.hideMenu(k)
        end
        GUI.changeMenu(GUI.currentMenu)
    end,
    pause = function()
        if GUI.currentMenu == "game" then
            GUI.showMenu"pause"
            paused = true
            local blurTime = .25
            local blurRadius = 5
            local cancelFct1, cancelFct2
            cancelFct1 = scheduler.before(blurTime, function(timeElapsed)
                local percentProgress = timeElapsed / blurTime
                effects.blur:set("radius_h", blurRadius * percentProgress)
                effects.blur:set("radius_v", blurRadius * percentProgress)
                effects.vignette:set("opacity", percentProgress)
                effects.desaturate:set("strength", percentProgress / 4)
            end, nil, "GUI")
            cancelFct2 = scheduler.after(blurTime, function()
                effects.blur:set("radius_h", blurRadius)
                effects.blur:set("radius_v", blurRadius)
                effects.vignette:set("opacity", 1)
                effects.desaturate:set("strength", .25)
            end, "GUI")
            cancelPause = function()
                cancelFct1()
                cancelFct2()
            end
            scheduler.pause"default"
            scheduler.pause"camera"
        end
    end,
    unpause = function()
        GUI.hideMenu"pause"
        paused = false
        if type(cancelPause) == "function" then
            cancelPause()
        end
        local blurTime = .1
        local blurRadius = 5
        scheduler.before(blurTime, function(timeElapsed)
            local percentProgress = 1 - timeElapsed / blurTime
            effects.blur:set("radius_h", blurRadius * percentProgress)
            effects.blur:set("radius_v", blurRadius * percentProgress)
            effects.vignette:set("opacity", percentProgress)
            effects.desaturate:set("strength", percentProgress / 4)
        end, nil, "GUI")
        scheduler.after(blurTime, function()
            effects.blur:set("radius_h", 0)
            effects.blur:set("radius_v", 0)
            effects.vignette:set("opacity", 0)
            effects.desaturate:set("strength", 0)
        end, "GUI")
        scheduler.resume"default"
        scheduler.resume"camera"
    end,
    paused = function()
        return paused
    end,
    draw = function()
        sprite.drawGroup"GUI"
        gooi.draw()
    end,
    mousepressed = function()
        gooi.pressed()
    end,
    mousereleased = function()
        gooi.released()
    end,
    startGame = function()
        error"GUI.startGame is undefined!"
    end,
    textinput = gooi.textinput,
    keypressed = gooi.keypressed,
    mousemoved = gooi.mousemoved
}

return GUI