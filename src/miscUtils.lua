--- A module containing a few utility functions: any, all, anyCondition, allCondition, math.round, math.frandom
--- @module miscUtils

local map = require "map"


---Returns if all of the arguments are truthy.
---@param ... The values to check for truthiness.
---@treturn boolean If all of the arguments are truthy.
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
---@tparam function fct The function to run on each value.
---@param ... The values to run fct on.
---@treturn boolean If all of the arguments passed in ... satisfy fct.
local function allCondition(fct, ...)
    return all(map(fct, 1, ...))
end

---Returns if any arguments are true.
---@param ... The values to check for truthiness.
---@treturn boolean If any arguments are true.
local function any(...)
    return ((...) or any(select(2, ...))) and true or false
end

---Returns if anything passed in ... satisfy fct.
---@tparam function fct The function to run on each value.
---@param ... The values to run fct on.
---@treturn boolean If all of the arguments passed in ... satisfy fct.
local function anyCondition(fct, ...)
    return any(map(fct, 1, ...))
end

---Rounds a floating point number to the nearest integer.
---@tparam number num The number to round
---@treturn number The nearest integer to num.
function math.round(num)
    return num >= 0 and math.floor(num + .5) or math.ceil(num - .5)
end

---Works like math.random(low,high), but returns a float instead of an int.
---@tparam number/nil low (Optional) The lower bound of the number.
---@tparam number/nil high (Optional) The upper bound of the number.
---@treturn number A random number in the range (low,high) if low and high are provided, in (0,low) if low is provided, or in (0,1) if neither are.
function math.frandom(low, high)
    if low and high then
        return math.random(low, high-1) + math.random() --returns a value in low < value < high
    elseif low then
        return math.random(low-1) + math.random() --returns a value in 0 < value < low
    end
    return math.random() --Not sure why you wouldn't pass arguments, but you can choose not to!
end

return all, any, allCondition, anyCondition
