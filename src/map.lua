---Applies a function to a set of data, returning the results.
--@param fct The function to apply.
--@param numArgs How many arguments the function takes.
--@param ... The values to apply the function to.
--@return The values the function returns each time, unpacked.
local function map(fct, numArgs, ...)
    assert(type(fct) == "function" and type(numArgs) == "number")
    local results = {}
    local resultsLen = 0
    local function innerWrap(fct, numArgs, results, args, argsLen)
        local returns, tblLen = {}, 0
        for i = argsLen, argsLen - numArgs + 1, -1 do
            tblLen = tblLen + 1
            returns[tblLen] = args[i]
            args[argsLen] = nil --Remove the last argument, avoiding table.remove (which is O(n), where this is O(1))
            argsLen = argsLen - 1
        end
        if argsLen < 0 and tblLen < numArgs then
            return results
        end
        resultsLen = resultsLen + 1
        results[resultsLen] = fct(unpack(returns))
        if argsLen >= numArgs then --Ordinarily, I'd do a ternary return, but that prevents a tail-recursion here.
            return innerWrap(fct, numArgs, results, args, argsLen)
        end
        return results
    end

    local tbl = innerWrap(fct, numArgs, results, { ... }, select("#", ...)) --Select vs. making {...} local and doing len on it was the same speed, but this is one line shorter.
    local tblLen = #tbl
    --Reverse the table, inserting it backwards in innerWrap is n*(n-i) iterations, but reversing it here is n/2.
    for i = 1, tblLen / 2 do
        tbl[i], tbl[tblLen - i + 1] = tbl[tblLen - i + 1], tbl[i] --Swap the first half of the elements with the last half
    end
    return unpack(tbl)
end

return map