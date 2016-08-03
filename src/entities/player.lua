local player = {}
player.x = 0
player.y = 0
player.width = 15
player.height = 20
player.speed = 192
player.bulletSpeed = 200
player.health = 100
player.name = "player"
player.type = "player"
player.xvel = 0
player.yvel = 0

function player:draw()
	love.graphics.setColor(50,50,205)
	love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)

	love.graphics.setColor(205,50,50)
	love.graphics.rectangle('fill', self.x, self.y - 10, self.width, 5)
	love.graphics.setColor(50,205,50)
	love.graphics.rectangle('fill', self.x, self.y - 10, self.health/100 * self.width, 5)
end

function player:filter(other)
	if other.owner == self then
		return false
	else
		return "slide"
	end
end

function player:update(dt)
	if not self.peer then
		game:checkToLoad(self)
	end

	if game.map.lightWorld and not self.light then 
		self.light = game.map.lightWorld:newLight(self.x + self.width/2, self.y+self.height/2, 100, 140, 180, 600)
		self.light:setGlowStrength(0.3)
	end

	local xMove, yMove = self.x, self.y
	if self.right then
		xMove = xMove + self.speed * dt
		self.xvel = self.speed
	elseif self.left then
		xMove = xMove - self.speed * dt
		self.xvel = -self.speed
	else
		self.xvel = 0
	end

	if self.up then
		yMove = yMove - self.speed * dt
		self.yvel = -self.speed
	elseif self.down then
		yMove = yMove + self.speed * dt
		self.yvel = self.speed
	else
		self.yvel = 0
	end

	self.x, self.y, cols, len = world:move(self, xMove, yMove, self.filter)
	
	if self.light then self.light:setPosition(self.x+self.width/2, self.y+self.height/2, 1) end
end

function player:new()
	local new = util:copyTable(self)
	return new
end

function player:shoot(x, y)
	x, y = camera:worldCoords(x,y)
	local pX, pY = self.x + self.width / 2 - bullet.width / 2, self.y + self.height / 2 - bullet.height / 2
	local angle = math.atan2(x - pX, y - pY)
    local xvel = self.bulletSpeed * math.sin(angle)
    local yvel = self.bulletSpeed * math.cos(angle)

	if math.abs(xvel + self.xvel) > math.abs(xvel) then
		xvel = xvel + self.xvel
	end

	if math.abs(yvel + self.yvel) > math.abs(yvel) then
		yvel = yvel + self.yvel
	end

	local toSend = {x = pX, y = pY, xvel = xvel, yvel = yvel}
	client:send("SHOOT"..Tserial.pack(toSend, false, false))
end

function player:load()
	world:add(self, self.x, self.y, self.width, self.height)
end

function player:die()
	self.health = 100
	self.x = game.map.spawnRoom.x * tile.tileSize + game.map.spawnRoom.width * tile.tileSize / 2
	self.y = game.map.spawnRoom.y * tile.tileSize + game.map.spawnRoom.height * tile.tileSize / 2
	world:update(self, self.x, self.y)
	self.peer:send("MOVE"..Tserial.pack({self.x, self.y}, false, false))
end

return player