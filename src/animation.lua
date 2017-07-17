local animation
animation = animation or {
    type = "animation",
    class = animation,
    runningAnimations = {}
}

--- Creates a new animation with the arguments provided.
-- @param self Allows animation.new or animation:new to be called.
-- @param args A table containing arguments, which may be any of the following:
-- frames: (Optional) The frames of the animation.
-- frameDurations: (Optional) The duration, in seconds, of each frame of the animation, or of all of them. Defaults to 1/60
-- sprite: The drawable used in the animation
-- colors: (Optional) A table containing all of the colors which will overlay the sprite, or one color which will overlay all of them.
-- @return The created animation.
function animation:new(args)
    local obj = {
        frames = args.frames or {},
        frameDurations = args.frameDurations or 1 / 60,
        currentFrame = 1,
        lastTime = 0,
        remainingTime = 0,
        frameCount = 1,
        sprite = args.sprite,
        animation = animation,
        colors = args.colors,
        paused = true,
        currentColor = false
    }
    return setmetatable(obj, { __index = animation })
end

--- Starts the animation. Makes the sprite draw using the first frame of this animation.
-- @param self The animation to start.
-- @return nil
function animation:start()
    self.animation.runningAnimations[self.sprite] = self
    self.lastTime = love.timer.getTime()
    self.sprite.animating = self
    self.paused = false
    self.currentColor = false
    if self.colors then
        if type(self.colors) == "table" then
            self.currentColor = self.colors[self.currentFrame]
        elseif type(self.colors) == "function" then
            self.currentColor = self:colors(self.currentFrame, self.frameCount)
        end
    end
end

--- Stops the animation. Makes the sprite go back to drawing using its image property.
-- @param self The animation to stop.
-- @return nil
function animation:stop()
    self.animation.runningAnimations[self.sprite] = nil
    self.sprite.animating = false
    self.paused = true
end

--- Pauses the animation. Note, a paused animation will use the current frame of the animation,
-- while a sprite not animating will use the sprite's image.
-- @param self The animation to pause.
-- @return nil
function animation:pause()
    self.paused = true
end

--- Resumes the animation.
-- @param self The animation to resume.
-- @return nil
function animation:resume()
    self.paused = false
    self.lastTime = love.timer.getTime() --Update the time of the last frame
    self:animate()
end

--- Resets all properties of this animation involving its running state.
-- @param self The animation to reset.
-- @return nil
function animation:reset()
    self.currentFrame = 1
    self.paused = true
    self.currentColor = false
    self.frameCount = 1
end

--- Makes a copy of this animation, resetting its state in the process.
-- @param self The animation to copy.
-- @return The copied animation.
function animation:copy()
    local obj = {
        frames = self.frames,
        frameDurations = self.frameDurations,
        currentFrame = 1,
        lastTime = 0,
        remainingTime = 0,
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

--- Animates the sprite, advancing which frame it is on if necessary, or updating the time until the next frame.
-- @param self The animation to animate.
-- @return nil
function animation:animate()
    if self.paused then --If it's paused, just return. Exists because paused animations will use the current frame,
        --but if the animation is stopped, the sprite will use its image to draw.
        return
    end
    if not self.sprite.visible then
        animation.runningAnimations[self.sprite] = nil
        return
    end
    local timePassed = love.timer.getTime() - self.lastTime --Get the delta between the last frame of animation and now.
    if self.remainingTime > timePassed then --If the leftover time before the next frame is animated is higher than the time passed...
        self.remainingTime = self.remainingTime - timePassed --Subtract it from the leftover time
        self.lastTime = love.timer.getTime() --Update the time of the last frame
        return
    else
        timePassed = timePassed - self.remainingTime --Subtract it from the time passed and move to the next frame.

        --Next frame!
        self.currentFrame = self.currentFrame == #self.frames and 1 or self.currentFrame + 1
        self.frameCount = self.frameCount + 1
    end
    if type(self.frameDurations) == "table" then
        while timePassed > 0 do
            if self.frameDurations[self.currentFrame] > timePassed then
                self.remainingTime = self.frameDurations[self.currentFrame] - timePassed --Set the leftover time, and break
                break
            end
            timePassed = timePassed - self.frameDurations[self.currentFrame] --Subtract the time from one frame

            --Next frame!
            self.currentFrame = self.currentFrame == #self.frames and 1 or self.currentFrame + 1
            self.frameCount = self.frameCount + 1
        end
    else
        local duration
        if type(self.frameDurations) == "number" then
            duration = self.frameDurations
        elseif type(self.frameDurations) == "function" then
            duration = self:frameDurations(self.currentFrame, self.frameCount)
        end
        assert(type(duration) == "table" or type(duration) == "number" or type(duration) == "function", ("frameDurations (%s) of animation incorrect! Expected table, number, or function, got %s."):format(self.frameDurations, type(self.frameDurations)))
        while timePassed > 0 do
            if duration > timePassed then
                self.remainingTime = duration - timePassed --Set the leftover time, and break; it's done!
                break
            end
            timePassed = timePassed - duration --Subtract the time from one frame

            --Next frame!
            self.currentFrame = self.currentFrame == #self.frames and 1 or self.currentFrame + 1
            self.frameCount = self.frameCount + 1
        end
    end
    self.currentColor = false
    if self.colors then
        if type(self.colors) == "table" then
            self.currentColor = self.colors[self.currentFrame]
        elseif type(self.colors) == "function" then
            self.currentColor = self:colors(self.currentFrame, self.frameCount)
        end
    end
    self.lastTime = love.timer.getTime() --Update the time of the last frame
end

--- Animates all animations at once.
-- @return nil
function animation.animateAll()
    for _, anim in pairs(animation.runningAnimations) do
        anim:animate()
    end
end

animation.unpause = animation.resume --Alias

return setmetatable(animation, { __call = animation.new })