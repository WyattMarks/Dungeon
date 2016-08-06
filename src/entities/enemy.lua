local enemy = {}
enemy.x = 0
enemy.y = 0
enemy.width = 15
enemy.height = 20
enemy.health = 100
enemy.speed = 48
enemy.bulletSpeed = 400
enemy.fireRate = 1
enemy.type = "enemy"
enemy.range = 300
enemy.targetsPlayers = true
enemy.firing = true
enemy.isAI = true
enemy.color = {205,50,50}

local enemyMeta = { __index = enemy }

function enemy:new(x, y)
	local new = setmetatable({}, enemyMeta)
	new.x = x
	new.y = y

	return new
end

function enemy:filter(other)
	if other.owner == self.id then
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


	game:addEntity(bullet:new(self.id, eX, eY, xvel, yvel))
end

function enemy:update(dt)
end

function enemy:die()
	game:removeEntity(self)
end













return enemy
