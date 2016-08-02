local tile = {}
tile.tileSize = 40

function tile:load()
	self.texture = love.graphics.newImage("assets/tiles.png")
	self.texture:setFilter("nearest", "nearest")
	self.textureWidth, self.textureHeight = self.texture:getDimensions()

	self.brick = {type = 'brick', quad = love.graphics.newQuad(0, 0, self.tileSize, self.tileSize, self.textureWidth, self.textureHeight )}
	self.wood = {type = 'wood', quad = love.graphics.newQuad(40, 0, self.tileSize, self.tileSize, self.textureWidth, self.textureHeight )}
end

function tile:new(name)
	local new = util:copyTable(self[name])

	return new
end


return tile