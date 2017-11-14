--- A module designed to show multiple sprites or UI elements at once.
--- @classmod scene

local scheduler = require "scheduler"
local camera = require "camera"
local parser = parser --Circular dependencies!
local sprite = require "sprite"

local font = love.graphics.getFont()
local fontHeight = font:getHeight()
local visibleText = {}
local i = 1
local defaultPaddingX, defaultPaddingY = 20, 10
local lastYOffset = 0

--- The internal function used by printText to write to the screen.
--- @tparam string text The text to write to the screen.
--- @tparam number paddingX How many pixels from the left/right side should be left by the text.
--- @tparam number paddingY How many pixels from the top/bottom side should be left by the text.
--- @tparam number i Which row the text should be on (1-however many fit on the screen)
--- @tparam table|nil color (Optional) What color the text should be. Defaults to white.
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
    local textDrawable = love.graphics.newText(font, text)
    if color then
        textDrawable:addf({ color, text }, love.graphics.getWidth() - 2 * paddingX, "left", 0, 0)
    end
    textDrawable:setFont(font)
    local textSprite = sprite {
        x = paddingX,
        y = localYOffset,
        w = textDrawable:getWidth(),
        h = textDrawable:getHeight(),
        group = "GUI",
        image = textDrawable,
        visible = true
    }
    visibleText[#visibleText + 1] = textSprite
    return yOffset
end

local scene = { scenes = {}, currentScenes = {} }

--- Print the given text on the screen, moving the camera down when the text gets off screen.
--- Make reset true to move the text back to the top of the screen.
--- @param _ unused
--- @tparam string text The text to print on screen
--- @tparam boolean|nil reset (Optional) If true, will reset the text back to the top of the screen.
--- @tparam table|nil color (Optional) The color to make the text. White by default.
--- @return nil
function scene.printText(_, text, reset, color)
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
end

--- Clears all visible text from printText.
--- @return nil
function scene.clearText()
    for _, v in pairs(visibleText) do
        v.visible = false --Make the sprites invisible so they disappear before garbage collection.
    end
    visibleText = {} --Release all of the references to the sprites, causing them to get collected.
end

--- Creates a new scene.
--- @tparam string name the name of the new scene
--- @return nil
function scene:new(name)
    name = name == nil and self or name
    assert(type(name) == "string", ("String expected, got %s."):format(type(name)))
    scene.scenes[name] = scene.scenes[name] or { class = scene, name = name }
    return setmetatable(scene.scenes[name], { __index = scene.scenes[name].class })
end

--- Sets a value to the given scene.
--- @tparam string sceneName The name of the scene to set the sprite to.
--- @tparam string spriteName The name of the sprite within the scene.
--- @tparam any value The value to insert into the scene.
--- @return nil
function scene:set(sceneName, spriteName, value)
    if not sprite then
        sceneName, spriteName, value = self, sceneName, spriteName
    end
    sceneName = type(sceneName) == "table" and sceneName.name or sceneName
    assert(type(sceneName) == "string", ("Name expected, got %s."):format(type(sceneName)))
    assert(type(spriteName) == "string", ("spriteName expected, got %s."):format(type(spriteName)))
    if not scene.scenes[sceneName] then
        scene:new(sceneName)
    end
    scene.scenes[sceneName][spriteName] = value
end

--- Clears the scene with the given name, or self if called with a scene.
--- @tparam string|nil sceneName (Optional) The name of the scene, if a reference to the scene is not available.
--- @return nil
function scene:clear(sceneName)
    sceneName = sceneName or self.name
    assert(sceneName, "Expected scene or scene name, got nil.")
    local thisScene = scene.scenes[sceneName]
    assert(thisScene, ("No scene with name %s found."):format(sceneName))
    if thisScene.onClear then
        thisScene:onClear(scene)
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
end

--- Shows the scene with the given name, or self if called with a scene.
--- @tparam string sceneName The name of the scene, if a reference to the scene is not available.
--- @return nil
function scene.show(sceneName)
    assert(type(sceneName) == "string" or type(sceneName) == "table", ("String or table expected, got %s"):format(type(sceneName)))
    sceneName = type(sceneName) == "string" and sceneName or sceneName.name
    scene.currentScenes[#scene.currentScenes + 1] = type(sceneName) == "string" and scene.scenes[sceneName] or sceneName
    local foundScene = false
    for i = 1, #scene.currentScenes do
        local currentScene = scene.scenes[scene.currentScenes[i].name]
        print(scene.currentScenes[i].name)
        if currentScene.onShow then
            currentScene:onShow(scene)
        end
        for k, v in pairs(currentScene) do
            if type(v) == "table" and k ~= "class" then
                foundScene = true
                v.visible = true
            end
        end
    end
    assert(foundScene, ("No scene with name %s found."):format(sceneName))
end

--- Returns the scene with the given name, or errors if there is not one.
--- @tparam string sceneName The name of the scene.
--- @return table The scene with the given name.
function scene.get(sceneName)
    assert(type(sceneName) == "string", ("String expected, got %s."):format(type(sceneName)))
    assert(scene.scenes[sceneName], ("No scene found with name %s."):format(sceneName))
    return scene.scenes[sceneName]
end

--- Switches scenes by running scene.clearAll() and showing the given scene(s).
--- @tparam string sceneName The name of the first scene to show.
function scene.switch(sceneName, ...)
    assert(sceneName, "Name or scene expected, got nil.")
    if not sceneName then
        sceneName = self
    end
    scene.clearAll()
    scene.show(sceneName)
    local scenes = { ... }
    for i = 1, #scenes do
        scene.show(scenes[i])
    end
end

--- Clears all scenes.
--- @return nil
function scene.clearAll()
    for _, scene in pairs(scene.currentScenes) do
        scene:clear()
    end
end

--- Returns which scenes are visible.
--- @treturn table which scenes are visible.
function scene.visible()
    return scene.currentScenes
end

--- Returns if self is visible.
--- @treturn boolean If self is visible.
function scene:isVisible()
    assert(self, "What are you trying to check the visibility of?")
    assert(self.name, "Self has no name.")
    assert(scene.scenes[self.name], ("No scene by the name %s exists."):format(self.name))
    for k, v in pairs(scene.scenes[self.name]) do
        assert(v, ("Scene %s contains no elements!"):format(self.name))
        if type(v) == "table" then
            return v.visible
        end
    end
end

--- Loads the scene file at the given location.
--- @tparam string sceneName The path to the scene.
--- @return nil
function scene:load(sceneName)
    if not sceneName then
        sceneName = self
    end
    assert(sceneName, "Cannot load scene without a name.")
    self = scene
    if not self.scenes[sceneName] then
        local sceneTbl = dofile("scenes/" .. sceneName .. ".scene")
        assert(sceneTbl, ("Could not load scene %s at scenes/%s.scene. Is the file malformed?"):format(sceneName, sceneName))
        local newScene = self:new(sceneName)
        for k = #sceneTbl, 1, -1 do
            local item = sceneTbl[k]
            if type(item) == "table" then
                local itemName = item.name
                local itemConstructor = item.type
                item.name = nil
                item.visible = false
                local itemSprite = itemConstructor(item)
                item.name = itemName
                newScene:set(sceneName, itemName, itemSprite)
            end
        end
        for k, v in pairs(sceneTbl) do
            if not tonumber(k) or k < 0 or k > #sceneTbl then
                newScene[k] = v
            end
        end
        if sceneTbl.init then
            sceneTbl:init(scene)
            newScene.init = sceneTbl.init
        end
        newScene.name = sceneName
        self.scenes[sceneName] = newScene
    end
    return self.scenes[sceneName]
end

--- Fades out the game using a vignette over seconds, then clears all scenes.
--- @tparam number seconds How many seconds it should take to fade out.
--- @tparam function fct A callback to run when it's done.
--- @return nil
function scene.circularFadeOut(seconds, fct)
    assert(type(seconds) == "number", ("Number expected, got %s."):format(type(seconds)))
    assert(type(fct) == "function" or not fct, ("Function or nil expected, got %s."):format(type(fct)))
    scheduler.before(seconds, function(timePassed)
        effects.vignette:set("opacity", timePassed / seconds)
        effects.vignette:set("softness", timePassed / seconds)
        effects.vignette:set("radius", 1 - timePassed / seconds)
    end)
    scheduler.after(seconds, function()
        scene.clearAll()
        effects.vignette:set("radius", .25)
        effects.vignette:set("opacity", 0)
        effects.vignette:set("softness", .45)
        if type(fct) == "function" then
            fct()
        end
    end)
end

--- Fades in the game using a vignette over seconds.
--- @tparam number seconds How many seconds it should take to fade in.
--- @tparam function fct A callback to run when it's done.
--- @return nil
function scene.circularFadeIn(seconds, fct)
    assert(type(seconds) == "number", ("Number expected, got %s."):format(type(seconds)))
    assert(type(fct) == "function" or not fct, ("Function or nil expected, got %s."):format(type(fct)))
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
        if type(fct) == "function" then
            fct()
        end
    end)
end

--- Fades out the game over seconds, then clears all scenes.
--- @tparam number seconds How many seconds it should take to fade out.
--- @tparam function fct A callback to run when it's done.
--- @return nil
function scene.fadeOut(seconds, fct)
    assert(type(seconds) == "number", ("Number expected, got %s."):format(type(seconds)))
    assert(type(fct) == "function" or not fct, ("Function or nil expected, got %s."):format(type(fct)))
    effects.vignette:set("radius", 0)
    scheduler.before(seconds, function(timePassed)
        effects.vignette:set("opacity", timePassed / seconds)
    end)
    scheduler.after(seconds, function()
        scene.clearAll()
        effects.vignette:set("radius", .25)
        effects.vignette:set("opacity", 0)
        effects.vignette:set("softness", .45)
        if type(fct) == "function" then
            fct()
        end
    end)
end

--- Fades in the game over seconds.
--- @tparam number seconds How many seconds it should take to fade in.
--- @tparam function fct A callback to run when it's done.
--- @return nil
function scene.fadeIn(seconds, fct)
    assert(type(seconds) == "number", ("Number expected, got %s."):format(type(seconds)))
    assert(type(fct) == "function" or not fct, ("Function or nil expected, got %s."):format(type(fct)))
    scheduler.before(seconds, function(timePassed)
        effects.vignette:set("opacity", 1 - timePassed / seconds)
    end)
    scheduler.after(seconds, function()
        effects.vignette:set("radius", .25)
        effects.vignette:set("opacity", 0)
        effects.vignette:set("softness", .45)
        if type(fct) == "function" then
            fct()
        end
    end)
end

return scene