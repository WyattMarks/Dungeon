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
	self.name = self.name..tostring(math.random(1,10)) --Tempoary 
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
end

function game:addEntity(entity, id, alreadyAdded)
	if server.hosting then 
		if alreadyAdded then return end
		self.entityCount = (self.entityCount or 0) + 1
		id = self.entityCount
	end

	entity.id = id

	self.entitiesByID[id] = entity
	self.entities[#self.entities + 1] = entity
	if server.hosting then
		--server:broadcast("SPAWN", entity) TODO: Make entities ECS
		server:spawn(entity)
	end

	world:add(entity, entity.x, entity.y, entity.width, entity.height)

	return id
end

function game:removeEntity(entity, index)
	if not index then
		for k,v in ipairs(self.entities) do
			if v == entity then
				index = k
				break
			end
		end
		error('entity not found')
	end
	table.remove(self.entities, index)
	self.entitiesByID[entity.id] = nil
	if world and world:hasItem(entity) then
		world:remove(entity)
	end
	if server.hosting then
		server:broadcast("KILL", { id = entity.id })
	end
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

		for k,v in ipairs(self.entities) do
			v:draw()
		end
	--end)

	camera:detach()

	love.graphics.setColor(255,255,255)

	self.debug:draw()
end

function game:update(dt)
	if self:getLocalPlayer() then camera:lookAt(self:getLocalPlayer().x, self:getLocalPlayer().y) end

	self.map:update(dt)
	for i=#self.entities, 1, -1 do
		local ent = self.entities[i]
		for k,sys in pairs(self.systems) do
			self.systems[k](ent, i, dt)
		end

		ent:update(dt)
	end

	self.debug:add("FPS", love.timer.getFPS())
	self.debug:update(dt)
end


return game
