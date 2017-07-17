local object
object = {
    --The "object" class, so to speak. Adds callbacks.
    type = "object",
    class = object,
    cancel = setmetatable({}, {
        __newindex = function()
        end
    })
}

--- Adds a callback to the given property (running the function when the property changes)
-- @param key The property to add the callback for.
-- @param fct The function to run when key changes. Object and the new value will be passed as parameters to it.
-- @return nil
function object:addCallback(key, fct)
    assert(type(fct) == "function", ("Function expected, got %s."):format(type(fct)))
    self.callbacks[key] = self.callbacks[key] or {}
    self.callbacks[key][#self.callbacks[key] + 1] = fct
end

--- Triggers the callback for the given property, updating it to the passed value if not cancelled.
-- @param property The property to trigger callbacks for.
-- @param value What the new value of the property should be.
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

--- Creates a new object using the values contained in tbl. Can be run using object(), object.new() or object:new().
-- @param self (Unused) Allows object.new or object:new to be called.
-- @param tbl The parameters to the object. All of these values will be put into the object on initialization.
-- @return The created object.
function object:new(tbl)
    tbl = tbl or self --Allow object.new{} or object:new{}.
    assert(type(tbl) == "table", ("Table expected, got %s."):format(type(tbl)))
    local realElement --This table stores values, the actual element is empty, because that's how callbacks are easily done in Lua.
    realElement = { callbacks = {} } --The table storing all of the callbacks for the object.
    realElement = setmetatable(realElement, { __index = object }) --Give it the methods from object
    realElement.realTbl = realElement --In case access to the real table is needed, here's a pointer to it.
    local defaultMt = {
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
    return element --Return the created "object"
end

return setmetatable(object, { __call = object.new })
