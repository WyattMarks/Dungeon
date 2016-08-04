local server = {}
server.port = 1337
server.updateRate = .02
server.lastUpdate = 0

function server:load()
	self.host = enet.host_create("*:"..tostring(self.port))
	--self.udp:settimeout(0)
	self.hosting = true
end

function server:getEntity(peer)
	for k,v in ipairs(game.entities) do
		if v.peer and v.peer == peer then
			return v
		end
	end
	return false
end

function server:broadcast(signal, payload)
	local message = signal .. Tserial.pack(payload, false, false)
	local sent = {}
	for k,v in ipairs(game.entities) do
		if v.peer then
			v.peer:send(message)
			sent[v.peer] = true
		end
	end
end

function server:send(player, signal, payload)
	local data = signal .. Tserial.serialize(payload, false, false)
	player.peer:send(data)
end

function server:playerJoin(data, peer)
	local info = Tserial.unpack( data:sub(5) )
	local name = info[1]
	local x = game.map.spawnRoom.x * tile.tileSize + game.map.spawnRoom.width * tile.tileSize / 2
	local y = game.map.spawnRoom.y * tile.tileSize + game.map.spawnRoom.height * tile.tileSize / 2


	peer:send("MAP"..game.map:getNetworkedMap())

	local ent = game.entitiesByID[game:addEntity(Player:new(info[2], name))]
	ent.x = x
	ent.y = y
	ent.peer = peer

	peer:send("LOCAL"..Tserial.pack({ent.id}, false, false))

	world:update(ent, x, y)


	for k,v in ipairs(game.entities) do
		local toSend = {type = v.type, name = v.name, x = v.x, y= v.y, health = v.health, id = v.id}
		print("SENDING", v.type, v.id, v.name)
		peer:send("SPAWN"..Tserial.pack(toSend, false, false))
	end
end

function server:spawn(entity)
	local toSend = {type = entity.type, name = entity.name, x = entity.x, y= entity.y, health = entity.health, id = entity.id}
	self:broadcast("SPAWN", toSend)
end

function server:update(dt)
	self.lastUpdate = self.lastUpdate + dt
	if self.lastUpdate >= self.updateRate then
		self.lastUpdate = self.lastUpdate - self.updateRate
		
		--self:broadcastEntityInfo()
	end
	
	local event = self.host:service()
	repeat
		if event then
			if event.type == "receive" then
				local data = event.data
				if data:sub(1,4) == "JOIN" then
					self:playerJoin(data, event.peer)
				end
			elseif event.type == "connect" then
				event.peer:send("READY")
			elseif event.type == "disconnect" then
				--TODO: remove from game and broadcast the problem
			end
		end
		event = self.host:service()
	until not event
end























return server
