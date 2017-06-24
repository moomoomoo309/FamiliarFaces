--Look ma, no dependencies!

local timer
timer = {
    paused = {},
    pauseTime = {},
    pauseStartTime = {},
    lastTime = {},
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
    after = function(seconds, fct, group)
        --- Run fct after seconds has passed. Returns a function which cancels this function.
        assert(type(fct)=="function", ("Function expected, got %s."):format(type(fct)))
        local startTime = love.timer.getTime()
        group = group or "default"
        timer.functions[group] = timer.functions[group] or {}
        local index = #timer.functions[group] + 1
        timer.functions[group][index] = function(currentTime)
            if currentTime - startTime >= seconds then
                fct()
                timer.functions[group][index] = nil
            end
        end
        return function()
            if timer.functions[group][index] then
                timer.functions[group][index] = nil
            end
        end
    end,
    before = function(seconds, fct, cancelFct, group)
        --- Run fct until seconds has passed. Returns a function which cancels this function.
        assert(type(fct)=="function", ("Function expected, got %s."):format(type(fct)))
        local startTime = love.timer.getTime()
        group = group or "default"
        timer.functions[group] = timer.functions[group] or {}
        local index = #timer.functions[group] + 1
        timer.functions[group][index] = function(currentTime)
            if currentTime - startTime >= seconds then
                timer.functions[group][index] = nil
            else
                fct(currentTime)
            end
        end
        return function()
            if timer.functions[group][index] then
                timer.functions[group][index] = nil
                if type(cancelFct) == "function" then
                    cancelFct()
                end
            end
        end
    end,
    ["until"] = function(conditionFct, fct, cancelFct, group)
        --- Runs fct until conditionFct returns a truthy value or the function returned is called.
        assert(type(fct)=="function", ("Function expected, got %s."):format(type(fct)))
        assert(type(conditionFct)=="function", ("Function expected, got %s."):format(type(conditionFct)))
        local done = conditionFct()
        group = group or "default"
        timer.functions[group] = timer.functions[group] or {}
        local index = #timer.functions[group] + 1
        timer.functions[group][index] = function()
            if done then
                timer.functions[group][index] = nil
                return
            end
            fct()
            done = done or conditionFct()
        end
        return function()
            done = true
            if type(cancelFct) == "function" then
                cancelFct()
            end
        end
    end,
    when = function(conditionFct, fct, cancelFct, group)
        --- Runs fct when conditionFct returns a truthy value or the function returned is called.
        assert(type(fct)=="function", ("Function expected, got %s."):format(type(fct)))
        assert(type(conditionFct)=="function", ("Function expected, got %s."):format(type(conditionFct)))
        local done = conditionFct()
        group = group or "default"
        timer.functions[group] = timer.functions[group] or {}
        local index = #timer.functions[group] + 1
        timer.functions[group][index] = function()
            if done then
                fct()
                timer.functions[group][index] = nil
                return
            end
            done = done or conditionFct()
        end
        return function()
            done = true
            if type(cancelFct) == "function" then
                cancelFct()
            end
        end
    end,
    pause = function(group)
        timer.paused[group] = true
        timer.pauseStartTime[group] = love.timer.getTime()
    end,
    resume = function(group)
        timer.paused[group] = false
        timer.pauseTime[group] = timer.pauseTime[group] + love.timer.getTime() - timer.pauseStartTime[group]
        timer.pauseStartTime[group] = -1
    end,
    update = function()
        for group,fcts in pairs(timer.functions) do
            if not timer.paused[group] then
                timer.lastTime[group] = love.timer.getTime()
                for _,fct in pairs(fcts) do
                    if not timer.lastTime[group] or not timer.pauseTime[group] then
                        fct(timer.lastTime[group])
                        timer.pauseTime[group] = 0
                    else
                        fct(timer.lastTime[group] - timer.pauseTime[group])
                    end
                end
            end
        end
    end
}
timer.unpause = timer.resume


return timer