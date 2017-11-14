--- A class which is used to draw sprites relative to others. Inherits from sprite. Could be used to overlay clothing on a sprite or a rotating arm, for example.
--- @classmod spriteOverlay
--- @see sprite

local sprite = require "sprite"

local spriteOverlay = { type = "spriteOverlay" }
spriteOverlay.class = spriteOverlay

--- Creates a spriteOverlay. Can take the form of a sprite or the args table that would be passed to a sprite.
--- @tparam table|sprite spriteInstOrArgs Either a sprite to be turned into a spriteOverlay or the args table used to make a sprite.
--- @tparam sprite|nil parent (Optional) The parent of the spriteOverlay.
--- @return The created spriteOverlay.
function spriteOverlay:new(spriteInstOrArgs, parent)
    local args, spriteInst
    assert(type(spriteInstOrArgs) == "table", ("Table expected, got %s."):format(type(spriteInstOrArgs)))
    if spriteInstOrArgs.extends and spriteInstOrArgs:extends "sprite" then
        spriteInst = spriteInstOrArgs
    else
        args = spriteInstOrArgs
        parent = parent and parent or args.parent
        spriteInst = sprite:new(args) --If it's not a sprite, assume it's an args table to create a sprite.
    end
    assert(spriteInst:extends "sprite", ("Sprite expected, got %s."):format(type(spriteInst) == "table" and spriteInst.type or type(spriteInst)))

    --Don't allow the sprite class to be messed with.
    assert(spriteInst.class == sprite, "Cannot create spriteOverlay from sprite class, must be an instance!")

    if parent then
        spriteInst.parent = parent
    end
    spriteInst.group = "overlay" --Make sure it doesn't get drawn by default.
    spriteInst.class = spriteOverlay
    return spriteInst
end

--- Attaches this spriteOverlay onto the given sprite. Will error if a sprite is already attached.
--- @tparam sprite sprite The sprite this spriteOverlay should be attached to.
--- @tparam string|number key The key used when inserting this into its parent.
--- @return nil
function spriteOverlay:attach(parent, key)
    assert(self ~= spriteOverlay, ("Cannot modify class!"))
    if self.parent then
        self:detach()
    end
    parent.overlays = parent.overlays or {}
    parent.overlayKeys = parent.overlayKeys or {}
    key = key or #parent.overlays + 1
    parent.overlays[key] = parent

    --Add to the keys using insertion sort.
    for i = 1, #parent.overlayKeys do
        if parent.overlayKeys[i] > key then
            table.insert(parent.overlayKeys, i, key)
        elseif i == #parent.overlayKeys then
            parent.overlayKeys[i + 1] = key
        end
    end

    self.parent = parent
end

--- Detaches this spriteOverlay from the sprite it's currently attached to. Will error if no sprite is attached.
--- @return nil
function spriteOverlay:detach()
    assert(self.parent, "SpriteOverlay cannot detach, has no parent!")
    local parent = self.parent
    for key, overlay in parent.overlays do
        if overlay == self then
            table.remove(parent.overlays, key)
            break
        elseif not next(parent.overlays, key) then
            error(("spriteOverlay (ID#%d) is not attached correctly to its parent (ID#%d)."):format(self.Id, parent.Id))
        end
    end
    self.parent = nil
end

--- Draws this spriteOverlay using the same drawing behavior as sprite._draw, but uses values relative to the parent.<br>
--- x, y, and rotation are additive (self value + parent value),<br>
--- w and h are multiplicative (self value * parent value),<br>
--- flipHorizontal and flipVertical are XOR'd (self value ~= parent value),<br>
--- ox and oy are multiplied by the spriteOverlay's width/height after multiplication (self value * w/h).
--- @return nil
function spriteOverlay:draw()
    local x, y, w, h, rotation, flipHorizontal, flipVertical, ox, oy
    local parent = self.parent
    assert(parent, ("Sprite Overlay \"%s\" has no parent!"):format(self.imagePath))
    x = self.x + parent.x
    y = self.y + parent.y
    w = self.w * parent.w
    h = self.h * parent.h
    rotation = self.rotation + parent.rotation
    flipHorizontal = self.flipHorizontal ~= parent.flipHorizontal
    flipVertical = self.flipVertical ~= parent.flipVertical
    ox = self.ox * w / self.sx
    oy = self.oy * h / self.sy

    --_draw is inherited from sprite.
    return self:_draw(x, y, w, h, rotation, flipHorizontal, flipVertical, ox, oy)
end

return setmetatable(spriteOverlay, { __index = sprite, __call = spriteOverlay.new })
