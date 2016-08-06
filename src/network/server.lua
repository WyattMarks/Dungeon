local server = {}
server.port = 1337


function server:load()
	self.updateRate = .02
	self.lastUpdate = 0
	self.players = {}
	self.host = enet.host_create("*:"..tostring(self.port))
	--self.udp:settimeout(0)
	self.hosting = true
end

function server:unload()
	self.host:destroy()
	--self.host:__gc()
	self.hosting = false
	self.players = {}
end

function server:getPlayer(peer)
	for k,v in pairs(self.players) do
		if v.peer and v.peer == peer then
			return v
		end
	end
	return false
end

function server:send(player, signal, payload)
	local data = signal..util:pack(payload)
	player.peer:send(data)
end

function server:broadcast(signal, payload)
	local message = signal..util:pack(payload)
	local sent = {}
	for k,v in pairs(self.players) do
		if v.peer then
			v.peer:send(message)
			sent[v.peer] = true
		end
	end
end

function server:processPlayerInfo(data, peer)
	local player = self:getPlayer(peer)

	if player then
		player.x = data[1]
		player.y = data[2]
	end
end

function server:broadcastEntityInfo()
	local toSend = {}
	
	for i=1, #game.entities do
		local ent = game.entities[i]
		
		toSend[ent.id] = {type = ent.type, x = ent.x, y = ent.y, health = ent.health}
	end

	self:broadcast('UPDATE', toSend)

	for i=1, #self.players do
		local player = self.players[i]

		player.peer:ping()

		local signal = player.peer:round_trip_time()
		if signal < 75 then
			signal = 3
		elseif signal < 200 then
			signal = 2
		else
			signal = 1
		end

		if player.signal ~= signal then
			self:broadcast("PING", {id = player.id, signal = signal})
		end
	end
end

function server:playerJoin(info, peer)
	local name = info[1]
	local x = game.map.spawnRoom.x * tile.tileSize + game.map.spawnRoom.width * tile.tileSize / 2
	local y = game.map.spawnRoom.y * tile.tileSize + game.map.spawnRoom.height * tile.tileSize / 2

	local player = Player:new()
	player.peer = peer
	player.x = x
	player.y = y
	player.name = name
	player.id = game:addEntity(player)
	world:update(player, x, y)
	self.players[#self.players + 1] = player
	game.players[#game.players + 1] = player

	self:send(player, "MAP", game.map:getNetworkedMap())
	self:send(player, "LOCAL", {player.id})

	for k,v in pairs(game.entities) do
		local toSend = {id = v.id, type = v.type, name = v.name, x = v.x, y = v.y, health = v.health, xvel = v.xvel, yvel = v.yvel}
		self:send(player, "SPAWN", toSend)
		if v.signal then
			self:send(player, "PING", {id = v.id, signal = v.signal})
		end
	end
end

function server:spawn(entity)
	local toSend = {id = entity.id, type = entity.type, name = entity.name, x = entity.x, y = entity.y, health = entity.health, xvel = entity.xvel, yvel = entity.yvel, owner = entity.owner}

	self:broadcast("SPAWN", toSend)
end

function server:shoot(info, peer)
	local player = self:getPlayer(peer)
	if not player then return end

	game:addEntity(bullet:new(player.id, info.x, info.y, info.xvel, info.yvel))
end

function server:chat(info)
	self:broadcast("CHAT", info)
end

function server:update(dt)
	self.lastUpdate = self.lastUpdate + dt
	if self.lastUpdate >= self.updateRate then
		self.lastUpdate = self.lastUpdate - self.updateRate
		
		self:broadcastEntityInfo()
	end
	
	local event = self.host:service()
	repeat
		if event then
			if event.type == "receive" then
				local data = event.data
				if data:sub(1,4) == "JOIN" then
					self:playerJoin(util:unpack(data:sub(5)), event.peer)
				elseif data:sub(1,6) == "UPDATE" then
					self:processPlayerInfo(util:unpack(data:sub(7)), event.peer)
				elseif data:sub(1,5) == "SHOOT" then
					self:shoot(util:unpack(data:sub(6)), event.peer)
				elseif data:sub(1,4) == "CHAT" then
					self:chat(util:unpack(data:sub(5)))
				end
			elseif event.type == "connect" then
				print(event.peer)
				event.peer:send("READY")
			elseif event.type == "disconnect" then
				--TODO: remove from game and broadcast the problem
			end
		end
		event = self.host:service()
	until not event
end























return server