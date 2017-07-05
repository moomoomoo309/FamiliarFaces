local function all(...)
    ---Returns if all values are true.
    return (select("#", ...) == 1 and (...) or ((...) and all(select(2, ...)))) and true or false
end

local function any(...)
    ---Returns if any value is true.
    return ((...) or any(select(2, ...))) and true or false
end

function math.round(num)
    ---Rounds a floating point number to the nearest integer.
    return num >= 0 and math.floor(num + .5) or math.ceil(num - .5)
end

function math.frandom(low, high)
    ---Works like math.random(low,high), but returns a float instead of an int.
    return math.random(low - (high and 0 or 1), high and high - 1 or nil) + math.random()
end

return all, any
