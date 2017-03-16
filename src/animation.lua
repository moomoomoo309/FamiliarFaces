animation = animation or {
    new = function(self, args)
        local obj = {
            frames = args.frames or {},
            frameDurations = args.frameDurations or 1 / 30,
            currentFrame = 1,
            lastTime = 0,
            remainingTime = 0,
            sprite = nil,
            animation = self,
            startAnimation = self.startAnimation,
            stopAnimation = self.stopAnimation
        }
        return obj
    end,
    startAnimation = function(self)
        self.animation.runningAnimations[self.sprite] = self
        self.lastTime = love.timer.getTime()
        self.sprite.animating = self
    end,
    stopAnimation = function(self)
        self.animation.runningAnimations[self.sprite] = nil
        self.sprite.animating = false
    end,
    runningAnimations = {},
    animate = function(self)
        for k, v in pairs(self.runningAnimations) do
            if not k.visible then
                self.runningAnimations[k] = nil
            end
            local timePassed = love.timer.getTime() - v.lastTime --Get the delta between the last frame of animation and now.
            if v.remainingTime > timePassed then --If the leftoever time before the next frame is animated is higher than the time passed...
                v.remainingTime = v.remainingTime - timePassed --Subtract it from the leftover time
                v.lastTime = love.timer.getTime() --Update the time of the last frame
                return
            else
                timePassed = timePassed - v.remainingTime --Subtract it from the time passed and move to the next frame.
                v.currentFrame = v.currentFrame == #v.frames and 1 or v.currentFrame + 1
            end
            if type(v.frameDurations) == "number" then
                while timePassed > 0 do
                    if v.frameDurations > timePassed then
                        v.remainingTime = v.frameDurations - timePassed --Set the leftover time, and break
                        break
                    end
                    timePassed = timePassed - v.frameDurations --Subtract the time from one frame
                    v.currentFrame = v.currentFrame == #v.frames and 1 or v.currentFrame + 1 --Next frame!
                end
            else
                while timePassed > 0 do
                    if v.frameDurations[v.currentFrame] > timePassed then
                        v.remainingTime = v.frameDurations[v.currentFrame] - timePassed --Set the leftover time, and break
                        break
                    end
                    timePassed = timePassed - v.frameDurations[v.currentFrame] --Subtract the time from one frame
                    v.currentFrame = v.currentFrame == #v.frames and 1 or v.currentFrame + 1 --Next frame!
                end
            end
            v.lastTime = love.timer.getTime() --Update the time of the last frame
        end
    end
}

setmetatable(animation, { __call = animation.new, __index = animation })

return animation