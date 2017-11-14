--- The "object" class, so to speak. Adds callbacks.
--- @classmod object

local object
object = {
    type = "object",
    class = object,
    cancel = setmetatable({}, {
        __newindex = function()
        end
    }),
    globalCallback = {}
}

--- Adds a callback to the given property (running the function when the property changes)
--- @tparam any key The property to add the callback for.
--- @tparam function fct The function to run when key changes. Object and the new value will be passed as parameters to it.
--- @return nil
function object:addCallback(key, fct)
    assert(type(fct) == "function", ("Function expected, got %s."):format(type(fct)))
    self.callbacks[key] = self.callbacks[key] or {}
    self.callbacks[key][#self.callbacks[key] + 1] = fct
end

--- Triggers the callback for the given property, updating it to the passed value if not cancelled.
--- @tparam string property The property to trigger callbacks for.
--- @tparam any value What the new value of the property should be.
--- @return nil
function object:triggerCallback(property, value)
    local cancel = false
    if self.callbacks[property] then
        for k, v in pairs(self.callbacks[property]) do
            local callbackResult = v(self, value)
            if callbackResult == false then
                table.remove(self.callbacks[property], k) --If the callback returns false, remove it.
            elseif callbackResult == object.cancel then
                cancel = true --If object.cancel is passed, cancel setting the value.
            end
        end
    end
    if not cancel then
        rawset(self.realTbl, property, value) --Set the value if nothing cancelled it.
    end
end

--- Returns the default metatable for this object.
--- @treturn table The default metatable for this object.
function object:defaultMetatable()
    local realElement = self.realTbl
    return {
        __newindex = function(_, key, val)
            if realElement[key] == val then
                return
            end
            if type(realElement.callbacks[key]) == "table" then
                realElement.triggerCallback(realElement, key, val)
            else
                realElement[key] = val
            end
        end,
        __index = realElement, --Read the value from the real table, since this one is empty.
        --Get the length of the real table, since this one is empty.
        --Only works with Lua 5.2 or with 5.2 compat flags enabled.
        __len = realElement,
    }
end

--- Creates a new object using the values contained in tbl. Can be run using object(), object.new() or object:new().
--- @tparam table tbl The parameters to the object. All of these values will be put into the object on initialization.
--- @treturn object The created object.
function object:new(tbl)
    tbl = tbl or self --Allow object.new{} or object:new{}.
    assert(type(tbl) == "table", ("Table expected, got %s."):format(type(tbl)))
    local realElement --This table stores values, the actual element is empty, because that's how callbacks are easily done in Lua.
    realElement = { callbacks = {} } --The table storing all of the callbacks for the object.
    realElement = setmetatable(realElement, { __index = object }) --Give it the methods from object
    realElement.realTbl = realElement --In case access to the real table is needed, here's a pointer to it.
    local defaultMt = realElement:defaultMetatable()
    local element = setmetatable({}, defaultMt) --Gives the element its metatable for callbacks
    element:addCallback("class",
        function(self, class)
            if not getmetatable(self) then
                --Add the metatable if it does not exist.
                setmetatable(self, defaultMt)
            end
            local mt = getmetatable(self)
            mt.__index = class --Update the __index so it grabs properties from its class.
            mt.__call = class.new --Update the constructor so it can be created with classname().
        end)
    for k, v in pairs(tbl) do
        realElement[k] = v --Make sure all of the values in tbl go into the object.
    end
    return element
end

--- Gives the object a global callback. This will remove the ability to use normal callbacks!
--- @tparam function fct The function to run when any property of the object changes.
function object:setGlobalCallback(fct)
    self.callbacks = setmetatable(object.globalCallback, {
        __newindex = function()
            error "Global callback in use!"
        end
    })
    getmetatable(self).__newindex = fct
end

--- Returns if this object has a global callback.
--- @treturn boolean If this object has a global callback.
function object:hasGlobalCallback()
    return self.callbacks == object.globalCallback
end

--- Removes the global callback from the object.
--- @return nil
function object:removeGlobalCallback()
    self.callbacks = {}
    getmetatable(self).__newindex = self:defaultMetatable()
end

--- Returns if an object extends the given class. Can be given the class name as a string, or a reference to the class itself.
--- @tparam string|table className A class's name as a string or a class.
--- @treturn boolean If the object extends the given class.
function object:extends(className)
    local originalClassname = self.type
    local originalExtensionCheck = className
    assert(type(className) == "string" or type(className) == "table", ("String or table expected, got %s."):format(type(className)))
    local checkedClasses = {}
    local checkExtension
    checkExtension = function(self, className)
        local mt = getmetatable(self)
        if not mt then
            return false
        end
        local parent = mt.__index
        if not parent then
            return false
        end
        for i = 1, #checkedClasses do
            assert(checkedClasses[i] ~= parent, ("Circular class dependency checking if %s extends %s."):format(originalClassname, originalExtensionCheck))
        end
        checkedClasses[#checkedClasses + 1] = parent
        if type(parent) == "function" then
            assert(self.class, "Self has no class!")
            assert(getmetatable(self.class), "Self.class has no metatable!")
            parent = getmetatable(self.class).__index
        end
        assert(type(parent) == "table", ("Metatable __index must be a table, was a %s."):format(type(mt.__index)))
        if (type(className) == "string" and parent.type or parent.class) == className then
            return true
        else
            return checkExtension(parent, className)
        end
    end
    return checkExtension(self, className)
end

return setmetatable(object, { __call = object.new })
