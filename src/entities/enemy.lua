local enemy = {}
enemy.x = 0
enemy.y = 0
enemy.width = 15
enemy.height = 20
enemy.health = 100
enemy.speed = 48
enemy.bulletSpeed = 200
enemy.fireRate = 1
enemy.type = "enemy"
enemy.range = 300

local enemyMeta = { __index = enemy }

function enemy:new(x, y)
	local new = setmetatable({}, enemyMeta)
	new.x = x
	new.y = y

	return new
end

function enemy:filter(other)
	if other.owner == self then
		return false
	else
		return "slide"
	end
end

function enemy:canSee(player)
	local function filter(e, other)
		if other.type == "brick" then
			return "slide"
		end
		return false
	end

	local x, y, cols, len = world:check(self, player.x, player.y, filter)

	return len == 0
end

function enemy:shoot(x, y)
	local eX, eY = self.x + self.width / 2 - bullet.width / 2, self.y + self.height / 2 - bullet.height / 2
	local angle = math.atan2(x - eX, y - eY)
	local xvel = self.bulletSpeed * math.sin(angle)
	local yvel = self.bulletSpeed * math.cos(angle)

	game:addEntity( bullet:spawn(game:getLocalPlayer(), 0, 0, 0, 0) )

end

function enemy:update(dt)

	if server.hosting then
		self.lastShoot = (self.lastShoot or 0) + dt
		self.timer = (self.timer or 0) - dt

		if self.timer <= 0 then
			local nextMoveDur = math.random(1,4)
			self.timer = nextMoveDur

			self.right = math.random(1,4) == 1
			self.left = math.random(1,4) == 1
			self.up = math.random(1,4) == 1
			self.down = math.random(1,4) == 1
		end

		if self.lastShoot > self.fireRate then
			self.lastShoot = self.lastShoot - math.random(self.fireRate-self.fireRate/2, self.fireRate+self.fireRate/2)

			local players = {}
			for k,v in pairs(game.entities) do
				if v.type == "player" then
					players[#players+1] = {util:distance(self.x, self.y, v.x, v.y), v}
				end 
			end

			table.sort(players, function( b, a ) return a[1] > b[1] end)

			for i=1, #players do
				local player = players[i][2]

				if self:canSee(player) and players[i][1] < self.range then
					self:shoot(player.x + player.width / 2, player.y + player.height / 2)
					break
				end
			end
		end


		local xMove, yMove = self.x, self.y
		if self.right then
			xMove = xMove + self.speed * dt
		elseif self.left then
			xMove = xMove - self.speed * dt
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
	end
end

function enemy:die()
	world:remove(self)
	for k,v in pairs(game.enemies) do
		if v == self then 
			game.enemies[k] = nil
		end
	end
end

function enemy:draw()
	love.graphics.setColor(205,50,50)
	love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)

	love.graphics.setColor(205,50,50)
	love.graphics.rectangle('fill', self.x, self.y - 10, self.width, 5)
	love.graphics.setColor(50,205,50)
	love.graphics.rectangle('fill', self.x, self.y - 10, self.health/100 * self.width, 5)
end












return enemy
