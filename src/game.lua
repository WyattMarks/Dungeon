Player = require("src/entities/player")
Camera = require("src/thirdparty/camera")
LightWorld = require("src/thirdparty/light")
bullet = require("src/entities/bullet")
enemy = require("src/entities/enemy")
hud = require("src.gui.hud")
local game = {}
game.map = {}
game.entities = {}
game.entitiesByID = {}
game.players = {}

function game:load()
	self.running = true
	self.bindings = require("src/input/bindings")
	self.bindings:load()
	self.map = require("src/level/map")
	self.debug = require("src/gui/debug")
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

function game:addEntity(entity, id, onServer)
	if server.hosting then 
		if onServer then return end
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

function game:removeEntity(entity, index, onServer)
	if server.hosting and onServer then
		return
	end

	if not index then
		for k,v in ipairs(self.entities) do
			if v == entity then
				index = k
				break
			end
		end
		
		if not index then 
			return --error("Entity "..tostring(entity.id or -1).." not found") --Commented out because bullets are destroyed client side so like idk 
		end
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
		local ent = self.entities[i]
		if ent.isLocal then return ent end
	end
	return false
end

function game:draw()
	---if not self.map.lightWorld then return end
	camera:attach()

	--self.map.lightWorld:draw(function()
		self.map:draw()
		for k,v in pairs(self.entities) do
			v:draw()
		end
	--end)

	camera:detach()

	love.graphics.setColor(255,255,255)

	hud:draw()
	self.debug:draw()
end

function game:update(dt)
	if self:getLocalPlayer() then camera:lookAt(self:getLocalPlayer().x, self:getLocalPlayer().y) end

	self.map:update(dt)
	
	for k,v in pairs(self.entities) do
		for k,sys in pairs(self.systems) do
			self.systems[k](v, dt)
		end
		v:update(dt)
	end
	
	hud:update(dt)
	self.debug:add("FPS", love.timer.getFPS())
	self.debug:update(dt)
end

return game