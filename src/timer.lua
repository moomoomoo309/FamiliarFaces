--Look ma, no dependencies!

local timer
timer = {
    paused = false,
    pauseTime = 0,
    pauseStartTime = -1,
    lastTime = -1,
    functions = {},
    sleep = function(seconds)
        --- Sleeps the running coroutine until seconds has passed. Will not work on the main thread.

        --Check for the main thread
        local co = coroutine.running()
        local success, errMessage = pcall(coroutine.yield)
        assert(success, errMessage:find("C-call", nil, true) and "You can't sleep on the main thread!" or errMessage)
        coroutine.resume(co)
        --Actually sleep
        love.timer.sleep(seconds)
    end,
    after = function(seconds, fct)
        --- Run fct after seconds with ... as parameters to fct. Returns a function which cancels this function.
        assert(type(fct)=="function", ("Function expected, got %s."):format(type(fct)))
        local startTime = love.timer.getTime()
        local index = #timer.functions+1
        timer.functions[index] = function(currentTime)
            if currentTime - startTime >= seconds then
                fct()
                timer.functions[index] = nil
            end
        end
        return function()
            if timer.functions[index] then
                timer.functions[index] = nil
            end
        end
    end,
    before = function(seconds, fct, cancelFct)
        --- Run fct until seconds with ... as parameters to fct. Returns a function which cancels this function.
        assert(type(fct)=="function", ("Function expected, got %s."):format(type(fct)))
        local startTime = love.timer.getTime()
        local index = #timer.functions + 1
        timer.functions[index] = function(currentTime)
            if currentTime - startTime >= seconds then
                timer.functions[index] = nil
            else
                fct(currentTime)
            end
        end
        return function()
            if timer.functions[index] then
                timer.functions[index] = nil
                if type(cancelFct) == "function" then
                    cancelFct()
                end
            end
        end
    end,
    pause = function()
        timer.paused = true
        timer.pauseStartTime = love.timer.getTime()
    end,
    resume = function()
        timer.paused = false
        timer.pauseTime = timer.pauseTime + love.timer.getTime() - timer.pauseStartTime
        timer.pauseStartTime = -1
    end,
    update = function()
        timer.lastTime = love.timer.getTime()
        local index = next(timer.functions, nil)
        if not timer.functions[index] or timer.paused then
            return
        end
        while true do
            local fct = timer.functions[index]
            fct(timer.lastTime - timer.pauseTime)
            index = next(timer.functions, index)
            if index == nil then
                break
            end
        end
    end
}
timer.unpause = timer.resume


return timer