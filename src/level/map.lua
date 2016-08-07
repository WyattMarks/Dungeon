Dungeon = require("src/level/Dungeon")

local map = {}
map.tiles = {}
map.rooms = {}
map.halls = {}
map.height = 0
map.width = 0 
map.horizontalBorder = 8
map.verticalBorder = 5

function map:load()
	self.tiles = {}
	world = bump.newWorld(64)
	tile:load()
end

function map:spawnEnemies()
	for k,room in pairs(self.rooms) do
		for i=0,math.random(0,3) do
			local x = math.random(room.x, room.x + room.width-1) * tile.tileSize
			local y = math.random(room.y, room.y + room.height-1) * tile.tileSize

			game:addEntity( enemy:new(x, y) )
		end
	end
end

function map:generateBorder()
	self.borderTiles = {}

	--Left side
	for x=-self.horizontalBorder + 1, 0 do
		self.borderTiles[x] = self.borderTiles[x] or {}
		for y=-self.verticalBorder, self.height + self.verticalBorder do
			self.borderTiles[x][y] = tile:new("brick")
			self.borderTiles[x][y].spriteID = self.spriteBatch:add(self.borderTiles[x][y].quad, x * tile.tileSize, y * tile.tileSize )
			self.borderTiles[x][y].x = x
			self.borderTiles[x][y].y = y
			world:add(self.borderTiles[x][y], x * tile.tileSize, y * tile.tileSize, tile.tileSize, tile.tileSize)
		end
	end

	--Right side
	for x=self.width + 1, self.horizontalBorder + self.width - 1 do
		self.borderTiles[x] = self.borderTiles[x] or {}
		for y=-self.verticalBorder, self.height + self.verticalBorder do
			self.borderTiles[x][y] = tile:new("brick")
			self.borderTiles[x][y].spriteID = self.spriteBatch:add(self.borderTiles[x][y].quad, x * tile.tileSize, y * tile.tileSize )
			self.borderTiles[x][y].x = x
			self.borderTiles[x][y].y = y
			world:add(self.borderTiles[x][y], x * tile.tileSize, y * tile.tileSize, tile.tileSize, tile.tileSize)
		end
	end

	--Top
	for x=1, self.width do
		self.borderTiles[x] = self.borderTiles[x] or {}
		for y = -self.verticalBorder + 1, 0 do
			self.borderTiles[x][y] = tile:new("brick")
			self.borderTiles[x][y].spriteID = self.spriteBatch:add(self.borderTiles[x][y].quad, x * tile.tileSize, y * tile.tileSize )
			self.borderTiles[x][y].x = x
			self.borderTiles[x][y].y = y
			world:add(self.borderTiles[x][y], x * tile.tileSize, y * tile.tileSize, tile.tileSize, tile.tileSize)
		end
	end

	--Bottom
	for x=1, self.width do
		for y = self.height + 1, self.height + self.verticalBorder do
			self.borderTiles[x][y] = tile:new("brick")
			self.borderTiles[x][y].spriteID = self.spriteBatch:add(self.borderTiles[x][y].quad, x * tile.tileSize, y * tile.tileSize )
			self.borderTiles[x][y].x = x
			self.borderTiles[x][y].y = y
			world:add(self.borderTiles[x][y], x * tile.tileSize, y * tile.tileSize, tile.tileSize, tile.tileSize)
		end
	end
end

function map:generate()
	Dungeon:generate()
	local top, left, bottom, right = 0,0,0,0
	for k,room in pairs(Dungeon.rooms) do
		if room.y < top then top = room.y end
		if room.y + room.height * tile.tileSize > bottom then bottom = room.y + room.height * tile.tileSize end
		if room.x < left then left = room.x end
		if room.x + room.width * tile.tileSize > right then right = room.x + room.width * tile.tileSize end
	end

	for x=1, (right-left)/tile.tileSize do
		if not self.tiles[x] then self.tiles[x] = {} end
		for y=1, (bottom-top)/tile.tileSize do
			self.tiles[x][y] = tile:new("brick")
		end
	end

	for k,room in pairs(Dungeon.rooms) do
		local x = (room.x - left)/tile.tileSize+1
		local y = (room.y - top)/tile.tileSize+1

		self.rooms[#self.rooms+1] = {x = x, y = y, width = room.width, height = room.height}

		for w=0, room.width-1 do
			for h=0, room.height-1 do
				if self.tiles[x + w] and self.tiles[x + w][y + h] then
					self.tiles[x + w][y + h] = tile:new("wood")
				end
			end
		end
	end

	for k,hall in pairs(Dungeon.halls) do
		local x = (hall.x - left)/tile.tileSize+1
		local y = (hall.y - top)/tile.tileSize+1

		self.halls[#self.halls+1] = {x = x, y = y, width = hall.width, height = hall.height}

		for w=0, hall.width-1 do
			for h=0, hall.height-1 do
				self.tiles[x + w][y + h] = tile:new("wood")
			end
		end
	end

	self.spriteBatch = love.graphics.newSpriteBatch(tile.texture, (#self.tiles + self.horizontalBorder * 2 + 1) * (#self.tiles[2] + self.verticalBorder * 2))

	for x=1, #self.tiles do
		for y=1, #self.tiles[2] do
			self.tiles[x][y].spriteID = self.spriteBatch:add(self.tiles[x][y].quad, x * tile.tileSize, y * tile.tileSize )
			self.tiles[x][y].x = x
			self.tiles[x][y].y = y 
			if self.tiles[x][y].type == 'brick' then
				world:add(self.tiles[x][y], x * tile.tileSize, y * tile.tileSize, tile.tileSize, tile.tileSize)
			end
		end
	end

	self.width = #self.tiles
	self.height = #self.tiles[2]
	self.spawnRoom = self.rooms[math.random(1,#self.rooms)]
	self:generateBorder()
	self.loaded = true
	--self:generateLightWorld()
end

function map:update(dt)
	if self.lightWorld then
		self.lightWorld:setTranslation(-camera.x + love.graphics.getWidth()/2, -camera.y + love.graphics.getHeight()/2)
		self.lightWorld:update(dt)
	end
end

function map:draw()
	if self.loaded then
		love.graphics.setColor(255,255,255)
		love.graphics.draw(self.spriteBatch, 0, 0)

		love.graphics.rectangle('line', 0, 0, self.width * 40, self.height * 40)
	end
end

function map:getNetworkedMap()
	local toSend = {}
	toSend.rooms = self.rooms
	toSend.halls = self.halls
	toSend.height = self.height
	toSend.width = self.width

	return toSend
end

function map:loadFromNetworkedMap(toLoad)

	self.width = toLoad.width
	self.height = toLoad.height

	for x=1, toLoad.width do
		if not self.tiles[x] then self.tiles[x] = {} end
		for y=1, toLoad.height do
			self.tiles[x][y] = tile:new("brick")
		end
	end

	for k,room in pairs(toLoad.rooms) do
		local x = room.x
		local y = room.y

		self.rooms[k] = {x = x, y = y, width = room.width, height = room.height}

		for w=0, room.width-1 do
			for h=0, room.height-1 do
				if self.tiles[x + w] and self.tiles[x + w][y + h] then
					self.tiles[x + w][y + h] = tile:new("wood")
				end
			end
		end
	end

	for k,hall in pairs(toLoad.halls) do
		local x = hall.x
		local y = hall.y

		self.halls[k] = {x = x, y = y, width = hall.width, height = hall.height}

		for w=0, hall.width-1 do
			for h=0, hall.height-1 do
				if self.tiles[x + w] and self.tiles[x + w][y + h] then
					self.tiles[x + w][y + h] = tile:new("wood")
				end
			end
		end
	end

	self.spriteBatch = love.graphics.newSpriteBatch(tile.texture, #self.tiles * #self.tiles[2])

	for x=1, #self.tiles do
		for y=1, #self.tiles[2] do
			self.tiles[x][y].spriteID = self.spriteBatch:add(self.tiles[x][y].quad, x * tile.tileSize, y * tile.tileSize )
			self.tiles[x][y].x = x
			self.tiles[x][y].y = y 
			if self.tiles[x][y].type == 'brick' then
				world:add(self.tiles[x][y], x * tile.tileSize, y * tile.tileSize, tile.tileSize, tile.tileSize)
			end
		end
	end

	self.loaded = true
	--self:generateLightWorld()

	self:generateBorder()
end

function map:generateLightWorld()
	self.lightWorld = LightWorld({
		ambient = {5,5,5},
	})

	self.lightWorld.rectangles = {}

	local rectangles = {}

	for x=1, self.width do
		local rectangle = {width = 1, x = x}
		for y=1, self.height do
			if self.tiles[x][y].type == "brick" then
				if not rectangle.y then
					rectangle.y = y
					rectangle.height = 1
				else
					rectangle.height = rectangle.height + 1
				end
			else
				if rectangle.y then
					local lastRect

					for i=1, #rectangles do
						local old = rectangles[i]
						if old.y == rectangle.y and old.height == rectangle.height and old.x + old.width == rectangle.x then
							lastRect = old
						end
					end

					if lastRect then
						lastRect.width = lastRect.width + 1
						rectangle = {width = 1, x = x}
					else
						rectangles[#rectangles + 1] = rectangle
						rectangle = {width = 1, x = x}
					end
				end
			end
		end

		if rectangle.y then
			local lastRect

			for i=1, #rectangles do
				local old = rectangles[i]
				if old.y == rectangle.y and old.height == rectangle.height then
					lastRect = old
				end
			end

			if lastRect then
				lastRect.width = lastRect.width + 1
				rectangle = {width = 1, x = x}
			else
				rectangles[#rectangles + 1] = rectangle
				rectangle = {width = 1, x = x}
			end
		end
	end

	for i=1, #rectangles do
		local rectangle = rectangles[i]
		local rX = rectangle.x*tile.tileSize + rectangle.width / 2 * tile.tileSize
		local rY = rectangle.y * tile.tileSize + rectangle.height / 2 * tile.tileSize
		table.insert(self.lightWorld.rectangles, self.lightWorld:newRectangle(rX, rY, rectangle.width*tile.tileSize, tile.tileSize*rectangle.height))
	end

	self.lightWorld:setTranslation(-camera.x + love.graphics.getWidth()/2, -camera.y + love.graphics.getHeight()/2)
end


return map