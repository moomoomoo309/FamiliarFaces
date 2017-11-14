--- A class allowing sprites to be animated.
--- @classmod animation

local object = require "object"
local animation

--- @see sprite
animation = animation or {
    type = "animation",
    class = animation,
    runningAnimations = {}
}

--- Creates a new animation with the arguments provided.
--- @tparam table args A table containing arguments, which may be any of the following:<br>
--- frames: (Optional) The frames of the animation.<br>
--- frameDurations: (Optional) The duration, in seconds, of each frame of the animation, or of all of them. Defaults to 1/60.<br>
--- sprite: The drawable used in the animation.<br>
--- colors: (Optional) A table containing all of the colors which will overlay the sprite, or one color which will overlay all of them.
--- @treturn animation The created animation.
function animation:new(args)
    local obj = object {
        frames = args.frames or {},
        frameDurations = args.frameDurations or 1 / 60,
        currentFrame = 1,
        startTime = 0,
        loopCount = 0,
        duration = -1,
        animTimeElapsed = 0,
        sprite = args.sprite,
        animation = animation,
        colors = args.colors,
        paused = true,
        currentColor = false
    }
    obj.class = animation
    obj:addCallback("frameDurations", animation.updateDuration)
    obj:updateDuration()
    return obj
end

--- Updates the duration of the animation.
--- @return nil
function animation:updateDuration()
    local t = type(self.frameDurations)
    if t == "number" then
        self.duration = self.frameDurations * (type(self.frames) == "table" and #self.frames or 1)
    elseif t == "table" then
        local duration = 0
        local durations = self.frameDurations
        for i = 1, #durations do
            duration = duration + durations[i]
        end
        self.duration = duration
    end
end

--- Starts the animation. Makes the sprite draw using the first frame of this animation.
--- @return nil
function animation:start()
    self.animation.runningAnimations[self.sprite] = self
    self.startTime = love.timer.getTime()
    self.sprite.animating = self
    self.paused = false
    self.currentColor = false
    if self.colors then
        self.currentColor = self:getColor()
    end
end

--- Stops the animation. Makes the sprite go back to drawing using its image property.
--- @return nil
function animation:stop()
    self.animation.runningAnimations[self.sprite] = nil
    self.sprite.animating = false
    self.paused = true
end

--- Pauses the animation. Note, a paused animation will use the current frame of the animation,
--- while a sprite not animating will use the sprite's image.
--- @return nil
function animation:pause()
    self.paused = true
end

--- Resumes the animation.
--- @return nil
function animation:resume()
    self.paused = false
    self.startTime = love.timer.getTime() --Update the time of the last frame
end

--- Resets all properties of this animation involving its running state.
--- @return nil
function animation:reset()
    self.currentFrame = 1
    self.paused = true
    self.currentColor = false
    self.loopCount = 0
end

--- Makes a copy of this animation, resetting its state in the process.
--- @treturn animation The copied animation.
function animation:copy()
    local obj = {
        frames = self.frames,
        frameDurations = self.frameDurations,
        currentFrame = 1,
        startTime = 0,
        frameCount = 1,
        sprite = self.sprite,
        animation = animation,
        start = self.start,
        stop = self.stop,
        colors = self.colors,
        paused = true,
        currentColor = false
    }
    return setmetatable(obj, { __index = animation })
end

function animation:getFrame(currentTime)
    self.currentFrame = self:getIndex(currentTime)
    return self.frames[self.currentFrame]
end

function animation:getIndex(currentTime)
    if self.paused then
        return self.currentFrame
    end
    currentTime = currentTime or love.timer.getTime()
    local dt = (currentTime - self.startTime)
    local currentFrame = self.currentFrame
    if dt / self.duration > self.loopCount then
        currentFrame = 1
    end
    dt = dt % self.duration --Make sure it doesn't have to loop over

    for i = 1, #self.frames do
        local nextFrame = type(self.frameDurations) == "table" and self.frameDurations[i] or self.frameDurations
        if dt < nextFrame then
            currentFrame = i
            break
        end
        dt = dt - nextFrame
    end
    return currentFrame
end

function animation:getColor(currentTime, index)
    local t = type(self.colors)
    if t == "number" then
        return { self.colors, self.colors, self.colors, 255 }
    elseif t == "table" then
        if (#self.colors == 3 or #self.colors == 4) and type(self.colors[1]) == "number" then
            return self.colors
        end
        return self.colors[index or self:getIndex(currentTime or love.timer.getTime())]
    elseif t == "function" then
        currentTime = currentTime or love.timer.getTime()
        return self:colors(currentTime - self.startTime)
    end
end

animation.unpause = animation.resume --Alias

return setmetatable(animation, { __call = animation.new, __index = object })