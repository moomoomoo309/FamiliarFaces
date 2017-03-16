local all = function(...) --Returns the last true value, or false if any value is false.
    return select("#", ...) == 1 and (...) or ((...) and all(select(2, ...)))
end

local any = function(...) --Returns the first true value, or the last false value.
    return (...) or any(select(2, ...))
end

function math.round(num) --Rounds a floating point number to the nearest integer.
    return num >= 0 and math.floor(num + .5) or math.ceil(num - .5)
end

function math.frandom(low, high) --Works like math.random(low,high), but returns a float instead of an int.
    return math.random(low - (high and 0 or 1), high and high - 1 or nil) + math.random()
end

return { all, any }

