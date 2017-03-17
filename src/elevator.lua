local function cerp(start, stop, percent)
    local f = (1 - math.cos(percent * math.pi)) * .5
    return start * (1 - f) + stop * f
end

local currentTransition = {}
local transitionIndex = 1
local nextDelta = 0
local camIndex = 1
local deltaX, deltaY = 0, 0
local extLight
local building
local stopElevatorLight
local t
updateFunctions = {}
local nextTarget
spaceLocked = true
transX, transY = 0, 0
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
    8,
    5,
    2,
    4,
    2,
    4,
    2,
    3,
    1,
    2,
    1,
    1,
    1,
    3,
    0
}
local buildingTranslations
local i = 1

local function moveElevatorLight()
    if type(buildingTranslations[i]) == "table" then
        extLight.x = extLight.x + buildingTranslations[i][1]
        extLight.y = extLight.y + buildingTranslations[i][2]
    elseif buildingTranslations[i] == "flipHorizontal" then
        extLight.flipHorizontal = not extLight.flipHorizontal
        i = i + 1
        extLight.x = extLight.x + buildingTranslations[i][1]
        extLight.y = extLight.y + buildingTranslations[i][2]
    end
    i = i + 1
end

local function elevatorRise(dt)
    if #currentTransition > 0 then
        transX = currentTransition[1] + cerp(currentTransition[1], currentTransition[2], t) - currentTransition[2]
        transY = currentTransition[3] + cerp(currentTransition[3], currentTransition[4], t) - currentTransition[4]
        local currNumSteps = -(currentTransition[5] - 1) * (currentTransition[2] - currentTransition[1] > 0 and (transX - currentTransition[1]) / (currentTransition[2] - currentTransition[1]) or (transY - currentTransition[3]) / (currentTransition[4] - currentTransition[3]))
        if currNumSteps >= nextTarget and currNumSteps ~= 0 then
            moveElevatorLight()
            nextTarget = nextTarget + 1
        end
        t = t - dt / currentTransition[6]
        if t <= 0 then
            t = 1
            moveElevatorLight()
            stopElevatorLight()
        end
    end
end

function stopElevatorLight()
    spaceLocked = transitionIndex >= #transitions
    for k, v in pairs(updateFunctions) do
        if v == elevatorRise then
            table.remove(updateFunctions, k)
        end
    end
    camIndex = camIndex + currentTransition[5]
    transitionIndex = transitionIndex + 1
    currentTransition = {}
end

local function startElevatorLight()
    spaceLocked = true
    if transitionIndex >= #transitions then
        return
    end
    deltaX, deltaY = nextDelta or 0, 0
    nextDelta = 0
    local i = camIndex
    while true do
        if transitionIndex == 27 then
            deltaX = deltaX
            break
        end
        if buildingTranslations[i] == "flipHorizontal" then
            nextDelta = extLight.flipHorizontal and deltaX + extLight.w or deltaX - extLight.w
            camIndex = camIndex + 1
            break
        end
        if not buildingTranslations[i] then
            break
        end
        deltaX = deltaX + buildingTranslations[i][1]
        deltaY = deltaY + buildingTranslations[i][2]
        if i == camIndex + transitions[transitionIndex] then
            deltaX = deltaX - buildingTranslations[i][1]
            deltaY = deltaY - buildingTranslations[i][2]
            break
        end
        i = i + 1
    end
    updateFunctions[#updateFunctions + 1] = elevatorRise
    currentTransition = { transX, transX + deltaX, transY, transY + deltaY, transitions[transitionIndex], .25 + transitions[transitionIndex] / 8 }
    nextTarget = 0
    t = 1
end

local init = function(BuildingScene, BuildingTranslations)
    buildingTranslations = BuildingTranslations
    building = BuildingScene
    extLight = BuildingScene.ElevatorLight
end

local elevator = {
    init = init,
    start = startElevatorLight,
    stop = stopElevatorLight,
    iter = elevatorRise
}

return elevator