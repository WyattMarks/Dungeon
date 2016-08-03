local tile = {}
tile.tileSize = 40
tile.type = "tile"

function tile:load()
	self.texture = love.graphics.newImage("assets/tiles.png")
	self.texture:setFilter("nearest", "nearest")
	self.textureWidth, self.textureHeight = self.texture:getDimensions()

	local variant = math.random(1,4)
	self.brick = {type = 'brick', quad = love.graphics.newQuad(1, 1 + (tile.tileSize+2) * (variant-1), self.tileSize, self.tileSize, self.textureWidth, self.textureHeight )}
	variant = math.random(1,4)
	self.wood = {type = 'wood', quad = love.graphics.newQuad(43, 1 + (tile.tileSize+2) * (variant-1), self.tileSize, self.tileSize, self.textureWidth, self.textureHeight )}
end

function tile:reloadQuad(new)
	local variant = math.random(1,4)

	if new.type == "wood" then
		new.quad = love.graphics.newQuad(43, 1 + (tile.tileSize+2) * (variant-1), self.tileSize, self.tileSize, self.textureWidth, self.textureHeight)
	elseif new.type == 'brick' then
		new.quad = love.graphics.newQuad(1, 1 + (tile.tileSize+2) * (variant-1), self.tileSize, self.tileSize, self.textureWidth, self.textureHeight )
	end
end

function tile:new(name)
	local new = util:copyTable(self[name])

	self:reloadQuad(new)

	return new
end


return tile