local animation = {}
animation.image = {}
animation.curFrame = 1
animation.frames = 4
animation.frameWidth = 9
animation.frameHeight = 15
animation.frameLength = .5
animation.quads = {}
animation.time = 0
animation.scale = 2
animation.dir = 1

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
	new.spritebatch:set(new.spriteID, new.quads[1], 1, 1)

	return new
end

function animation:genQuads()
	local framesPerRow = self.image:getWidth() / self.frameWidth

	for i=1, self.frames do
		local y = (math.ceil(i / framesPerRow) - 1) * self.frameHeight + 1
		local x = (i-1) * self.frameWidth + 1

		self.quads[i] = love.graphics.newQuad(x, y, self.frameWidth, self.frameHeight, self.image:getDimensions())
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

function animation:draw(x, y, xscale, yscale)
	xscale = self.scale * (xscale or 1) * self.dir
	yscale = self.scale * (yscale or 1)

	if self.dir == -1 then
	   x = x + self.frameWidth * math.abs(xscale)
	end

	love.graphics.setColor(255,255,255)
	love.graphics.draw(self.spritebatch, x-self.scale, y-self.scale, 0, xscale, yscale)
end


return animation