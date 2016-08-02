local player = {}
player.x = 0
player.y = 0
player.width = 15
player.height = 20
player.speed = 192
player.name = "player"

function player:draw()
	love.graphics.setColor(50,50,205)
	love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end


function player:update(dt)
	if game.map.lightWorld and not self.light then 
		self.light = game.map.lightWorld:newLight(self.x + self.width/2, self.y+self.height/2, 100, 140, 180, 300)
		self.light:setGlowStrength(0.3)
	end

	local xMove, yMove = self.x, self.y
	if self.right then
		xMove = xMove + self.speed * dt
	elseif self.left then
		xMove = xMove - self.speed * dt
	end

	if self.up then
		yMove = yMove - self.speed * dt
	elseif self.down then
		yMove = yMove + self.speed * dt
	end

	self.x, self.y, cols, len = world:move(self, xMove, yMove)
	if self.light then self.light:setPosition(self.x+self.width/2, self.y+self.height/2, 1) end
end

function player:new()
	local new = util:copyTable(self)
	return new
end

function player:load()
	world:add(self, self.x, self.y, self.width, self.height)
end

return player