local font = love.graphics.getFont()
local fontHeight = font:getHeight()
sprite = sprite or require "sprite"
local visibleText = {}
local i = 1
local defaultPaddingX, defaultPaddingY = 20, 10
local scene
scene = {
    scenes = {},
    currentScenes = {},
    printText2 = function(text, paddingX, paddingY, i)
        local y = (i - 1) * (fontHeight + paddingY) + paddingY
        if y > love.graphics.getHeight() then
            transX, transY = transX, transX-(y - love.graphics.getHeight() - paddingY)
        end
        local img = love.graphics.newText(font, text .. i)
        visibleText[#visibleText + 1] = sprite {
            x = paddingX,
            y = y,
            w = img:getWidth(),
            h = img:getHeight(),
            image = img
        }
        return transX, transY
    end,
    printText = function(self,text, reset)
        if reset then
            i = 1
        end
        local transX, transY = self.printText2(text, defaultPaddingX, defaultPaddingY, i)
        i = i + 1
        return transX, transY
    end,
    clearText = function()
        for _, v in pairs(visibleText) do
            v.visible = {}
        end --Make the sprites invisible so you don't need to wait for GC
        visibleText = {} --Release all of the references to the sprites, causing them to get collected.
    end,
    new = function(self, name)
        scene.scenes[name] = scene.scenes[name] or { class = scene, name = name }
    end,
    add = function(self, name, sceneName, additionalScene)
        if not scene.scenes[name] then scene:new(name) end
        scene.scenes[name][sceneName] = additionalScene
    end,
    clear = function(self, sceneName)
        sceneName = sceneName or self.name
        for k, v in pairs(scene.scenes[sceneName] or {}) do
            if type(v) == "table" and k ~= "class" then
                v.visible = false
            end
        end
        for i = 1,#scene.currentScenes do
            if scene.currentScenes[i] == scene.scenes[sceneName] then
                table.remove(scene.currentScenes,i)
                break
            end
        end
    end,
    show = function(self, sceneName)
        scene:clear(sceneName or self.currentScene)
        scene.currentScenes = sceneName
        for k, v in pairs(scene.scenes[scene.currentScenes] or {}) do
            if type(v) == "table" and k ~= "class" then
                v.visible = true
            end
        end
    end,
    clearAll = function()
        scene:clear()
    end,
    visible = function(self)
        return scene.currentScenes
    end,
    isVisible = function(self)
        return scene.scenes[self.name] and ({next(scene.scenes[self.name])})[2].visible
    end
}

return scene