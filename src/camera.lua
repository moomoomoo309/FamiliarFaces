--- A class acting like a camera using scale, translate, and rotate.
--- @classmod camera

local object = require "object"
local scheduler = require "scheduler"

local camera

camera = {
    cancelFcts = {},
    interpolations = {
        linear = function(start, stop, percentProgress)
            return start + (stop - start) * (1 - percentProgress)
        end,
        cos = function(start, stop, percentProgress)
            local f = (1 - math.cos((1 - percentProgress) * math.pi)) / 2
            return start * (1 - f) + stop * f
        end
    }
}

--- Creates the instance of the camera with the values passed in args.
--- @param _ (Unused) Allows camera.new to be called or camera:new.
--- @tparam table args A table of arguments modifying the camera. Can be any of the following:<br>
--- x: The x coordinate of the camera. Defaults to 0.<br>
--- y: The y coordinate of the camera. Defaults to 0.<br>
--- w: The width of the camera's viewport. Defaults to the screen width.<br>
--- h: The height of the camera's viewport. Defaults to the screen height.<br>
--- viewport: Another way of specifying the width and height of the camera. Defaults to the screen dimensions.<br>
--- zoom: How much the camera should be zoomed in. Defaults to 1.<br>
--- rotation: How much the camera should be rotated, in degrees. Defaults to 0.<br>
--- @treturn camera The instance of the camera. Will error if the camera instance already exists.
function camera.new(_, args)
    assert(camera.inst == nil, "Camera instance already exists! Camera is a singleton!")
    args = args or _ or {}
    local obj = object {
        x = args.x or 0,
        y = args.y or 0,
        w = args.w or love.graphics.getWidth(),
        h = args.h or love.graphics.getHeight(),
        viewport = args.viewport or love.graphics.getDimensions(),
        zoom = args.zoom or 1,
        rotation = args.rotation or 0,
        rotationPointX = args.rotationPointX or function(self)
            return self.w / 2
        end,
        rotationPointY = args.rotationPointY or function(self)
            return self.h / 2
        end,
        followFct = nil,
        inst = nil
    }
    obj.viewport = { obj.w, obj.h }
    obj:addCallback("w", function(self, w)
        self.viewport[1] = w
    end)
    obj:addCallback("h", function(self, h)
        self.viewport[2] = h
    end)
    obj:addCallback("viewport", function(self, viewport)
        if type(viewport) ~= "table" then
            error(("Viewport should be a table, was a %s."):format(type(viewport)))
        end
        if #viewport == 2 then
            self.w, self.h = unpack(viewport)
        else
            error "Viewport length not 2!"
        end
    end)
    obj.class = camera
    camera.inst = obj
    return obj
end

--- Performs all necessary matrix transformations needed by the camera.
--- @return nil
function camera:draw()
    local centerX = self.x + self.w / 2 / self.zoom
    local centerY = self.y + self.h / 2 / self.zoom
    local rotationPointX = type(self.rotationPointX) == "function" and self:rotationPointX() or self.rotationPointX
    local rotationPointY = type(self.rotationPointY) == "function" and self:rotationPointY() or self.rotationPointY
    love.graphics.push()
    love.graphics.translate(rotationPointX, rotationPointY)
    love.graphics.rotate(math.rad(self.rotation))
    love.graphics.translate(-rotationPointX, -rotationPointY)
    love.graphics.scale(self.zoom)
    love.graphics.translate(centerX, centerY)
end

--- Returns a table containing all of the matrix transformations done by the camera.
--- @treturn table A table containing all of the matrix transformations done by the camera.
function camera:getTransformations()
    self = self or camera.inst
    local centerX = self.x + self.w / 2 / self.zoom
    local centerY = self.y + self.h / 2 / self.zoom
    return { math.rad(self.rotation), self.zoom, self.zoom, centerX, centerY }
end

--- Converts screen coordinates to camera coordinates.
--- @tparam number x The x coordinate in screen coordinates
--- @tparam number y The y coordinate in screen coordinates.
--- @treturn number,number x and y in camera coordinates.
function camera:toCameraCoords(x, y)
    assert(type(x) == "number", ("Number expected, got %s."):format(type(x)))
    assert(type(y) == "number", ("Number expected, got %s."):format(type(y)))
    local xRot, yRot = math.cos(-self.rotation), math.sin(-self.rotation)
    x, y = (x - self.w / 2) / self.zoom, (y - self.h / 2) / self.zoom
    x, y = xRot * x - yRot * y, yRot * x + xRot * y
    return x + self.x, y + self.y
end

--- Converts camera coordinates to screen coordinates.
--- @tparam number x The x coordinate in camera coordinates
--- @tparam number y The y coordinate in camera coordinates.
--- @treturn number,number x and y in screen coordinates.
function camera:toScreenCoords(x, y)
    assert(type(x) == "number", ("Number expected, got %s."):format(type(x)))
    assert(type(y) == "number", ("Number expected, got %s."):format(type(y)))
    local xRot, yRot = math.cos(-self.rotation), math.sin(-self.rotation)
    x, y = x + self.x, y + self.y
    x, y = xRot * x - yRot * y, yRot * x + xRot * y
    return (x - self.w / 2) / self.zoom, (y - self.h / 2) / self.zoom
end

--- Transitions the values in values using the interpolation provided in the time provided, running fct.
--- key can be used to make sure it cancels the function with the given key, and fct will run on each iteration.
--- @tparam number time How many seconds it should take for the value to change completely.
--- @tparam string interpolation (Optional) The key of the function in camera.interpolations to use to tween the values.
--- @tparam table values A table whose keys are the fields to transition, and whose values are what they should transition to.
--- @tparam string key (Optional) The key of the transition function, so other functions on that key can be cancelled.
--- @tparam function fct (Optional) A function to run on each iteration of the transition.
--- @return A function which will cancel the transition.
function camera:transition(time, interpolation, values, key, fct)
    key = key or "default"
    if self.cancelFcts[key] then
        self.cancelFcts[key]()
    end
    local endValues, startValues, keys = {}, {}, {}
    for k, v in pairs(values) do
        endValues[#endValues + 1] = v
        startValues[#startValues + 1] = self[k]
        keys[#keys + 1] = k
        if time == 0 then
            self[k] = v
        end
    end
    if time == 0 then
        if type(fct) == "function" then
            fct(self, 1)
        end
        return
    end
    local interFct = camera.interpolations[interpolation] or camera.interpolations.cos --How it should interpolate
    local transitionFct
    local firstIteration = true --The first iteration is way off, so it should be ignored.
    local lastInterValues = {}
    local cam = camera.inst
    transitionFct = function(timeElapsed)
        local percentProgress = timeElapsed / time
        percentProgress = percentProgress > 1 and 1 or percentProgress < 0 and 0 or percentProgress --Ensure it stays between 0 and 1
        local deltas, interValues = {}, {}
        local interpolatedPercentProgress = 1 - interFct(0, 1, percentProgress)
        for i = 1, #endValues do
            interValues[i] = interFct(0, startValues[i] - endValues[i], percentProgress)
            if #lastInterValues > 0 then
                deltas[i] = interValues[i] - lastInterValues[i]
            end
        end
        lastInterValues = interValues --Grab the last values for the next delta.
        if firstIteration then
            --Ignore the first iteration, since it isn't a delta in the first iteration.
            firstIteration = false
            return
        end
        for i = 1, #keys do
            cam[keys[i]] = cam[keys[i]] + deltas[i] --Actually offset the values in the camera.
        end
        if type(fct) == "function" then
            fct(cam, interpolatedPercentProgress, percentProgress)
        end
    end

    local cancelFct1 = scheduler.before(time, transitionFct)
    local cancelFct2 = scheduler.after(time, function()
        for i = 1, #keys do
            if values[i] ~= nil then
                cam[keys[i]] = values[i] --Make sure the camera values end up being where they should be.
            end
        end
        self.cancelFcts[key] = nil
    end)
    self.cancelFcts[key] = function()
        cancelFct1()
        cancelFct2()
    end
    return self.cancelFcts[key]
end

--- Pans the camera to the given location in the given amount of time using the given interpolation.
--- @tparam number x Where it should end up on the x coordinate.
--- @tparam number y Where it should end up on the y coordinate.
--- @tparam number time How many seconds it should take to pan completely.
--- @tparam string interpolation (Optional) The key of the function in camera.interpolations to use to tween the values.
--- @tparam function fct A function to run on each movement of the camera.
--- @return A function which will cancel the camera pan right where it is.
function camera:pan(x, y, time, interpolation, fct)
    return self:transition(time, interpolation, { x = x, y = y }, "pan", fct)
end

--- Pans the camera to the given object in the given amount of time using the given interpolation.
--- @tparam table obj The object to pan to. (It does not actually need to be an object, it could be a normal table)
--- @tparam number time How many seconds it should take to pan completely.
--- @tparam string interpolation (Optional) The key of the function in camera.interpolations to use to tween the values.
--- @tparam function fct (Optional) A function to run on each movement of the camera.
--- @return A function which will cancel the camera pan right where it is.
function camera:panTo(obj, time, interpolation, fct)
    return self:pan(-obj.x, -obj.y, time, interpolation, fct)
end

--- Zooms the camera to the given zoom level in the given amount of time using the given interpolation.
--- @tparam number newZoom Where the zoom should end up.
--- @tparam number time How many seconds it should take to pan completely.
--- @tparam string interpolation (Optional) The key of the function in camera.interpolations to use to tween the values.
--- @tparam function fct (Optional) A function to run on each movement of the camera.
--- @treturn function A function which will cancel the camera pan right where it is.
function camera:zoomTo(newZoom, time, interpolation, fct)
    return self:transition(time, interpolation, { zoom = newZoom }, "zoom", fct)
end

--- Makes the camera follow the given object.
--- @tparam table obj The object to follow.
--- @return nil
function camera:follow(obj)
    self.followFct = function(self)
        self.x, self.y = -obj.x, -obj.y
    end
end

--- Makes the camers stop following anything.
--- @return nil
function camera:unfollow()
    self.followFct = nil
end

--- Makes sure camera:follow works.
--- @return nil
function camera:update()
    if (self or camera.inst).followFct then
        (self or camera.inst):followFct()
    end
end

return setmetatable(camera, { __call = camera.new, __index = object })
