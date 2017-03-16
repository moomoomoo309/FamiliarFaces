local map = function(fct, numArgs, ...) --Allows functions to take unlimited arguments.
    assert(type(fct) == "function" and type(numArgs) == "number")
    local results = {}
    local resultsLen = 0
    local function innerWrap(fct, numArgs, results, args, argsLen)
        local returns, tblLen = {}, 0
        for i = argsLen, argsLen - numArgs + 1, -1 do
            tblLen = tblLen + 1
            returns[tblLen] = args[i]
            args[argsLen] = nil --Remove the last argument, so to avoid a table.remove() call (which is O(n), where this is O(1))
            argsLen = argsLen - 1
        end
        if argsLen < 0 and tblLen < numArgs then
            return results
        end
        resultsLen = resultsLen + 1
        results[resultsLen] = fct(unpack(returns))
        return argsLen >= numArgs and innerWrap(fct, numArgs, results, args, argsLen) or results
    end

    local tbl = innerWrap(fct, numArgs, results, { ... }, select("#", ...)) --Select vs. making {...} local and doing len on it was the same speed, but this is one line shorter.
    local tblLen = #tbl
    for i = 1, tblLen / 2 do --Reverse the table, since inserting it backwards is n(n-i) iterations, but reversing it is n/2.
        tbl[i], tbl[tblLen - i + 1] = tbl[tblLen - i + 1], tbl[i] --Swap the first half of the elements with the last half
    end
    return unpack(tbl)
end

return map