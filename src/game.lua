Player = require("src/entities/player")
Camera = require("src/thirdparty/camera")
LightWorld = require("src/thirdparty/light")
bullet = require("src/entities/bullet")
enemy = require("src/entities/enemy")
local game = {}
game.map = {}
game.entities = {}
game.name = "player"
game.toLoad = {}
game.bulletsFired = 0

function game:load()
	self.bindings = require("src/input/bindings")
	self.bindings:load()
	self.map = require("src/level/map")
	self.debug = require("src/debug")
	self.systems = require("src.systems.systems")
	self.systems:load()
	
	camera = Camera(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
	camera:zoom(2)

	self.map:load()
	if server.hosting then
		self.map:generate()
		self.map:spawnEnemies()
	end

	self:addPlayer(#self.entities+1, true, self.name..tostring(math.random(0,10)))
	camera:lookAt(self:getLocalPlayer().x, self:getLocalPlayer().y)
end

function game:getEntity(id)
	for k,v in pairs(self.entities) do
		if v.id == id then
			return v
		end
	end
end

function game:network(peer, info)
	local player = server:getEntity(peer)
	if player then
		for k,v in pairs(info) do
			player[k] = v
		end
	else 
		self.toLoad[peer] = self.toLoad[peer] or {}
		for k,v in pairs(info) do
			self.toLoad[peer][k] = v
		end
	end
end

function game:checkToLoad(player)
	for k,v in pairs(self.toLoad) do
		if v.name == player.name then
			for key,value in pairs(v) do
				player[key] = value
			end
			self.toLoad[k] = nil
		end
	end
end

function game:addPlayer(id, isLocal, name)
	local player = Player:new()
	player.name = name
	player.id = id
	player.isLocal = isLocal

	self:checkToLoad(player)

	player:load()

	self.entities[#self.entities + 1] = player
end

function game:getLocalPlayer()
	for k,v in pairs(self.entities) do
		if v.isLocal then return v end
	end
	return false
end

function game:draw()
	--if not self.map.lightWorld then return end
	camera:attach()

	--self.map.lightWorld:draw(function()
		self.map:draw()
		for k,v in ipairs(self.entities) do
			v:draw()
		end
	--end)

	camera:detach()

	love.graphics.setColor(255,255,255)

	self.debug:draw()
end

function game:update(dt)
	self.totalTime = (self.totalTime or 0) + dt
	camera:lookAt(self:getLocalPlayer().x, self:getLocalPlayer().y)
	self.map:update(dt)
	for k,v in ipairs(self.entities) do
		for k,sys in pairs(self.systems) do
			self.systems[k](v, dt)
		end
		v:update(dt)
	end

	self.debug:add("FPS", love.timer.getFPS())
	self.debug:update(dt)
end

return game