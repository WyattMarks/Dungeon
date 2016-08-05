local player = {}
player.x = 0
player.y = 0
player.width = 15
player.height = 20
player.speed = 192
player.bulletSpeed = 200
player.fireRate = 0.15
player.health = 100
player.name = "player"
player.type = "player"
player.xvel = 0
player.yvel = 0


local playerMeta = { __index = player }

function player:new()
	local new = setmetatable({}, playerMeta)

	return new
end


function player:draw()
	love.graphics.setColor(50,50,205)
	love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)

	love.graphics.setColor(205,50,50)
	love.graphics.rectangle('fill', self.x, self.y - 10, self.width, 5)
	love.graphics.setColor(50,205,50)
	love.graphics.rectangle('fill', self.x, self.y - 10, self.health/100 * self.width, 5)
end

function player:filter(other)
	if other.owner == self.id then
		return false
	else
		return "slide"
	end
end

function player:update(dt)
    --[[
	if game.map.lightWorld and not self.light then 
		self.light = game.map.lightWorld:newLight(self.x + self.width/2, self.y+self.height/2, 100, 140, 180, 300)
		self.light:setGlowStrength(0.3)
	end

	local xMove, yMove = self.x + self.xvel * dt, self.y + self.yvel * dt

	self.x, self.y, cols, len = world:move(self, xMove, yMove, self.filter)
	
	if self.light then self.light:setPosition(self.x+self.width/2, self.y+self.height/2, 1) end

	--]]
	if game.debug and self.isLocal then 
		game.debug:add("X/Y", tostring(math.floor( (self.x + self.width / 2) / tile.tileSize)).."/"..tostring(math.floor( (self.y + self.height / 2) / tile.tileSize)))
	end
end

function player:shoot(x, y)
	x, y = camera:worldCoords(x,y)
	local pX, pY = self.x + self.width / 2 - bullet.width / 2, self.y + self.height / 2 - bullet.height / 2
	local angle = math.atan2(x - pX, y - pY)
    local xvel = self.bulletSpeed * math.sin(angle)
    local yvel = self.bulletSpeed * math.cos(angle)

    -- this makes it hard to aim, my bad
    --[[
	if math.abs(xvel + self.xvel) > math.abs(xvel) then
		xvel = xvel + self.xvel
	end

	if math.abs(yvel + self.yvel) > math.abs(yvel) then
		yvel = yvel + self.yvel
	end
	--]]

	local toSend = {x = pX, y = pY, xvel = xvel, yvel = yvel}
	client:send("SHOOT", toSend)
end

function player:load()
	world:add(self, self.x, self.y, self.width, self.height)
end

function player:die()
	local spawnRoom = game.map.spawnRoom
	self.health = 100
	self.x = (spawnRoom.x + spawnRoom.width * 0.5) * tile.tileSize
	self.y = (spawnRoom.y + spawnRoom.height * 0.5) * tile.tileSize
	world:update(self, self.x, self.y)
	server:send(self, "MOVE", {self.x, self.y})
end

return player
