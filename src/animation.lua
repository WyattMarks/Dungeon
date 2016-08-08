local animation = {}
animation.image = {}
animation.curFrame = 1
animation.frames = 4
animation.frameWidth = 7
animation.frameHeight = 13
animation.frameLength = .5
animation.quads = {}
animation.time = 0
animation.scale = 2

local animMeta = { __index = animation }

function animation:new(image, frames, frameLength, frameWidth, frameHeight)
	local new = setmetatable({}, animMeta)
    new.image = love.graphics.newImage(image)
    new.frames = frames or self.frames
    new.frameWidth = frameWidth or self.frameWidth
    new.frameHeight = frameHeight or self.frameHeight
    new.frameLength = frameLength or self.frameLength

    new:genQuads()
    new.spritebatch = love.graphics.newSpriteBatch(new.image, 1)
    new.spriteID = new.spritebatch:add(self.quads[1])

	return new
end

function animation:genQuads()
    for i=1, self.frames do
        local framesPerRow = (self.image:getWidth() / (self.frameWidth + 2))
        local y = math.floor( math.max(0, i-1) / framesPerRow )

        print(i, (i-1) * self.frameWidth + 1, y * (self.frameHeight + 2) + 1)
        self.quads[i] = love.graphics.newQuad((i-1) * self.frameWidth + i * 2 - 1, y * (self.frameHeight + 2) + 1, self.frameWidth, self.frameHeight, self.image:getDimensions())
    end
end

function animation:update(dt)
    self.time = self.time + dt
    if self.time >= self.frameLength then
        self.time = self.time - self.frameLength

        self.curFrame = self.curFrame + 1

        if self.curFrame > self.frames then
            self.curFrame = 1
        end
        self.spritebatch:set(self.spriteID, self.quads[self.curFrame], 1, 1)
    end
end

function animation:draw(x, y)
    love.graphics.setColor(255,255,255)
    love.graphics.draw(self.spritebatch, x - 1, y - 1, 0, self.scale, self.scale)
end


return animation