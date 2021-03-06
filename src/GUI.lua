---The class handling all parts of the GUI.
--- @classmod GUI

require "gooi"
local gooi = gooi
local audioHandler = require "audioHandler"
local scene = require "scene"
local scheduler = require "scheduler"
local parser = require "parser"
local sprite = require "sprite"

component.style.bgColor = { 140, 145, 145, 170 }

local GUI

--TODO: Settings Menu
local paused = false
local cancelPause
local borderX, borderY = 10, 10
local btnWidth, btnHeight = 185, 30
local btnBack = gooi.newButton("Back", borderX, love.graphics.getHeight() - borderY - btnHeight, btnWidth, btnHeight):onRelease(function()
    GUI.changeMenu "main"
end)
btnBack.visible = false

GUI = GUI or {
    currentMenu = "main",
    menus = {
        main = {
            widgets = {},
            assets = {},
            init = function(self)
                if next(GUI.menus.main.widgets) then
                    return
                end
                local font = love.graphics.newFont(love.window.fromPixels(24))
                local w, h = love.graphics.getDimensions()
                local btnWidth, btnHeight = 400, 55
                local oldStyle = component.style
                gooi.setStyle { font = font }
                self.assets.mainTitle = sprite {
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
                    btnHeight):onRelease(function()
                    GUI.changeMenu "game"
                    GUI.startGame()
                end):onHover(function()
                    self.assets.guiHand.x = self.widgets.btnStart.x + self.widgets.btnStart.w + borderX
                    self.assets.guiHand.y = self.widgets.btnStart.y
                end)

                self.widgets.btnSoundboard = gooi.newButton("Soundboard",
                    w / 2 - btnWidth / 2,
                    h / 2 + btnHeight + borderY * 3,
                    btnWidth,
                    btnHeight):onRelease(function()
                    GUI.changeMenu "soundboard"
                end):onHover(function()
                    self.assets.guiHand.x = self.widgets.btnSoundboard.x + self.widgets.btnSoundboard.w + borderX
                    self.assets.guiHand.y = self.widgets.btnSoundboard.y
                end)

                self.widgets.btnCredits = gooi.newButton("Credits",
                    w / 2 - btnWidth / 2,
                    h / 2 + btnHeight * 2 + borderY * 4,
                    btnWidth,
                    btnHeight):onRelease(function()
                    GUI.changeMenu "credits"
                end):onHover(function()
                    self.assets.guiHand.x = self.widgets.btnCredits.x + self.widgets.btnCredits.w + borderX
                    self.assets.guiHand.y = self.widgets.btnCredits.y
                end)

                self.widgets.btnExit = gooi.newButton("Exit",
                    w / 2 - btnWidth / 2,
                    h / 2 + btnHeight * 3 + borderY * 5,
                    btnWidth,
                    btnHeight):onRelease(function()
                    gooi.setStyle { font = font }
                    gooi.confirm("Are you sure?", love.event.quit, function()
                        gooi.setStyle(oldStyle)
                    end)
                end):onHover(function()
                    self.assets.guiHand.x = self.widgets.btnExit.x + self.widgets.btnStart.w + borderX
                    self.assets.guiHand.y = self.widgets.btnExit.y
                end)
                self.assets.guiHand = sprite {
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
            end
        },
        soundboard = {
            widgets = {},
            assets = {},
            init = function(self)
                if next(GUI.menus.soundboard.widgets) then
                    return
                end
                self.widgets.btnAirRaidSiren = gooi.newButton("Air Raid Siren", borderX, borderY, btnWidth, btnHeight):onRelease(function()
                    audioHandler.play "air_raid_siren"
                end)
                self.widgets.btnBap1 = gooi.newButton("Bap 1", borderX * 2 + btnWidth, borderY, btnWidth, btnHeight):onRelease(function()
                    audioHandler.play "bap_1"
                end)
                self.widgets.btnBap2 = gooi.newButton("Bap 2", borderX * 3 + btnWidth * 2, borderY, btnWidth, btnHeight):onRelease(function()
                    audioHandler.play "bap_2"
                end)
                self.widgets.btnBap3 = gooi.newButton("Bap 3", borderX * 4 + btnWidth * 3, borderY, btnWidth, btnHeight):onRelease(function()
                    audioHandler.play "bap_3"
                end)
                self.widgets.btnBapDistressed = gooi.newButton("Bap Distressed", borderX, borderY * 2 + btnHeight, btnWidth, btnHeight):onRelease(function()
                    audioHandler.play "bap_distressed"
                end)
                self.widgets.btnFaceReassembly = gooi.newButton("Face Reassembly", borderX * 2 + btnWidth, borderY * 2 + btnHeight, btnWidth, btnHeight):onRelease(function()
                    audioHandler.play "face_reassembly"
                end)
                self.widgets.btnGrossBlink = gooi.newButton("Gross Blink", borderX * 3 + btnWidth * 2, borderY * 2 + btnHeight, btnWidth, btnHeight):onRelease(function()
                    audioHandler.play "gross_blink"
                end)
                self.widgets.btnHeadBang = gooi.newButton("Head Bang", borderX * 4 + btnWidth * 3, borderY * 2 + btnHeight, btnWidth, btnHeight):onRelease(function()
                    audioHandler.play "head_bang"
                end)
                self.widgets.btnLick = gooi.newButton("Lick", borderX, borderY * 3 + btnHeight * 2, btnWidth, btnHeight):onRelease(function()
                    audioHandler.play "lick"
                end)
                self.widgets.btnBack = btnBack
                btnBack.visible = true
            end
        },
        credits = {
            widgets = {},
            assets = {},
            init = function(self)
                if next(GUI.menus.credits.widgets) then
                    return
                end
                --TODO: Credits
                self.widgets.btnBack = btnBack
                btnBack.visible = true
            end
        },
        game = {
            widgets = {},
            assets = {},
            init = function()
            end
        },
        pause = {
            widgets = {},
            assets = {},
            init = function(self)
                if next(GUI.menus.pause.widgets) then
                    return
                end
                local w, h = love.graphics.getDimensions()
                local btnWidth, btnHeight = w * .8, h * .075
                local font = love.graphics.newFont(love.window.toPixels(24))
                local oldStyle = component.style
                gooi.setStyle { font = font }
                self.widgets.btnResume = gooi.newButton("Resume", w * .1, h * .35, btnWidth, btnHeight):onRelease(GUI.unpause)
                self.widgets.btnSettings = gooi.newButton("Settings", w * .1, h * .45, btnWidth, btnHeight):onRelease(function()
                    GUI.changeMenu "settings"
                end)
                self.widgets.btnQuit = gooi.newButton("Quit", w * .1, h * .55, btnWidth, btnHeight):onRelease(function()
                    GUI.changeMenu "main"
                    scene.clearAll()
                    GUI.unpause()
                    parser.lock()
                    scene.clearText()
                end)
                gooi.setStyle(oldStyle)
            end
        },
        settings = {
            widgets = {},
            assets = {},
            init = function(self)
                if next(GUI.menus.settings.widgets) then
                    return
                end
                local w, h = love.graphics.getDimensions()
            end
        }
    }
}

--- Updates the GUI.
--- @return nil
GUI.update = gooi.update

--- Adds a menu with the passed values and the given name.
--- @tparam table menu A table containing an init function, widgets, and any assets needed by the GUI.
--- @tparam string name The name of the menu.
--- @return nil
function GUI.addMenu(menu, name)
    assert(type(menu) == "table", ("Table expected, got %s."):format(type(menu)))
    assert(type(name) == "string", ("String expected, got %s."):format(type(name)))
    if GUI.menus[name] then
        print(("Warning: Overriding menu \"%s\"!"):format(name))
    end
    GUI.menus[name] = menu
end

--- Shows the menu with the given name.
--- @tparam string menuName The name of the menu to show.
--- @return nil
function GUI.showMenu(menuName)
    local newMenu = GUI.menus[menuName]
    assert(newMenu, ("Menu name \"%s\" not found."):format(menuName))
    if next(newMenu.widgets) then
        for _, v in pairs(newMenu.widgets) do
            v.visible = true
        end
    end
    if next(newMenu.assets) then
        for _, v in pairs(newMenu.assets) do
            v.visible = true
        end
    else
        newMenu:init()
    end
end

--- Hides the menu with the given name.
--- @tparam string menuName The name of the menu to hide.
--- @return nil
function GUI.hideMenu(menuName)
    assert(type(menuName) == "string", ("String expected, got %s."):format(menuName))
    local currentMenu = GUI.menus[menuName]
    assert(currentMenu, ("No menu with name %s found."):format(menuName))
    for _, v in pairs(currentMenu.widgets) do
        v.visible = false
    end
    for _, v in pairs(currentMenu.assets) do
        v.visible = false
    end
end

--- Changes the visible menu to the one with the given name. Do not use this to switch to the pause menu, use pause or unpause.
--- @tparam string menuName The name of the menu to switch to.
--- @return nil
function GUI.changeMenu(menuName)
    assert(menuName ~= "pause", "Cannot switch to the pause menu via changeMenu! Use pause or unpause instead!")
    GUI.hideMenu(GUI.currentMenu)
    GUI.currentMenu = menuName
    GUI.showMenu(menuName)
end

--- Initializes the GUI, loading any necessary assets.
--- @return nil
function GUI.init()
    for k, v in pairs(GUI.menus) do
        v:init()
        GUI.hideMenu(k)
    end
    GUI.changeMenu(GUI.currentMenu)
end

--- Pauses the game.
--- @return nil
function GUI.pause()
    if GUI.currentMenu == "game" then
        GUI.showMenu "pause"
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
        function GUI.cancelPause()
            cancelFct1()
            cancelFct2()
        end

        scheduler.pause "default"
        scheduler.pause "camera"
        audioHandler.pauseAll()
    end
end

--- Unpauses the game.
--- @return nil
function GUI.unpause()
    GUI.hideMenu "pause"
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
    scheduler.resume "default"
    scheduler.resume "camera"
    audioHandler.resumeAll()
end

--- Returns if the game is paused or not.
--- @treturn boolean If the game is paused or not.
function GUI.paused()
    return paused
end

--- Draws all GUI-related assets, and the GUI itself.
--- @return nil
function GUI.draw()
    sprite.drawGroup "GUI"
    gooi.draw()
end

--- Passes mousepressed events to gooi.
--- @return nil
function GUI.mousepressed()
    gooi.pressed()
end

--- Passes mousereleased events to gooi.
--- @return nil
function GUI.mousereleased()
    gooi.released()
end

--- Starts the game. Gets overridden in main.
--- @return nil
function GUI.startGame()
    error "GUI.startGame is undefined!"
end

--- Passes textinput events to gooi.
--- @return nil
GUI.textinput = gooi.textinput

--- Passes keypressed events to gooi.
--- @return nil
GUI.keypressed = gooi.keypressed

--- Passes mousemoved events to gooi.
--- @return nil
GUI.mousemoved = gooi.mousemoved


return GUI