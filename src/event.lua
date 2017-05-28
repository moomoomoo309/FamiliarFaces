--Event subsystem
local event = event or { events = {} }
function event.register(eventName, f)
    event.events[eventName] = event.events[eventName] or {}
    local eventList = event.events[eventName]
    if type(eventList) == "table" then
        eventList[#eventList + 1] = f
    else
        eventList = { f }
    end
end

function event.pass(eventName, ...)
    event.events[eventName] = event.events[eventName] or {}
    local eventList = event.events[eventName]
    for i = 1, #eventList do
        eventList[i](...)
    end
end

function event.remove(eventName, f)
    event.events[eventName] = event.events[eventName] or {}
    local eventList = event.events[eventName]
    for i = 1, #eventList do
        if eventList[i] == f then
            table.remove(eventList, i)
        end
    end
end

function event.addDefaults(eventFct)
    --Passes mouse, keyboard, joystick, and window events when they occur
    love.mousemoved = function(...)
        eventFct("mouseMoved", ...)
    end
    love.mousepressed = function(...)
        eventFct("mousePressed", ...)
    end
    love.mousereleased = function(...)
        eventFct("mouseReleased", ...)
    end
    love.keypressed = function(...)
        eventFct("keyPressed", ...)
    end
    love.keyreleased = function(...)
        eventFct("keyReleased", ...)
    end
    love.resize = function(...)
        eventFct("windowResized", ...)
    end
    love.wheelmoved = function(...)
        eventFct("mouseWheelMoved", ...)
    end
    love.gamepadaxis = function(...)
        eventFct("axisMoved", ...)
    end
    love.joystickadded = function(...)
        eventFct("joystickConnected", ...)
    end
    love.joystickremoved = function(...)
        eventFct("joystickDisconnected", ...)
    end
    love.joystickpressed = function(...)
        eventFct("joystickPressed", ...)
    end
    love.joystickreleased = function(...)
        eventFct("joystickReleased", ...)
    end
    love.joystickhat = function(...)
        eventFct("joystickHat", ...)
    end
end

return event

