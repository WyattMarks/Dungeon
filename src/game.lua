Player = require("src/entities/player")
Camera = require("src/thirdparty/camera")
LightWorld = require("src/thirdparty/light")
bullet = require("src/entities/bullet")
enemy = require("src/entities/enemy")
local game = {}
game.map = {}
game.entities = {}
game.entitiesByID = {}
game.name = "player"
game.toLoad = {}

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

	--self:addPlayer(#self.entities+1, true, self.name..tostring(math.random(0,10)))
	--camera:lookAt(self:getLocalPlayer().x, self:getLocalPlayer().y)
end

function game:addEntity(entity, id)
	if server.hosting then 
		self.entityCount = (self.entityCount or 0) + 1
		id = self.entityCount
	end

	self.entitiesByID[id] = entity
	self.entities[#self.entities + 1] = entity
end

function game:removeEntity(entity, index)
	table.remove(self.entities, index)
	self.entitiesByID[entity.id] = nil
end

function game:getLocalPlayer()
	for i=1, #self.entities do
		if self.entities[i].isLocal then return self.entities[i] end
	end
	return false
end

function game:draw()
	--if not self.map.lightWorld then return end
	camera:attach()

	--self.map.lightWorld:draw(function()
		self.map:draw()
	--end)

	camera:detach()

	love.graphics.setColor(255,255,255)

	self.debug:draw()
end

function game:update(dt)
	camera:lookAt(self:getLocalPlayer().x, self:getLocalPlayer().y)
	self.map:update(dt)
	for i=1, #self.entities do
		local ent = self.entities[i]
		for k,sys in pairs(self.systems) do
			self.systems[k](ent, i, dt)
		end
	end

	self.debug:add("FPS", love.timer.getFPS())
	self.debug:update(dt)
end

return game