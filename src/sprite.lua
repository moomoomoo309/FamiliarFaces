tablex = tablex or require "pl.tablex"
animation = animation or require "animation"
utils = utils or require "pl.utils"
pretty = pretty or require "pl.pretty"
map = map or require "map"
object = object or require "object"

local sprite
sprite = sprite or {
    type = "sprite",
    class = sprite,
    currentId = 1,
    sprites = setmetatable({}, { __mode = "v" }), --Make sure the sprites can be garbage collected!
    spriteKeys = {},
    batches = {},
    Id = function()
        --- Returns the next available numeric id for a sprite.
        while sprite.sprites[sprite.currentId] do
            sprite.currentId = sprite.currentId + 1
        end
        return sprite.currentId
    end,
    new = function(self, args)
        --- Creates a new sprite.
        if not args and self then
            --Allows you to call sprite.new or sprite:new
            args = self
        end
        local obj = object {
            Id = (args.Id and not sprite.sprites[args.Id]) and args.Id or sprite.Id(),
            imagePath = args.imagePath or false,
            image = args.image,
            animations = args.animations or {},
            animating = false,
            visible = args.visible == nil and true or args.visible,
            x = args.x or 0,
            y = args.y or 0,
            w = args.w or 0,
            h = args.h or 0,
            ox = args.ox or 0,
            oy = args.oy or 0,
            rotation = args.rotation or 0,
            flipHorizontal = args.flipHorizontal ~= nil and args.flipHorizontal or false,
            flipVertical = args.flipVertical ~= nil and args.flipVertical or false,
            alpha = args.alpha or 255,
            color = args.color,
            filterMin = args.filterMin or "nearest",
            filterMax = args.filterMax or "nearest",
            anisotropy = args.anisotropy or 0,
            animPath = args.animPath or (args.imagePath and args.imagePath:find(".", nil, true) and args.imagePath:sub(1, -args.imagePath:reverse():find(".", nil, true)) .. "anim") or false
        }
        obj.class = sprite --Update the class (This does call the callback in object!)
        obj.sprite = sprite --Give a reference to sprite, which may be needed for children.
        if obj.imagePath then
            obj:setImagePath(obj.imagePath) --When the class was changed, so was the metatable, making its __index point to sprite.
        end
        if obj.image.setFilter then
            obj.image:setFilter(obj.filterMin, obj.filterMax, obj.anisotropy) --If for some reason, nearest isn't wanted.
        end
        for _, animation in pairs(obj.animations) do
            --Give each animation a pointer to its sprite.
            animation.sprite = obj
        end
        --Insert the sprite into sprite.sprites and sprite.spriteKeys.
        --sprite.spriteKeys remains sorted so that draw order is based on a sprite's Id.
        sprite.sprites[obj.Id] = obj
        local inserted = false
        for k in ipairs(sprite.spriteKeys) do
            if k >= obj.Id then
                --Yay, insertion sort!
                inserted = true
                table.insert(sprite.spriteKeys, k, obj.Id)
                break
            end
        end
        if not inserted then
            sprite.spriteKeys[#sprite.spriteKeys + 1] = obj.Id
        end
        return obj
    end,
    copy = function(self, that, args)
        if not args and self and that then
            --Allows you to call sprite.copy or sprite:copy
            that, args = self, that
        end
        local this = {}
        local reusableFields = { "animations" } --Tables that should be shared amongst copied sprites.
        for k, v in pairs(that) do
            --Copy that to this
            if k == "image" then
                if not args.noBatch then
                    --If true, it will not use a SpriteBatch to make copies.
                    local batches = sprite.sprite.batches
                    if not batches[sprite.imagePath] then
                        love.graphics.newSpriteBatch(sprite.image)
                    end
                    this[k] = batches[sprite.imagePath]
                else
                    this[k] = v
                end
            end
            if type(v) == "table" then
                --Make copies of tables unless they should be reused.
                if table.find(reusableFields, k) then
                    this[k] = v --Reuse certain tables
                else
                    this[k] = tablex.copy(v) --Make new copies of the rest
                end
            end
        end

        for k, v in pairs(args) do
            if k ~= "id" then
                --Do not ever create copies with the same Id.
                this[k] = v
            end
        end
        this.Id = sprite.Id()
        return this
    end,
    draw = function(self)
        if not self.visible then
            return
        end
        local img, quad
        if self.animating then
            if self.animating.frames[self.animating.currentFrame]:type() ~= "Quad" then
                img = self.animating.frames[self.animating.currentFrame] --If it's not a quad, it's a Drawable.
            else
                img = self.image
                quad = self.animating.frames[self.animating.currentFrame] --If it's a quad, say so.
            end
        else
            img = self.image --No animation.
        end
        local oldColor
        if self.animating and self.animating.currentColor or self.color then
            oldColor = { love.graphics.getColor() }
            love.graphics.setColor(self.animating.currentColor or self.color)
        end
        if quad then
            local _, _, quadWidth, quadHeight = quad:getViewport()
            self.sx = self.w / quadWidth --X scale
            self.sy = self.h / quadHeight --Y scale
            love.graphics.draw(img,
            quad,
            self.flipHorizontal and self.x + self.w - self.sx / self.w or self.x,
            self.flipVertical and self.y + self.h - self.sy / self.h or self.y + self.sy / self.h,
            math.rad(self.rotation),
            self.flipHorizontal and -self.sx or self.sx,
            self.flipVertical and -self.sy or self.sy,
            type(self.ox) == "function" and self:ox() or self.ox,
            type(self.oy) == "function" and self:oy() or self.oy)
        else
            self.sx = self.w / img:getWidth() --X scale
            self.sy = self.h / img:getHeight() --Y scale
            love.graphics.draw(img,
            self.flipHorizontal and self.x + self.image:getWidth() or self.x,
            self.flipVertical and self.y + self.image:getHeight() or self.y,
            math.rad(self.rotation),
            self.flipHorizontal and -self.sx or self.sx,
            self.flipVertical and -self.sy or self.sy,
            type(self.ox) == "function" and self:ox() or self.ox,
            type(self.ox) == "function" and self:oy() or self.oy)
        end
        if oldColor then
            love.graphics.setColor(oldColor)
        end
    end,
    drawAll = function()
        for i = 1, #sprite.spriteKeys do
            local v = sprite.spriteKeys[i]
            if sprite.sprites[v] and sprite.sprites[v].visible then
                sprite.sprites[v]:draw()
            end
        end
    end,
    updateAll = function()
        --- Runs in love.update, not love.draw!
        animation:animateAll()
    end,
    setImagePath = function(self, imagePath)
        self.imagePath = imagePath
        local spriteSheet = love.graphics.newImage(self.imagePath)
        if spriteSheet.setFilter then
            spriteSheet:setFilter(self.filterMin, self.filterMax, self.anisotropy) --If for some reason, nearest isn't wanted.
        end
        self.image = self.image or spriteSheet --If it was user-overridden, keep it!
        assert(self.imagePath, "No imagePath found for sprite!")
        local success, metaFile = false, nil
        if self.animPath and io.open(self.animPath,"r") then
            success, metaFile = pcall(function()
                return dofile(self.animPath)
            end) --Try to read the file...
        else
            return
        end
        assert(success, ("Could not execute file at %s. Is the path correct, or is the file malformed?"):format(imagePath))
        assert(type(metaFile) == "table", ("Expected table, found %s."):format(type(metaFile)))
        for name, anim in pairs(metaFile) do
            local frameSize = {}
            assert(type(anim.frameSize) == "table", ("frameSize must be a table, is a %s."):format(type(anim.frameSize)))
            if type(anim.frameSize[1]) == "table" then
                for i = 1, #anim.frameSize do
                    assert(#anim.frameSize[i] % 2 == 0, ("The frameSize for frame %d (%d) must be a multiple of two!"):format(i, #anim.frameSize[i]))
                end
                frameSize = anim.frameSize
            elseif #anim.frameSize % 2 == 0 then
                assert(#anim.frameSize % 2 == 0, ("The frameSize (%d) must be a multiple of two!"):format(#anim.frameSize))
                for i = 1, #anim.frameSize, 2 do
                    assert(type(anim.frameSize[i]) == "number", ("frameSize[%d] must be a number, is a %s."):format(i, type(anim.frameSize[i])))
                    assert(type(anim.frameSize[i + 1]) == "number", ("frameSize[%d] must be a number, is a %s."):format(i + 1, type(anim.frameSize[i + 1])))
                    frameSize[(i + 1) / 2] = { anim.frameSize[i], anim.frameSize[i + 1] }
                end
            end
            if type(anim.frameDurations) == "table" then
                assert((#anim.frameSize == 2 and type(anim.frameSize[1]) == "number") or
                #anim.frameSize == #anim.frameDurations,
                ("Mismatched frame duration (%d) and size! (%d)"):format(#anim.frameDurations, #anim.frameSize))
                assert(#anim.frameDurations == #anim.frames, ("Mismatched frame duration (%d) and count! (%d)"):format(#anim.frameDurations, #anim.frames))
            end
            if type(anim.colors) == "table" then
                assert(#anim.colors == 1 or #anim.colors == #anim.frames, ("Mismatched frame count (%d) and colors (%d)"):format(#anim.frames, #anim.colors))
            end
            if type(anim.frames) == "string" or #anim.frames > 0 then
                local frames = {}
                if type(anim.frames) == "string" then
                    frames = { love.graphics.newImage(anim.frames) }
                elseif type(anim.frames) == "table" and #anim.frames == 2 and type(anim.frames[1]) == "number" and type(anim.frames[2]) == "number" then
                    --It's in the format of {x,y} for a quad.
                    frames = {
                        love.graphics.newQuad(map(tonumber, 1,
                        anim.frames[1],
                        anim.frames[2],
                        frameSize[1][1],
                        frameSize[1][2],
                        spriteSheet:getDimensions()))
                    }
                elseif type(anim.frames) == "table" then
                    for k, frame in pairs(anim.frames) do
                        if tonumber(frame[1]) then
                            frames[#frames + 1] = love.graphics.newQuad(map(tonumber, 1,
                            frame[1],
                            frame[2],
                            frameSize[k % #frameSize + 1][1],
                            frameSize[k % #frameSize + 1][2],
                            spriteSheet:getDimensions()))
                        elseif type(frame) == "string" then
                            frames[#frames + 1] = love.graphics.newImage(frame)
                        end
                    end
                else
                    error(("Frames must be a table or string, is a %s"):format(type(anim.frames)))
                end
                self.animations[name] = animation {
                    frames = frames,
                    frameDurations = anim.frameDurations,
                    self = self,
                    colors = anim.colors,
                    sprite = sprite
                }
            end
        end
    end,
    centerOx = function(self)
        return self.flipHorizontal and -self.w / 2 / self.sx or self.w / 2 / self.sx
    end,
    centerOy = function(self)
        return self.flipVertical and -self.h / 2 / self.sy or self.h / 2 / self.sy
    end,
    type = "sprite"
}

return setmetatable(sprite, { __call = sprite.new, __index = object }) --Yay, inheritance!
