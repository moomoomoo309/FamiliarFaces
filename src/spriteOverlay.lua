--- A class which is used to draw sprites relative to others. Inherits from sprite. Could be used to overlay clothing on a sprite or a rotating arm, for example.
-- @classmod spriteOverlay
-- @see sprite

sprite = require "sprite"

local spriteOverlay = { type = "spriteOverlay" }
spriteOverlay.class = spriteOverlay

--- Creates a spriteOverlay. Can take the form of a sprite or the args table that would be passed to a sprite.
-- @param spriteInstOrArgs Either a sprite to be turned into a spriteOverlay or the args table used to make a sprite.
-- @return The created spriteOverlay.
function spriteOverlay:new(spriteInstOrArgs)
    local args, spriteInst
    assert(type(spriteInstOrArgs) == "table", ("Table expected, got %s."):format(type(spriteInstOrArgs)))
    if spriteInstOrArgs:extends "sprite" then
        spriteInst = spriteInstOrArgs
    else
        args = spriteInstOrArgs
        spriteInst = sprite:new(spriteInstOrArgs) --If it's not a sprite, assume it's an args table to create a sprite.
    end
    assert(spriteInst.type == "sprite", ("Sprite expected, got %s."):format(type(spriteInst) == "table" and spriteInst.type or type(spriteInst)))

    --Don't allow the sprite class to be messed with.
    assert(sprite.class == sprite, "Cannot create spriteOverlay from sprite class, must be an instance!")

    return setmetatable(sprite, { __index = spriteOverlay })
end

--- Attaches this spriteOverlay onto the given sprite. Will error if a sprite is already attached.
-- @param sprite The sprite this spriteOverlay should be attached to.
-- @return nil
function spriteOverlay:attach(sprite)
    assert(not self.parent, "SpriteOverlay cannot attach, already has a parent!")
    sprite.overlays[#sprite.overlays + 1] = sprite
    self.parent = sprite
end

--- Detached this spriteOverlay from the sprite it's currently attached to. Will error if no sprite is attached.
-- @return nil
function spriteOverlay:detach()
    assert(self.parent, "SpriteOverlay cannot detach, has no parent!")
    local sprite = self.parent
    for i = 1, #sprite.overlays do
        if sprite.overlays[i] == self then
            table.remove(sprite.overlays, i)
            break
        elseif i == #sprite.overlays then
            print(("Warning: spriteOverlay (ID#%d) is not attached correctly to its parent (ID#%d)."):format(self.Id, sprite.Id))
        end
    end
    self.parent = nil
end

--- Draws this spriteOverlay using the same drawing behavior as sprite._draw, but uses values relative to the parent.<br>
-- x, y, and rotation are additive (self value + parent value),<br>
-- w and h are multiplicative (self value * parent value),<br>
-- flipHorizontal and flipVertical are XOR'd (self value ~= parent value),<br>
-- ox and oy are multiplied by the spriteOverlay's width/height after multiplication (self value * w/h).
-- @return nil
function spriteOverlay:draw()
    local x, y, w, h, rotation, flipHorizontal, flipVertical, ox, oy
    local parent = self.parent
    x = self.x + parent.x
    y = self.y + parent.y
    w = self.w * parent.w
    h = self.h * parent.h
    rotation = self.rotation + parent.rotation
    flipHorizontal = self.flipHorizontal ~= parent.flipHorizontal
    flipVertical = self.flipVertical ~= parent.flipVertical
    ox = self.ox * w
    oy = self.oy * h

    --It might seem a bit weird that it's calling sprite's _draw method, but the drawing part is the same, only the
    --parameters are changing, so doing this decreases the code's "surface area".
    --I also could have done self:draw here, but I wanted to make it explicit it's inheriting behavior from sprite.
    return sprite._draw(self, x, y, w, h, rotation, flipHorizontal, flipVertical, ox, oy)
end

return setmetatable(spriteOverlay, { __index = sprite })