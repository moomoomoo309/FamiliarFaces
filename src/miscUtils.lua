map = map or require "map"

local function all(...)
    ---Returns if all of the arguments are truthy.
    if select("#", ...) == 1 then
        return (...) and true or false
    elseif (...) then
        return all2(select(2, ...))
    end
    return false
end

--If you want all to be iterative (because you're using a lot of args), here you go!
--[[
local function all(args)
    for i = 1, #args do
        if not args[i] then
            return false
        end
    end
    return true
end
--]]

local function allCondition(fct, ...)
    ---Returns if all of the arguments passed in ... satisfy fct.
    return all(map(fct, 1, ...))
end

local function any(...)
    ---Returns if any arguments are true.
    return ((...) or any(select(2, ...))) and true or false
end

local function anyCondition(fct, ...)
    ---Returns if anything passed in ... satisfy fct.
    return any(map(fct, 1, ...))
end

function math.round(num)
    ---Rounds a floating point number to the nearest integer.
    return num >= 0 and math.floor(num + .5) or math.ceil(num - .5)
end

function math.frandom(low, high)
    ---Works like math.random(low,high), but returns a float instead of an int.
    if low and high then
        return math.random(low, high-1) + math.random() --returns a value in low < value < high
    elseif low then
        return math.random(low-1) + math.random() --returns a value in 0 < value < low
    end
    return math.random() --Not sure why you wouldn't pass arguments, but you can choose not to!
end

return all, any, allCondition, anyCondition
