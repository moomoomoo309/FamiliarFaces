tablex = tablex or require "pl.tablex"
animation = animation or require "animation"
utils = utils or require "pl.utils"
pretty = pretty or require "pl.pretty"
map = map or require "map"

sprite = sprite or {
    currentId = -1,
    sprites = setmetatable({}, { __mode = "v" }),
    spriteKeys = {},
    batches = {},
    Id = function(self)
        self.currentId = self.currentId + 1
        return self.currentId
    end,
    new = function(self, args)
        local obj = {
            Id = args.Id or self:Id(),
            imagePath = args.imagePath or {},
            image = args.image,
            animations = args.animations or {},
            animating = false,
            visible = args.visible==nil and true or args.visible,
            lastTime = 0,
            x = args.x or 0,
            y = args.y or 0,
            w = args.w or 0,
            h = args.h or 0,
            ox = args.ox or 0,
            oy = args.oy or 0,
            rotation = args.rotation or 0,
            flipHorizontal = args.flipHorizontal or false,
            flipVertical = args.flipVertical or false,
            alpha = args.alpha or 255,
            type = "sprite"
        }
        obj.setImagePath = self.setImagePath
        if not obj.image then
            obj:setImagePath(obj.imagePath)
        end
        obj.ox = 1 / obj.image:getWidth()
        obj.oy = 1 / obj.image:getHeight()
        obj.draw = self.draw
        obj.sprite = self
        for _, animation in pairs(obj.animations) do
            animation.sprite = obj
        end
        self.sprites[obj.Id] = obj
        self.spriteKeys[#self.spriteKeys+1] = obj.Id
        table.sort(self.spriteKeys)
        return obj
    end,
    copy = function(self, that, args)
        local this = {}
        local reusableFields = { "animations" } --Tables that should be shared amongst copied sprites.
        for k, v in pairs(that) do --Copy that to this
            if k == "image" then
                if not args.noBatch then
                    local batches = self.sprite.batches
                    if not batches[self.imagePath] then
                        love.graphics.newSpriteBatch(self.image)
                    end
                    that[k] = batches[self.imagePath]
                else
                    that[k] = v
                end
            end
            if type(v) == "table" then --Make copies of tables unless they should be reused.
                if table.find(reusableFields, k) then
                    that[k] = v --Reuse certain tables
                else
                    that[k] = tablex.copy(v) --Make new copies of the rest
                end
            end
        end

        for k, v in pairs(args) do
            if k ~= "id" then --Do not ever create copies with the same Id.
                this[k] = v
            else
                this[k] = self.Id()
            end
        end
        return this
    end,
    draw = function(self)
        if not self.visible then
            return
        end
        local img, quad
        if self.animating then
            if self.animating.frames[self.animating.currentFrame]:type() ~= "Quad" then
                img = self.animating.frames[self.animating.currentFrame]
            else
                img = self.image
                quad = self.animating.frames[self.animating.currentFrame]
            end
        else
            img = self.image
        end
        local sx = self.w / img:getWidth()
        local sy = self.h / img:getHeight()
        if quad then
            local _, _, quadWidth, quadHeight = quad:getViewport()
            love.graphics.draw(img,
                quad,
                self.flipHorizontal and self.x + self.w * (quadWidth * self.ox) or self.x,
                self.flipVertical and self.y + self.h * (quadHeight * self.oy) or self.y,
                math.rad(self.rotation),
                self.flipHorizontal and -sx or sx,
                self.flipVertical and -sy or sy,
                self.ox,
                self.oy)
        else
            love.graphics.draw(img,
                self.flipHorizontal and self.x + self.w * (self.image:getWidth() * self.ox) or self.x,
                self.flipVertical and self.y + self.h * (self.image:getHeight() * self.oy) or self.y,
                math.rad(self.rotation),
                self.flipHorizontal and -sx or sx,
                self.flipVertical and -sy or sy,
                self.ox,
                self.oy)
        end
    end,
    drawSprites = function(self)
        local keys = tablex.keys(self.sprites)
        table.sort(keys)
        for _,v in pairs(keys) do
            if self.sprites[v].visible then
                self.sprites[v]:draw()
            end
        end
        animation:animate()
    end,
    setImagePath = function(self, imagePath)
        self.image = love.graphics.newImage(self.imagePath)
        local metaPath = self.imagePath:sub(0, -self.imagePath:reverse():find(".", nil, true)) .. "meta"
        local success, metaFile = pcall(function() return utils.readfile(metaPath) end)
        local cnt = 1
        if success and metaFile then
            metaFile = pretty.read(metaFile)
            for name, anim in pairs(metaFile) do
                local frameSize
                if #anim.frameSize == 2 then
                    frameSize = anim.frameSize
                else
                    frameSize = anim.frameSize[cnt]
                    cnt = cnt + 1
                end
                if type(anim.frameDurations) == "table" then
                    assert(#anim.frameDurations == #anim.frames, "Mismatched frame duration and count!")
                end
                if #anim.frames > 0 then
                    if type(anim.frames[1]) == "table" then
                        local frames = {}
                        for _, frame in pairs(anim.frames) do
                            if tonumber(frame[1]) then
                                frames[#frames + 1] = love.graphics.newQuad(map(tonumber, 1,
                                    frame[1],
                                    frame[2],
                                    frameSize[1],
                                    frameSize[2],
                                    self.image:getDimensions()))
                            end
                        end
                        self.animations[name] = animation {
                            frames = frames,
                            frameDurations = anim.frameDurations,
                            sprite = self
                        }
                    else
                        self.animations[name] = animation {
                            frames = map(love.graphics.newImage, 1, unpack(anim.frames)),
                            frameDurations = anim.frameDurations,
                            sprite = self
                        }
                    end
                end
            end
        end
    end
}

setmetatable(sprite, { __call = sprite.new})

return sprite