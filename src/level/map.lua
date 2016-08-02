Dungeon = require("src/level/Dungeon")

local map = {}
map.tiles = {}
map.rooms = {}
map.halls = {}
map.height = 0
map.width = 0 

function map:load()
	self.tiles = {}
	world = bump.newWorld(64)
	tile:load()
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

	self.width = #self.tiles
	self.height = #self.tiles[2]
	self.spawnRoom = self.rooms[math.random(1,#self.rooms)]
	self.loaded = true
	self:generateLightWorld()
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
	end
end

function map:getNetworkedMap()
	local toSend = {}
	toSend.rooms = self.rooms
	toSend.halls = self.halls
	toSend.height = self.height
	toSend.width = self.width

	return Tserial.pack(toSend, false, false)
end

function map:loadFromNetworkedMap(toLoad)
	toLoad = Tserial.unpack(toLoad)

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
	self:generateLightWorld()
end

function map:generateLightWorld()
	self.lightWorld = LightWorld({
		ambient = {10,10,10},
	})

	self.lightWorld.rectangles = {}

	for x=1, self.width do
		for y=1, self.height do
			if self.tiles[x][y].type == "brick" then
				table.insert(self.lightWorld.rectangles, self.lightWorld:newRectangle(x*tile.tileSize + tile.tileSize/2, y*tile.tileSize + tile.tileSize/2, tile.tileSize, tile.tileSize))
			end
		end
	end

	self.lightWorld.l = -camera.x + love.graphics.getWidth()/2
    self.lightWorld.t = -camera.y + love.graphics.getHeight()/2
end


return map