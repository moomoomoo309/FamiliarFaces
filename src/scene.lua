sprite = sprite or require "sprite"
camera = camera or require "camera"

local font = love.graphics.getFont()
local fontHeight = font:getHeight()
local visibleText = {}
local i = 1
local defaultPaddingX, defaultPaddingY = 20, 10
local scene
local lastYOffset = 0

local function printText2(text, paddingX, paddingY, i, color)
    assert(type(text) == "string", ("String expected, got %s."):format(type(text)))
    assert(type(paddingX) == "number", ("Number expected, got %s."):format(type(paddingX)))
    assert(type(paddingY) == "number", ("Number expected, got %s."):format(type(paddingY)))
    assert(type(i) == "number", ("Number expected, got %s."):format(type(i)))
    assert(color == nil or type(color) == "table", ("Table or nil expected, got %s."):format(type(color)))
    if type(color) == "table" then
        assert(#color == 3 or #color == 4, ("Color must be of length 3 or 4, was length %d."):format(#color))
    end
    local localYOffset = (i - 1) * (fontHeight + paddingY) + paddingY
    local yOffset = 0
    if localYOffset > love.graphics.getHeight() then
        yOffset = love.graphics.getHeight() - localYOffset - fontHeight - paddingY
    end
    local textObj = love.graphics.newText(font, text)
    if color then
        textObj:addf({ color, text }, love.graphics.getWidth() - 2 * paddingX, "left", 0, 0)
    end
    textObj:setFont(font)
    local text = sprite {
        x = paddingX,
        y = localYOffset,
        w = textObj:getWidth(),
        h = textObj:getHeight(),
        group = "GUI",
        image = textObj,
        visible = true
    }
    visibleText[#visibleText + 1] = text
    return yOffset
end

scene = {
    scenes = {},
    currentScenes = {},
    printText = function(self, text, reset, color)
        --- Print the given text on the screen, moving the camera down when the text gets off screen.
        --- Make reset true to move the text back to the top of the screen.
        local yOffset
        assert(color == nil or type(color) == "table", ("Color must be nil or a table, was a %s."):format(type(color)))
        if type(color) == "table" then
            assert(#color == 3 or #color == 4, ("Color must be of length 3 or 4, had length %d."):format(#color))
        end
        if reset then
            i = 0
            yOffset = 0
        end
        yOffset = printText2(text, defaultPaddingX, defaultPaddingY, i, color)
        if yOffset ~= lastYOffset then
            camera.inst:pan(camera.inst.x, camera.inst.y + yOffset - lastYOffset, 0)
            lastYOffset = yOffset
        end
        i = i + 1
    end,
    clearText = function()
        --- Clears all visible text from printText.
        for _, v in pairs(visibleText) do
            v.visible = false --Make the sprites invisible so they disappear before garbage collection.
        end
        visibleText = {} --Release all of the references to the sprites, causing them to get collected.
    end,
    new = function(self, name)
        --- Creates a new scene.
        name = name == nil and self or name
        assert(type(name) == "string", ("String expected, got %s."):format(type(name)))
        scene.scenes[name] = scene.scenes[name] or { class = scene, name = name }
        return setmetatable(scene.scenes[name], { __index = scene.scenes[name].class })
    end,
    set = function(self, name, sceneName, sprite)
        --- Adds a sprite to the given scene.
        if not sprite then
            name, sceneName, sprite = self, name, sceneName
        end
        assert(type(name) == "string", ("Name expected, got %s."):format(type(name)))
        assert(type(sceneName) == "string", ("SceneName expected, got %s."):format(type(sceneName)))
        assert(type(sprite) == "table" and sprite.type == "sprite", ("Sprite expected, got %s."):format(type(sprite) == "table" and sprite.type or type(sprite)))
        if not scene.scenes[name] then
            scene:new(name)
        end
        scene.scenes[name][sceneName] = sprite
    end,
    clear = function(self, sceneName)
        --- Clears the scene with the given name, or self if called with a scene.
        sceneName = sceneName or self.name
        assert(sceneName, "Expected scene or scene name, got nil.")
        local thisScene = scene.scenes[sceneName]
        assert(thisScene, ("No scene with name %s found."):format(sceneName))
        if thisScene.onClear then
            thisScene:onClear()
        end
        for k, v in pairs(thisScene) do
            if type(v) == "table" and k ~= "class" then
                v.visible = false
            end
        end
        for i = 1, #scene.currentScenes do
            if scene.currentScenes[i] == thisScene then
                table.remove(scene.currentScenes, i)
                break
            end
        end
    end,
    show = function(self, sceneName)
        --- Shows the scene with the given name, or self if called with a scene.
        assert(sceneName or self ~= scene, "Name or object expected, got nil.")
        assert(type(sceneName) == "string" or sceneName == nil, ("Expected string, got %s"):format(type(sceneName)))
        scene.currentScenes[#scene.currentScenes + 1] = sceneName and scene.scenes[sceneName] or self
        local foundScene = false
        for i = 1, #scene.currentScenes do
            local currentScene = scene.scenes[scene.currentScenes[i].name]
            if currentScene.onShow then
                currentScene:onShow()
            end
            for k, v in pairs(currentScene) do
                if type(v) == "table" and k ~= "class" then
                    foundScene = true
                    v.visible = true
                end
            end
        end
        assert(foundScene, ("No scene with name %s found."):format(sceneName))
    end,
    clearAll = function()
        --- Clears all scenes.
        for _, scene in pairs(scene.currentScenes) do
            scene:clear()
        end
    end,
    visible = function()
        --- Returns which scenes are visible.
        return scene.currentScenes
    end,
    isVisible = function(self)
        --- Returns if self is visible.
        assert(self, "What are you trying to check the visibility of?")
        assert(self.name, "Self has no name.")
        assert(scene.scenes[self.name], ("No scene by the name %s exists."):format(self.name))
        for k, v in pairs(scene.scenes[self.name]) do
            assert(v, ("Scene %s contains no elements!"):format(self.name))
            if type(v) == "table" then
                return v.visible
            end
        end
    end,
    load = function(self, sceneName)
        if not sceneName then
            sceneName = self
        end
        assert(sceneName, "Cannot load scene without a name.")
        self = scene
        if not self.scenes[sceneName] then
            local sceneTbl = dofile("scenes/" .. sceneName .. ".scene")
            assert(sceneTbl, ("Could not load scene %s at scenes/%s.scene. Is the file malformed?"):format(sceneName,sceneName))
            local newScene = self:new(sceneName)
            for k, item in pairs(sceneTbl) do
                if type(item) == "table" then
                    local itemName = item.name
                    item.name = nil
                    item.visible = false
                    local itemConstructor = item.type
                    local itemSprite = itemConstructor(item)
                    newScene:set(sceneName, itemName, itemSprite)
                else
                    newScene[k] = item
                end
            end
            self.scenes[sceneName] = newScene
        end
        return self.scenes[sceneName]
    end,
    circularFadeOut = function(seconds)
        assert(type(seconds) == "number", ("Number expected, got %s."):format(type(seconds)))
        parser.lock()
        scheduler.before(seconds, function(timePassed)
            effects.vignette:set("opacity", timePassed / seconds)
            effects.vignette:set("softness", timePassed / seconds)
            effects.vignette:set("radius", 1 - timePassed / seconds)
        end)
        scheduler.after(seconds, function()
            parser.unlock()
            scene.clearAll()
            effects.vignette:set("radius", .25)
            effects.vignette:set("opacity", 0)
            effects.vignette:set("softness", .45)
        end)
    end,
    circularFadeIn = function(seconds)
        assert(type(seconds) == "number", ("Number expected, got %s."):format(type(seconds)))
        parser.lock()
        scheduler.before(seconds, function(timePassed)
            effects.vignette:set("opacity", 1 - timePassed / seconds)
            effects.vignette:set("softness", 1 - timePassed / seconds)
            effects.vignette:set("radius", timePassed / seconds)
        end)
        scheduler.after(seconds, function()
            parser.unlock()
            effects.vignette:set("radius", .25)
            effects.vignette:set("opacity", 0)
            effects.vignette:set("softness", .45)
        end)
    end,
    fadeOut = function(seconds)
        assert(type(seconds) == "number", ("Number expected, got %s."):format(type(seconds)))
        parser.lock()
        scheduler.before(seconds, function(timePassed)
            effects.vignette:set("opacity", timePassed / seconds)
        end)
        scheduler.after(seconds, function()
            parser.unlock()
            scene.clearAll()
            effects.vignette:set("radius", .25)
            effects.vignette:set("opacity", 0)
            effects.vignette:set("softness", .45)
        end)
    end,
    fadeIn = function(seconds)
        assert(type(seconds) == "number", ("Number expected, got %s."):format(type(seconds)))
        parser.lock()
        scheduler.before(seconds, function(timePassed)
            effects.vignette:set("opacity", 1 - timePassed / seconds)
        end)
        scheduler.after(seconds, function()
            parser.unlock()
            effects.vignette:set("radius", .25)
            effects.vignette:set("opacity", 0)
            effects.vignette:set("softness", .45)
        end)
    end
}

return scene