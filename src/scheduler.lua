--Look ma, no dependencies!

local scheduler
scheduler = {
    paused = {},
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
        group = group or "default"
        scheduler.functions[group] = scheduler.functions[group] or {}
        local index = #scheduler.functions[group] + 1
        local timeElapsed = 0
        scheduler.functions[group][index] = function(dt)
            timeElapsed = timeElapsed + dt
            if timeElapsed >= seconds then
                fct()
                scheduler.functions[group][index] = nil
            end
        end
        return function()
            if scheduler.functions[group][index] then
                scheduler.functions[group][index] = nil
            end
        end
    end,
    before = function(seconds, fct, cancelFct, group)
        --- Run fct until seconds has passed. Returns a function which cancels this function.
        assert(type(fct)=="function", ("Function expected, got %s."):format(type(fct)))
        group = group or "default"
        scheduler.functions[group] = scheduler.functions[group] or {}
        local index = #scheduler.functions[group] + 1
        local timeElapsed = 0
        scheduler.functions[group][index] = function(dt)
            timeElapsed = timeElapsed + dt
            if timeElapsed >= seconds then
                scheduler.functions[group][index] = nil
            else
                fct(timeElapsed, dt)
            end
        end
        return function()
            if scheduler.functions[group][index] then
                scheduler.functions[group][index] = nil
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
        scheduler.functions[group] = scheduler.functions[group] or {}
        local index = #scheduler.functions[group] + 1
        scheduler.functions[group][index] = function()
            if done then
                scheduler.groups[scheduler.functions[group][index]] = nil
                scheduler.functions[group][index] = nil
                return
            end
            fct()
            done = done or conditionFct()
        end
        scheduler.groups[scheduler.functions[group][index]] = group
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
        scheduler.functions[group] = scheduler.functions[group] or {}
        local index = #scheduler.functions[group] + 1
        scheduler.functions[group][index] = function()
            if done then
                fct()
                scheduler.groups[scheduler.functions[group][index]] = nil
                scheduler.functions[group][index] = nil
                return
            end
            done = done or conditionFct()
        end
        scheduler.groups[scheduler.functions[group][index]] = group
        return function()
            done = true
            if type(cancelFct) == "function" then
                cancelFct()
            end
        end
    end,
    every = function(seconds, fct, cancelFct, group)
        --- Runs fct every seconds seconds.
        assert(type(fct)=="function", ("Function expected, got %s."):format(type(fct)))
        group = group or "default"
        scheduler.functions[group] = scheduler.functions[group] or {}
        local index = #scheduler.functions[group] + 1
        local timeElapsed = 0
        local timesRun = 0
        scheduler.functions[group][index] = function(dt)
            timeElapsed = timeElapsed + dt
            if timeElapsed >= seconds then
                timeElapsed = 0
                timesRun = timesRun + 1
                fct(timesRun)
            end
        end
        scheduler.groups[scheduler.functions[group][index]] = group
        return function()
            if scheduler.functions[group][index] then
                scheduler.functions[group][index] = nil
                if type(cancelFct) == "function" then
                    cancelFct()
                end
            end
        end
    end,
    everyCondition = function(conditionFct, fct, cancelFct, group)
        --- Runs fct every time conditionFct returns a truthy value.
        assert(type(fct)=="function", ("Function expected, got %s."):format(type(fct)))
        assert(type(conditionFct)=="function", ("Function expected, got %s."):format(type(conditionFct)))
        group = group or "default"
        scheduler.functions[group] = scheduler.functions[group] or {}
        local index = #scheduler.functions[group] + 1
        local timesRun = 0
        scheduler.functions[group][index] = function()
            if conditionFct() then
                timesRun = timesRun + 1
                fct(timesRun)
            end
        end
        scheduler.groups[scheduler.functions[group][index]] = group
        return function()
            if scheduler.functions[group][index] then
                scheduler.functions[group][index] = nil
                if type(cancelFct) == "function" then
                    cancelFct()
                end
            end
        end
    end,
    pause = function(group)
        scheduler.paused[group] = true
    end,
    resume = function(group)
        scheduler.paused[group] = false
    end ,
    update = function(dt)
        for group, fcts in pairs(scheduler.functions) do
            if not scheduler.paused[group] then
                for _, fct in pairs(fcts) do
                    fct(dt)
                end
            end
        end
    end
}
scheduler.unpause = scheduler.resume


return scheduler