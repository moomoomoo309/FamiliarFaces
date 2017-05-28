local object
object = {
    --The "object" class, so to speak. Adds callbacks.
    type = "object",
    class = object,
    addCallback = function(self, key, fct) --Adds a callback to the given property (running the function when the property changes)
        self.callbacks[key] = self.callbacks[key] or {}
        self.callbacks[key][#self.callbacks[key] + 1] = fct
    end,
    triggerCallback = function(self, property)
        for k, v in pairs(self.callbacks[property]) do
            if v(self, self[property]) == false then --If the callback returns false, remove it.
                table.remove(self.callbacks[property], k)
            end
        end
    end,
    new = function(self, tbl)
        local realElement --This table stores values, the actual element is empty, because that's how callbacks are easily done in Lua.
        realElement = { callbacks = {} } --The table storing all of the callbacks for the object.
        realElement = setmetatable(realElement, { __index = object }) --Give it the methods from object
        realElement.realTbl = realElement --In case access to the real table is needed, here's a pointer to it.
        local defaultMt = {
            __newindex = function(_, key, val)
                if realElement[key] == val then return end
                realElement[key] = val --Set the value in the real table first, then run any callbacks
                if type(realElement.callbacks[key]) == "table" then
                    realElement.triggerCallback(realElement, key)
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
                if not getmetatable(self) then --Add the metatable if it does not exist.
                    setmetatable(self, defaultMt)
                end
                local mt = getmetatable(self)
                mt.__index = class --Update the __index so it grabs properties from its class.
                mt.__call = class.new --Update the constructor so it can be created with classname().
            end)
        for k, v in pairs(tbl) do --Set all the specified properties of the element in the constructor to the user set ones
            realElement[k] = v
        end
        return element --Return the created "object"
    end
}

return setmetatable(object, { __call = object.new })
