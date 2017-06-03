scene = scene or require"scene"

extLight = extLight
local scenes = {
    bathroom = function(self)
        local bathroom = scene:new "bathroom"
        scene:add("bathroom", "SinkBackground", sprite {
            w = 800,
            h = 600,
            imagePath = "assets/SinkBackground.png",
            visible = false
        })
        scene:add("bathroom", "Character", sprite {
            x = love.graphics.getWidth() / 2 - 280,
            w = 510,
            h = 740,
            imagePath = "assets/mc.png",
            visible = false
        })
        scene:add("bathroom", "Sink", sprite {
            w = 800,
            h = 600,
            imagePath = "assets/Sink.png",
            visible = false
        })
        return bathroom
    end,
    museum = function(self)
        local museum = scene:new "museum"
        scene:add("museum", "appleGuy", sprite {
            x = love.graphics.getWidth() / 2 - 130,
            y = love.graphics.getHeight() / 2 - 100,
            w = 275,
            h = 220,
            imagePath = "assets/museum_apple_guy.png",
            visible = false
        })
        scene:add("museum", "Museum", sprite {
            w = 800,
            h = 600,
            imagePath = "assets/Museum.png",
            visible = false
        })
        return museum
    end,
    building = function(self)
        local building = scene:new "building"
        scene:add("building", "building", sprite {
            x = -700 - 26,
            y = -4500,
            w = 2460,
            h = 5120,
            imagePath = "assets/OfficeExterior.png",
            visible = false
        })
        extLight = sprite {
            x = -33,
            y = 260,
            w = 450,
            h = 280,
            imagePath = "assets/OfficeElevatorLighting.png",
            visible = false
        }
        scene:add("building", "ExteriorLight", sprite {
            x = -102,
            y = 340,
            w = 520,
            h = 400,
            imagePath = "assets/OfficeEntranceLighting.png",
            visible = false
        })
        scene:add("building", "ElevatorLight", extLight)
        return building
    end
}

return scenes