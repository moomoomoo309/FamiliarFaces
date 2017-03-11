--It begins.
io.stdout:setvbuf"no" --Makes printing not buffer, so it prints instantly.

abstractions = require"abstractions"
event = require"event"

abstractions:generateEvents(event.pass)
local mousePosX,mousePosY=0,0
local w,h=50,50
local avgColorsPerSecond=1
event.register("mouseMoved",function(x,y) mousePosX,mousePosY=x,y end)
function love.update(dt)
	if math.random(0,1/(dt*avgColorsPerSecond))<1 then
		abstractions.setColor(math.random(0,255),math.random(0,255),math.random(0,255))
	end
end

function love.draw()
	abstractions.rect(mousePosX-w/2,mousePosY-h/2,w,h)
end
