local enemy = {}
enemy.x = 0
enemy.y = 0
enemy.width = 15
enemy.height = 20
enemy.health = 100
enemy.speed = 96
enemy.bulletSpeed = 200
enemy.type = "enemy"

function enemy:new(id, x, y)
	local new = util:copyTable(self)
	new.id = id
	new.x = x
	new.y = y
	world:add(new, new.x, new.y, new.width, new.height)

	return new
end

function enemy:filter(other)
	if other.owner == self then
		return false
	else
		return "slide"
	end
end


function enemy:update(dt)
	
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