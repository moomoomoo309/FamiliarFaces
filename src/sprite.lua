--- A class representing a drawable 2D object (image, text, etc.). Supports callbacks.
--- @classmod sprite

local tablex = require "pl.tablex"
local animation = require "animation"
local pretty = require "pl.pretty"
local object = require "object"
local loader = require "love-loader.love-loader"

local sprite = {
    type = "sprite",
    currentId = 1,
    sprites = setmetatable({}, { __mode = "v" }), --Make sure the sprites can be garbage collected!
    batches = {},
    groups = {},
    type = "sprite"
}
sprite.class = sprite

--- Returns the next available numeric id for a sprite.
--- @treturn number The next available numeric id for a sprite.
function sprite.Id()
    while sprite.sprites[sprite.currentId] do
        sprite.currentId = sprite.currentId + 1
    end
    return sprite.currentId
end

--- Creates a new sprite.
--- @tparam table args The arguments to the sprite, which can be:<br>
--- Id: The numeric ID of the sprite.<br>
--- imagePath: The path to the image, if it is not yet loaded.<br>
--- image: A Drawable which represents the sprite.<br>
--- group: The group the sprite will be in, or "default"<br>
--- animations: Any animations the sprite has. Should be specified in an anim file, but do not have to be for sprite reuse.<br>
--- visible: Whether or not the sprite is visible.<br>
--- x: The x coordinate of the sprite, from the top left.<br>
--- y: The y coordinate of the sprite, from the top left.<br>
--- w: The width of the sprite.<br>
--- h: The height of the sprite.<br>
--- ox: The x coordinate of where the scaling and rotation of the sprite should be about.<br>
--- oy: The y coordinate of where the scaling and rotation of the sprite should be about.<br>
--- rotation: The rotation of the sprite, in degrees.<br>
--- flipHorizontal: Whether or not the sprite is flipped horizontally.<br>
--- flipVertical: Whether or not the sprite is flipped vertically.<br>
--- alpha: The opacity of the sprite.<br>
--- color: A color overlay for the sprite.<br>
--- filterMin: How the sprite should be filtered when scaling down. Defaults to "nearest".<br>
--- filterMax: How the sprite should be filtered when scaling up. Defaults to "nearest".<br>
--- anisotropy: How many samples of anisotropic filtering the sprite should go through. Defaults to 0.<br>
--- animPath: The path to the anim file specifying the frames and animations of this sprite. Will be initialized if imagePath is specified.
--- @treturn sprite The created sprite.
function sprite:new(args)
    if not args and self then
        --Allows you to call sprite.new or sprite:new
        args = self or {}
    end
    assert(type(args) == "table", ("Table expected, got %s."):format(type(args)))
    local obj = object {
        Id = (args.Id and not sprite.sprites[args.Id]) and args.Id or sprite.Id(),
        imagePath = args.imagePath or false,
        image = args.image,
        group = args.group or "default",
        animations = args.animations or {},
        animating = false,
        visible = args.visible == nil and true or args.visible,
        x = args.x or 0,
        y = args.y or 0,
        w = args.w or 0,
        h = args.h or 0,
        ox = args.ox or 0,
        oy = args.oy or 0,
        sx = 1,
        sy = 1,
        rotation = args.rotation or 0,
        flipHorizontal = args.flipHorizontal ~= nil and args.flipHorizontal or false,
        flipVertical = args.flipVertical ~= nil and args.flipVertical or false,
        alpha = args.alpha or 255,
        color = args.color,
        filterMin = args.filterMin or "nearest",
        filterMax = args.filterMax or "nearest",
        anisotropy = args.anisotropy or 0,
        animPath = args.animPath or (args.imagePath and args.imagePath:find(".", nil, true) and args.imagePath:sub(1, -args.imagePath:reverse():find(".", nil, true)) .. "anim") or false,
        overlays = args.overlays or {},
        overlayKeys = {}
    }
    assert(obj, "Object could not be created in sprite.")
    obj.class = sprite --Update the class (This does call the callback in object!)

    obj.group = obj.group or "default" --Make sure it has a group
    sprite.groups[obj.group] = sprite.groups[obj.group] or { keys = {} }

    if obj.imagePath then
        obj:setImagePath(obj.imagePath) --When the class was changed, so was the metatable, making its __index point to sprite.
    end

    --Give each animation a pointer to its sprite.
    for _, animation in pairs(obj.animations) do
        animation.sprite = obj
    end

    --Insert the sprite into sprite.sprites and into its group's keys.
    --The keys for a given group remains sorted so that draw order is based on a sprite's Id.
    sprite.sprites[obj.Id] = obj
    local keys = sprite.groups[obj.group].keys
    local inserted = false
    for k in ipairs(keys) do
        if k >= obj.Id then
            --Yay, insertion sort!
            inserted = true
            table.insert(keys, k, obj.Id)
            break
        end
    end
    if not inserted then
        keys[#keys + 1] = obj.Id
    end


    --Attach any overlays that are present to the sprite.
    for _, overlay in pairs(obj.overlays) do
        overlay:attach(obj)
    end

    return obj
end

--- Copies that to a new sprite.
--- @tparam sprite that The sprite to copy.
--- @tparam table args If noBatch is true, it will not use a spriteBatch to copy the sprite.
--- @treturn sprite The copied sprite.
function sprite:copy(that, args)
    if not args and self and that then
        --Allows you to call sprite.copy or sprite:copy.
        that, args = self, that
    end

    assert(type(that) == "table" and that:extends "sprite", ("Sprite expected, got %s."):format(type(that) == "table" and that.type or type(that)))
    assert(type(args) == "table", ("Table expected, got %s."):format(args))

    local this = {}
    local reusableFields = { "animations" } --Tables that should be shared amongst copied sprites.
    for k, v in pairs(that) do
        --Copy that to this
        if k == "image" then
            if not args.noBatch then
                --If true, it will not use a SpriteBatch to make copies.
                local batches = sprite.batches
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
end

--- Draws the given sprite.
--- @return nil
function sprite:draw()
    self:_draw(self.x, self.y, self.w, self.h, self.rotation, self.flipHorizontal, self.flipVertical, type(self.ox) == "function" and self:ox() or self.ox, type(self.oy) == "function" and self:oy() or self.oy)
end

--- The method which actually draws the sprite internally. Used by sprite and spriteOverlay.
--- @tparam number x The x coordinate of the sprite.
--- @tparam number y The y coordinate of the sprite.
--- @tparam number w The width of the sprite.
--- @tparam number h the height of the sprite.
--- @tparam number rotation The rotation of the sprite, in degrees.
--- @tparam boolean flipHorizontal Whether or not the sprite should be flipped horizontally.
--- @tparam boolean flipVertical Whether or not the sprite should be flipped vertically.
--- @tparam number ox The x coordinate of the origin used for rotation, scaling, and other matrix transformations.
--- @tparam number oy The y coordinate of the origin used for rotation, scaling, and other matrix transformations.
--- @return nil
function sprite:_draw(x, y, w, h, rotation, flipHorizontal, flipVertical, ox, oy)
    assert(type(self) == "table" and self:extends "sprite", ("Sprite expected, got %s."):format(type(self) == "table" and self.type or type(self)))

    if not self.visible then
        return
    end

    local img, quad, currentTime, animIndex

    if self.animating then
        currentTime = love.timer.getTime()
        self.animating.currentFrame = self.animating:getIndex(currentTime)
        if self.animating.frames[self.animating.currentFrame]:type() ~= "Quad" then
            img = self.animating.frames[self.animating.currentFrame] --If it's not a quad, it's a Drawable.
        else
            img = self.image
            quad = self.animating.frames[self.animating.currentFrame] --If it's a quad, say so.
        end
    else
        img = self.image --No animation.
    end

    --If the current frame being drawn wants to have its color changed, grab the old color then change it.
    local oldColor
    if self.animating and self.animating.currentColor or self.color then
        oldColor = { love.graphics.getColor() }
        self.animating.currentColor = self.animating:getColor(currentTime, self.animating.currentFrame)
        love.graphics.setColor(self.animating.currentColor or self.color)
    end

    if quad then
        local _, _, quadWidth, quadHeight = quad:getViewport()
        self.sx = w / quadWidth --X scale
        self.sy = h / quadHeight --Y scale

        love.graphics.draw(img,
        quad,
        flipHorizontal and x + w - self.sx / w or x,
        flipVertical and y + h - self.sy / h or y + self.sy / h,
        math.rad(rotation),
        flipHorizontal and -self.sx or self.sx,
        flipVertical and -self.sy or self.sy,
        ox,
        oy)
    else
        self.sx = w / img:getWidth() --X scale
        self.sy = h / img:getHeight() --Y scale

        love.graphics.draw(img,
        flipHorizontal and x + w - self.sx / w or x,
        flipVertical and y + h - self.sy / h or y + self.sy / h,
        math.rad(rotation),
        flipHorizontal and -self.sx or self.sx,
        flipVertical and -self.sy or self.sy,
        ox,
        oy)
    end

    --Don't forget to change the color back if you changed it before!
    if oldColor then
        love.graphics.setColor(oldColor)
    end

    --Draw the overlays, if any exist.
    for i = 1, #self.overlayKeys do
        self.overlays[self.overlayKeys[i]]:draw()
    end
end

--- Draws all sprites.
--- @return nil
function sprite.drawAll()
    for k in pairs(sprite.groups) do
        sprite.drawGroup(k)
    end
end

--- Draws all sprites within the given group.
--- @tparam string group The name of the group of sprites you want to draw.
--- @return nil
function sprite.drawGroup(group)
    local spriteGroup = sprite.groups[group]
    assert(spriteGroup, ("No group with name %s found."):format(pretty.write(group)))
    for i = #spriteGroup.keys, 1, -1 do
        local key = spriteGroup.keys[i]
        if sprite.sprites[key] and sprite.sprites[key].visible then
            sprite.sprites[key]:draw()
        end
    end
end

--- Sets the imagePath of a sprite, updating its image and animations accordingly.
--- @tparam string imagePath The path to the image file.
--- @return nil
function sprite:setImagePath(imagePath)
    assert(type(imagePath) == "string", ("String expected, got %s."):format(type(imagePath)))
    if not love.filesystem.exists(imagePath) then
        return
    end
    assert(type(self) == "table" and self:extends "sprite", ("Sprite expected, got %s."):format(type(self) == "table" and self.type or type(self)))
    self.imagePath = imagePath
    local spriteSheet

    --This is so it can set a local,
    local fakeSpriteSheet = setmetatable({}, {
        __newindex = function(_, _, v)
            spriteSheet = v
        end
    })
    if loadingAssets then
        --It takes a table and a key, and since I don't want to use debug.getLocal, I have to use metatables.
        loader.newImage(fakeSpriteSheet, "ifYouSeeThisKeySomethingIsWrong", self.imagePath)

        --Wait to set the filter and image until it's finished loading everything.
        loadingCallbacks[#loadingCallbacks + 1] = function()
            if not self.image then
                self.image = spriteSheet
            end
            if spriteSheet.setFilter then
                spriteSheet:setFilter(self.filterMin, self.filterMax, self.anisotropy) --If for some reason, nearest isn't wanted.
            end
        end
    else
        spriteSheet = love.graphics.newImage(self.imagePath)
        if spriteSheet.setFilter then
            spriteSheet:setFilter(self.filterMin, self.filterMax, self.anisotropy) --If for some reason, nearest isn't wanted.
        end
    end
    self.image = self.image or spriteSheet --If it was user-overridden, keep it!
    local success, metaFile = false, nil
    if self.animPath then
        if love.filesystem.exists(self.animPath) then
            success, metaFile = pcall(function()
                return dofile(self.animPath)
            end) --Try to read the file...
        else
            self.animPath = nil
            return
        end
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
                    #anim.frameSize == #anim.frameDurations, ("Mismatched frame duration (%d) and size! (%d)"):format(#anim.frameDurations, #anim.frameSize))
            assert(#anim.frameDurations == #anim.frames, ("Mismatched frame duration (%d) and count! (%d)"):format(#anim.frameDurations, #anim.frames))
        end
        if type(anim.colors) == "table" then
            assert(#anim.colors == 1 or #anim.colors == #anim.frames, ("Mismatched frame count (%d) and colors (%d)"):format(#anim.frames, #anim.colors))
        end
        if type(anim.frames) == "string" or #anim.frames > 0 then
            local frames = {}
            if type(anim.frames) == "string" then
                frames = { (loadingAssets and loader or love.graphics).newImage(anim.frames) }
            elseif type(anim.frames) == "table" and #anim.frames == 2 and type(anim.frames[1]) == "number" and type(anim.frames[2]) == "number" then
                --It's in the format of {x,y} for a quad.
                if loadingAssets then
                    loadingCallbacks[#loadingCallbacks + 1] = function()
                        frames = {
                            love.graphics.newQuad(tonumber(anim.frames[1]),
                                tonumber(anim.frames[2]),
                                tonumber(frameSize[1][1]),
                                tonumber(frameSize[1][2]),
                                spriteSheet:getDimensions())
                        }
                    end
                else
                    frames = {
                        love.graphics.newQuad(tonumber(anim.frames[1]),
                            tonumber(anim.frames[2]),
                            tonumber(frameSize[1][1]),
                            tonumber(frameSize[1][2]),
                            spriteSheet:getDimensions())
                    }
                end
            elseif type(anim.frames) == "table" then
                for k, frame in pairs(anim.frames) do
                    if tonumber(frame[1]) then
                        if loadingAssets then
                            loadingCallbacks[#loadingCallbacks + 1] = function()
                                frames[#frames + 1] = love.graphics.newQuad(tonumber(frame[1]),
                                    tonumber(frame[2]),
                                    tonumber(frameSize[k % #frameSize + 1][1]),
                                    tonumber(frameSize[k % #frameSize + 1][2]),
                                    spriteSheet:getDimensions())
                            end
                        else
                            frames[#frames + 1] = love.graphics.newQuad(tonumber(frame[1]),
                                tonumber(frame[2]),
                                tonumber(frameSize[k % #frameSize + 1][1]),
                                tonumber(frameSize[k % #frameSize + 1][2]),
                                spriteSheet:getDimensions())
                        end
                    elseif type(frame) == "string" then
                        frames[#frames + 1] = love.graphics.newImage(frame)
                    end
                end
            else
                error(("Frames must be a table or string, is a %s"):format(type(anim.frames)))
            end
            if loadingAssets then
                loadingCallbacks[#loadingCallbacks + 1] = function()
                    self.animations[name] = animation {
                        frames = frames,
                        frameDurations = anim.frameDurations,
                        self = self,
                        colors = anim.colors,
                        sprite = sprite
                    }
                end
            else
                self.animations[name] = animation {
                    frames = frames,
                    frameDurations = anim.frameDurations,
                    self = self,
                    colors = anim.colors,
                    sprite = sprite
                }
            end
        end
    end
end

--- Returns what you would set ox to in order to rotate the sprite about its left side.
--- @treturn number What you would set ox to in order to rotate the sprite about its left side.
function sprite:leftOx()
    assert(type(self) == "table" and self:extends "sprite", ("Sprite expected, got %s."):format(type(self) == "table" and self.type or type(self)))
    return self.flipHorizontal and -self.w / self.sx or 0
end

--- Returns what you would set ox to in order to rotate the sprite about its center.
--- @treturn number What you would set ox to in order to rotate the sprite about its center.
function sprite:centerOx()
    assert(type(self) == "table" and self:extends "sprite", ("Sprite expected, got %s."):format(type(self) == "table" and self.type or type(self)))
    return self.flipHorizontal and -self.w / 2 / self.sx or self.w / 2 / self.sx
end

--- Returns what you would set ox to in order to rotate the sprite about its right side.
--- @treturn number What you would set ox to in order to rotate the sprite about its right side.
function sprite:rightOx()
    assert(type(self) == "table" and self:extends "sprite", ("Sprite expected, got %s."):format(type(self) == "table" and self.type or type(self)))
    return self.flipHorizontal and 0 or -self.w / self.sx
end

--- Returns what you would set oy to in order to rotate the sprite about its top.
--- @treturn number What you would set oy to in order to rotate the sprite about its top.
function sprite:topOy()
    assert(type(self) == "table" and self:extends "sprite", ("Sprite expected, got %s."):format(type(self) == "table" and self.type or type(self)))
    return self.flipVertical and -self.h / self.sy or 0
end

--- Returns what you would set oy to in order to rotate the sprite about its center.
--- @treturn number What you would set oy to in order to rotate the sprite about its center.
function sprite:centerOy()
    assert(type(self) == "table" and self:extends "sprite", ("Sprite expected, got %s."):format(type(self) == "table" and self.type or type(self)))
    return self.flipVertical and -self.h / 2 / self.sy or self.h / 2 / self.sy
end

--- Returns what you would set oy to in order to rotate the sprite about its bottom.
--- @treturn number What you would set oy to in order to rotate the sprite about its bottom.
function sprite:bottomOy()
    assert(type(self) == "table" and self:extends "sprite", ("Sprite expected, got %s."):format(type(self) == "table" and self.type or type(self)))
    return self.flipVertical and 0 or -self.h / self.sy
end


return setmetatable(sprite, { __call = sprite.new, __index = object })
