local bullet = {}
bullet.x = 0
bullet.y = 0
bullet.xvel = 0
bullet.yvel = 0
bullet.width = 5
bullet.height = 5
bullet.type = "bullet"

function bullet:spawn(owner,x,y,xvel,yvel)
	local new = util:copyTable(self)
	new.x = x
	new.y = y
	new.xvel = xvel
	new.yvel = yvel
	new.owner = owner
	game.bulletsFired = game.bulletsFired + 1
	new.id = game.bulletsFired

	world:add(new, new.x, new.y, new.width, new.height)

	return new
end 

function bullet:filter(other)
	if self.owner == other or other.owner == self.owner then
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
			world:remove(self)
			for k,v in pairs(game.bullets) do
				if v == self then 
					game.bullets[k] = nil
				end
			end

			if server.hosting then
				server:shoot(hit, self)
			end
		end
	end
end



return bullet