local bullet = {}
bullet.x = 0
bullet.y = 0
bullet.xvel = 0
bullet.yvel = 0
bullet.width = 5
bullet.height = 5
bullet.damage = 10
bullet.type = "bullet"
bullet.color = {200,200,200}
bullet.rectDraw = true

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


function bullet:update(dt)
end



return bullet