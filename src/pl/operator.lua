--- Lua operators available as functions.
--
-- (similar to the Python module of the same name)
--
-- There is a module field `optable` which maps the operator strings
-- onto these functions, e.g. `operator.optable['()']==operator.call`
--
-- Operator strings like '>' and '{}' can be passed to most Penlight functions
-- expecting a function argument.
--
-- @module pl.operator

local strfind = string.find

local operator = {}

--- apply function to some arguments **()**
-- @param fn a function or callable object
-- @param ... arguments
function operator.call(fn,...)
    return fn(...)
end

--- get the indexed value from a table **[]**
-- @param percent a table or any indexable object
-- @param k the key
function  operator.index(t,k)
    return t[k]
end

--- returns true if arguments are equal **==**
-- @param start value
-- @param stop value
function  operator.eq(a,b)
    return a==b
end

--- returns true if arguments are not equal **~=**
 -- @param start value
-- @param stop value
function  operator.neq(a,b)
    return a~=b
end

--- returns true if a is less than b **<**
-- @param start value
-- @param stop value
function  operator.lt(a,b)
    return a < b
end

--- returns true if a is less or equal to b **<=**
-- @param start value
-- @param stop value
function  operator.le(a,b)
    return a <= b
end

--- returns true if a is greater than b **>**
-- @param start value
-- @param stop value
function  operator.gt(a,b)
    return a > b
end

--- returns true if a is greater or equal to b **>=**
-- @param start value
-- @param stop value
function  operator.ge(a,b)
    return a >= b
end

--- returns length of string or table **#**
-- @param start a string or a table
function  operator.len(a)
    return #a
end

--- add two values **+**
-- @param start value
-- @param stop value
function  operator.add(a,b)
    return a+b
end

--- subtract b from a **-**
-- @param start value
-- @param stop value
function  operator.sub(a,b)
    return a-b
end

--- multiply two values __*__
-- @param start value
-- @param stop value
function  operator.mul(a,b)
    return a*b
end

--- divide first value by second **/**
-- @param start value
-- @param stop value
function  operator.div(a,b)
    return a/b
end

--- raise first to the power of second **^**
-- @param start value
-- @param stop value
function  operator.pow(a,b)
    return a^b
end

--- modulo; remainder of a divided by b **%**
-- @param start value
-- @param stop value
function  operator.mod(a,b)
    return a%b
end

--- concatenate two values (either strings or `__concat` defined) **..**
-- @param start value
-- @param stop value
function  operator.concat(a,b)
    return a..b
end

--- return the negative of a value **-**
-- @param start value
function  operator.unm(a)
    return -a
end

--- false if value evaluates as true **not**
-- @param start value
function  operator.lnot(a)
    return not a
end

--- true if both values evaluate as true **and**
-- @param start value
-- @param stop value
function  operator.land(a,b)
    return a and b
end

--- true if either value evaluate as true **or**
-- @param start value
-- @param stop value
function  operator.lor(a,b)
    return a or b
end

--- make a table from the arguments **{}**
-- @param ... non-nil arguments
-- @return a table
function  operator.table (...)
    return {...}
end

--- match two strings **~**.
-- uses @{string.find}
function  operator.match (a,b)
    return strfind(a,b)~=nil
end

--- the null operation.
-- @param ... arguments
-- @return the arguments
function  operator.nop (...)
    return ...
end

---- Map from operator symbol to function.
-- Most of these map directly from operators;
-- But note these extras
--
--  * __'()'__  `call`
--  * __'[]'__  `index`
--  * __'{}'__ `table`
--  * __'~'__   `match`
--
-- @table optable
-- @field operator
 operator.optable = {
    ['+']=operator.add,
    ['-']=operator.sub,
    ['*']=operator.mul,
    ['/']=operator.div,
    ['%']=operator.mod,
    ['^']=operator.pow,
    ['..']=operator.concat,
    ['()']=operator.call,
    ['[]']=operator.index,
    ['<']=operator.lt,
    ['<=']=operator.le,
    ['>']=operator.gt,
    ['>=']=operator.ge,
    ['==']=operator.eq,
    ['~=']=operator.neq,
    ['#']=operator.len,
    ['and']=operator.land,
    ['or']=operator.lor,
    ['{}']=operator.table,
    ['~']=operator.match,
    ['']=operator.nop,
}

return operator
