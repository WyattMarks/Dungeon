Player = require("src/player")
Camera = require("src/thirdparty/camera")
LightWorld = require("src/thirdparty/light")
local game = {}
game.map = {}
game.players = {}
game.name = "player"
game.toLoad = {}

function game:load()
	self.bindings = require("src/input/bindings")
	self.bindings:load()
	self.map = require("src/level/map")

	camera = Camera(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
	camera:zoom(2)

	self.map:load()
	if server.hosting then
		self.map:generate()
	end

	self:addPlayer(self.name..tostring(math.random(0,10)), true)
	camera:lookAt(self:getLocalPlayer().x, self:getLocalPlayer().y)
end

function game:getPlayer(name)
	for k,v in pairs(self.players) do
		if v.name == name then
			return v
		end
	end
end

function game:network(peer, info)
	local player = server:getPlayer(peer)
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

function game:addPlayer(name, isLocal)
	local player = Player:new()
	player.name = name
	player.isLocal = isLocal

	for k,v in pairs(self.toLoad) do
		if v.name == name then
			for key,value in pairs(v) do
				player[key] = value
			end
			self.toLoad[k] = nil
		end
	end

	player:load()

	self.players[#self.players + 1] = player
end

function game:getLocalPlayer()
	for k,v in pairs(self.players) do
		if v.isLocal then return v end
	end
	return false
end

function game:draw()
	if not self.map.lightWorld then return end
	camera:attach()

	self.map.lightWorld:draw(function()
		self.map:draw()
		for k,v in pairs(self.players) do
			v:draw()
		end
	end)

	camera:detach()

	love.graphics.setColor(255,255,255)
	love.graphics.print(tostring(love.timer.getFPS()), 10, 10)
end

function game:update(dt)
	self.totalTime = (self.totalTime or 0) + dt
	camera:lookAt(self:getLocalPlayer().x, self:getLocalPlayer().y)
	self.map:update(dt)
	for k,v in pairs(self.players) do
		v:update(dt)
	end
end

return game