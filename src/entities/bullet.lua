local bullet = {}
bullet.x = 0
bullet.y = 0
bullet.xvel = 0
bullet.yvel = 0
bullet.width = 5
bullet.height = 5
bullet.type = "bullet"

local bulletMeta = {__index = bullet}


function bullet:new(owner,x,y,xvel,yvel)
	local new = setmetatable({}, bulletMeta)
	new.x = x or self.x
	new.y = y or self.y
	new.xvel = xvel or self.xvel
	new.yvel = yvel or self.yvel
	new.owner = owner or -1

	return new
end 

function bullet:filter(other)
	if self.owner == other.id or self.type == other.type then
		return false
	else
		return "slide"
	end
end

function bullet:draw()
	love.graphics.setColor(200,200,200)
	love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

function bullet:update(dt)
	local xMove, yMove = self.x, self.y
	xMove = xMove + self.xvel * dt
	yMove = yMove + self.yvel * dt

	self.x, self.y, cols, len = world:move(self, xMove, yMove, self.filter)

	for i=1, len do
		local col = cols[i]
		local hit = col.other

		if i == 1 then
			if server.hosting and hit.health then
				hit.health = math.max(0, hit.health - 10)
			end

			game:removeEntity(self)
		end
	end
end



return bullet