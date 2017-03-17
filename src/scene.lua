local font = love.graphics.getFont()
local fontHeight = font:getHeight()
sprite = sprite or require "sprite"
local visibleText = {}
local i = 1
local defaultPaddingX, defaultPaddingY = 20, 10
local scene
yOffset = 0

local function printText2(text, paddingX, paddingY, i, color)
    local localYOffset = (i - 1) * (fontHeight + paddingY) + paddingY
    if localYOffset > love.graphics.getHeight() then
        yOffset = love.graphics.getHeight() - localYOffset
    end
    local img = love.graphics.newText(font, text)
    if color then
        img:addf({color,text},love.graphics.getWidth()-2*paddingX,"left",0,0)
    end
    img:setFont(font)
    visibleText[#visibleText + 1] = sprite {
        x = paddingX,
        y = localYOffset,
        w = img:getWidth(),
        h = img:getHeight(),
        image = img
    }
    return transX, transY
end

scene = {
    scenes = {},
    currentScenes = {},
    printText = function(self, text, reset, color) ---Print the given text on the screen, moving the camera down when the text gets off screen.
        ---Make reset true to move the text back to the top of the screen.
        if reset then
            i = 0
            yOffset = 0
        end
        local transX, transY = printText2(text, defaultPaddingX, defaultPaddingY, i, color)
        i = i + 1
        return transX, transY
    end,
    clearText = function() ---Clears all visible text from printText.
        for _, v in pairs(visibleText) do
            v.visible = false
        end --Make the sprites invisible so they disappear before garbage collection.
        visibleText = {} --Release all of the references to the sprites, causing them to get collected.
    end,
    new = function(self, name) ---Creates a new scene.
        scene.scenes[name] = scene.scenes[name] or { class = scene, name = name }
    end,
    add = function(self, name, sceneName, additionalScene) ---Adds a sprite to the given scene.
        if not scene.scenes[name] then scene:new(name) end
        scene.scenes[name][sceneName] = additionalScene
    end,
    clear = function(self, sceneName) ---Clears the scene with the given name, or self if called with a scene.
        sceneName = sceneName or self.name
        for k, v in pairs(scene.scenes[sceneName] or {}) do
            if type(v) == "table" and k ~= "class" then
                v.visible = false
            end
        end
        for i = 1, #scene.currentScenes do
            if scene.currentScenes[i] == scene.scenes[sceneName] then
                table.remove(scene.currentScenes, i)
                break
            end
        end
    end,
    show = function(self, sceneName) ---Shows the scene with the given name, or self if called with a scene.
        scene.currentScenes[#scene.currentScenes + 1] = sceneName or self
        for i = 1, #scene.currentScenes do
            for k, v in pairs(scene.scenes[scene.currentScenes[i].name]) do
                if type(v) == "table" and k ~= "class" then
                    v.visible = true
                end
            end
        end
    end,
    clearAll = function() ---Clears all scenes.
        scene:clear()
    end,
    visible = function(self) ---Returns which scenes are visible
        return scene.currentScenes
    end,
    isVisible = function(self) ---Returns if self is visible.
        return scene.scenes[self.name] and ({ next(scene.scenes[self.name]) })[2].visible
        --The thing after the and gets the first sprite in the scene and checks if it's visible. The [2] is because next returns the key and the value.
    end
}

return scene