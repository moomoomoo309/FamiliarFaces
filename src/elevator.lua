local elevator
camera = camera or require "camera"
scene = scene or require "scene"
local elevatorScene = scene.load "elevator"
local cam = camera.inst --Camera is a singleton, so I can just grab the instance as a "static member".
local locked = true
local transitionIndex = 1

local lightOffsets = {
    { 0, -80 },
    { 0, -80 },
    { 0, -80 },
    { 0, -80 },
    { 0, -80 },
    { 0, -80 },
    { 0, -80 },
    { 0, -80 },
    { 0, -80 },
    { 0, -80 },
    { 0, -80 },
    { 0, -80 },
    { 69, 41 },
    "flipHorizontal",
    { 69, -40 },
    { 70, -41 },
    { 69, -40 },
    { 70, -41 },
    { 69, -40 },
    { 69, -40 },
    { 69, -40 },
    { 70, -41 },
    { 69, -40 },
    { 0, -79 },
    { 0, -80 },
    { 0, -80 },
    { 0, -80 },
    { -69, 40 },
    { -70, 41 },
    { 0, -80 },
    { 0, -80 },
    { 0, -80 },
    { 0, -80 },
    { 0, -80 },
    { 0, -80 },
    { -69, 40 },
    { -70, 41 },
    "flipHorizontal",
    { -69, -40 },
    { -69, -40 },
    { 0, -80 },
    { 0, -80 },
    { -69, -40 },
    { -69, -40 },
    { -69, -40 },
    { 0, 80 },
    { 0, 80 },
    { -70, -41 },
    { -70, -40 },
    { -69, -40 },
    { 0, -80 },
    { 0, -80 },
    { 0, -80 },
    { 0, -80 },
    { 0, -80 },
    { 69, 40 },
    "flipHorizontal",
    { 70, -40 },
    { 69, -40 },
    { 69, -40 },
    { 69, -40 },
    { 0, -80 },
    { 0, -80 },
    { 0, -80 },
    { -70, 40 },
    { -69, 40 },
    { -69, 40 },
    { 0, -80 },
    { 0, -80 },
    { 70, -40 },
    { 69, -40 },
    { 0, -80 },
    { 0, -80 },
    { -70, 41 },
    { -70, 40 },
    { -69, 40 },
    { -69, 40 },
    { -69, 40 },
    { -69, 120 },
    { -69, 40 },
    { -70, 40 },
    { 0, -80 },
    { 0, -80 },
    { 0, -80 },
    { 0, -80 },
    { 0, -80 },
    { 70, -40 },
    { 69, -40 },
    { 0, -80 },
    { 0, -80 },
    { 0, -80 },
    { 0, -80 },
    { -69, 40 },
    { -70, 40 },
    "flipHorizontal",
    { 0, -80 },
    { 0, -80 },
    { 0, -80 },
    "flipHorizontal",
    { 70, -40 },
    { 0, -80 },
    { 0, -80 },
    { 0, -80 },
    { -69, 40 },
    "flipHorizontal",
    { 0, -80 },
    { 0, -80 },
    "flipHorizontal",
    { 69, -40 },
    { 0, -80 },
    { 0, -80 },
    { 0, -80 },
}

local transitions = {
    12,
    1,
    10,
    4,
    2,
    6,
    2,
    3,
    2,
    3,
    2,
    3,
    5,
    1,
    5,
    3,
    3,
    2,
    2,
    2,
    5,
    3,
    5,
    2,
    4,
    2,
    4,
    2,
    3,
    1,
    3,
    2,
    3
}

local translationIndex = 1

--- Moves the light by one window, flipping it if flipHorizontal appears.
-- @return nil
local function moveElevatorLight()
    if type(lightOffsets[translationIndex]) == "table" then
        elevatorScene.light.x = elevatorScene.light.x + lightOffsets[translationIndex][1]
        elevatorScene.light.y = elevatorScene.light.y + lightOffsets[translationIndex][2]
    elseif lightOffsets[translationIndex] == "flipHorizontal" then
        local offset = elevatorScene.light.flipHorizontal and 520 or -520
        elevatorScene.light.flipHorizontal = not elevatorScene.light.flipHorizontal
        elevatorScene.light.x = elevatorScene.light.x - offset
    end
    translationIndex = translationIndex + 1
end

elevator = {}

--- Makes the elevator light and the camera start moving.
-- @return nil
function elevator.start()
    if transitionIndex > #transitions then
        print "At the top"
        return
    end
    local totalDx, totalDy = 0, 0 --Total amount the camera will move from this function call
    for transIndex = 1, transitions[transitionIndex] do
        if lightOffsets[translationIndex + transIndex - 1] ~= "flipHorizontal" then
            totalDx = totalDx + lightOffsets[translationIndex + transIndex - 1][1]
            totalDy = totalDy + lightOffsets[translationIndex + transIndex - 1][2]
        end
    end
    local startX, startY = cam.x, cam.y
    local currentOffset = 0
    local lastOffset = 0
    local panFct = function(self, percentProgress)
        currentOffset = math.floor(math.abs(cam.y - startY) / math.abs(totalDy / transitions[transitionIndex - 1]))
        if currentOffset ~= lastOffset then
            lastOffset = currentOffset
            moveElevatorLight()
        end
    end
    cam:pan(startX - totalDx, startY - totalDy, .5 + .125 * (transitions[transitionIndex] - 1), "cos", panFct)
    locked = true
    scheduler.after(.5 + .125 * (transitions[transitionIndex] - 1), function()
        locked = false
    end)
    moveElevatorLight()
    transitionIndex = transitionIndex + 1
end

--- Returns if the elevator is locked.
-- @return If the elevator is locked.
function elevator.locked()
    return locked
end

--- Locks the elevator.
-- @return nil
function elevator.lock()
    locked = true
end

--- Unlocks the elevator.
-- @return nil
function elevator.unlock()
    locked = false
end

return elevator
