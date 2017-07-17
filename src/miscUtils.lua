map = map or require "map"


---Returns if all of the arguments are truthy.
--@param ... The values to check for truthiness.
--@return If all of the arguments are truthy.
local function all(...)
    if select("#", ...) == 1 then
        return (...) and true or false
    elseif (...) then
        return all(select(2, ...))
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

---Returns if all of the arguments passed in ... satisfy fct.
--@param fct The function to run on each value.
--@param ... The values to run fct on.
--@return If all of the arguments passed in ... satisfy fct.
local function allCondition(fct, ...)
    return all(map(fct, 1, ...))
end

---Returns if any arguments are true.
--@param ... The values to check for truthiness.
--@return If any arguments are true.
local function any(...)
    return ((...) or any(select(2, ...))) and true or false
end

---Returns if anything passed in ... satisfy fct.
--@param fct The function to run on each value.
--@param ... The values to run fct on.
--@return If all of the arguments passed in ... satisfy fct.
local function anyCondition(fct, ...)
    return any(map(fct, 1, ...))
end

---Rounds a floating point number to the nearest integer.
--@param num The number to round
--@return The nearest integer to num.
function math.round(num)
    return num >= 0 and math.floor(num + .5) or math.ceil(num - .5)
end

---Works like math.random(low,high), but returns a float instead of an int.
--@param low (Optional) The lower bound of the number.
--@param high (Optional) The upper bound of the number.
--@return A random number in the range (low,high) if low and high are provided, in (0,low) if low is provided, and (0,1) if neither are.
function math.frandom(low, high)
    if low and high then
        return math.random(low, high-1) + math.random() --returns a value in low < value < high
    elseif low then
        return math.random(low-1) + math.random() --returns a value in 0 < value < low
    end
    return math.random() --Not sure why you wouldn't pass arguments, but you can choose not to!
end

return all, any, allCondition, anyCondition
