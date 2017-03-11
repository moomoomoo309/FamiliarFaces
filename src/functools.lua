local functools = {}

function functools.partial(f,...) --Provides default arguments for a function. Efficient enough to use lightly.
  local args={...}
  return function(...)
    return f(unpack(args),...)
  end
end
local skip={}
functools.skip=skip

function functools.partialGaps(f,...) --Provides default arguments for a function, allowing for gaps.
  --Not efficient because of how dynamic it is. Do not use if possible.
  local args={...}
  return function(...)
    local finalArgs,offset={},1
    for i=1,#args+select("#",...) do
      if args[i]==skip or i>#args then
        finalArgs[i]=select(offset,...)
        offset=offset+1
      else
        finalArgs[i]=args[i]
      end
    end
    return f(unpack(finalArgs))
  end
end

function functools.reduce(f,numArgs,...) --Apply function of two arguments cumulatively to the args, from left to right,
  --so as to reduce the iterable to a single value.
  local result=f(...)
  for i=numArgs,select("#",...),numArgs do
    result = f(result,select(i-1,...))
  end
  return result
end

return functools