local player = {}
player.x = 0
player.y = 0
player.width = 14
player.height = 26
player.speed = 192
player.bulletSpeed = 400
player.fireRate = 0.15
player.health = 100
player.name = "player"
player.type = "player"
player.xvel = 0
player.yvel = 0
player.color = {50,50,205}
player.animated = true
player.animations = {}

local playerMeta = { __index = player }

function player:loadAssets()
	self.animations["idle"] = animation:new("assets/player_idle.png", 4, .5, 9, 15)
	self.curAnim = self.animations.idle
end

function player:new()
	local new = setmetatable({}, playerMeta)

	return new
end

function player:filter(other)
	if other.owner == self.id then
		return false
	else
		return "slide"
	end
end

function player:update(dt)
	if game.debug and self.isLocal then 
		game.debug:add("X/Y", tostring(math.floor( (self.x + self.width / 2) / tile.tileSize)).."/"..tostring(math.floor( (self.y + self.height / 2) / tile.tileSize)))
	end
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
