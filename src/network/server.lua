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
	for k,v in pairs(game.entities) do
		if v.peer and v.peer == peer then
			return v
		end
	end
	return false
end

function server:broadcast(message)
	local sent = {}
	for k,v in pairs(game.entities) do
		if v.peer then
			v.peer:send(message)
			sent[v.peer] = true
		end
	end

	for k,v in pairs(game.toLoad) do
		if not sent[k] then
			sent[k] = true
			k:send(message)
		end
	end
end

function server:processPlayerInfo(data, peer)
	local player = self:getEntity(peer)
	data = Tserial.unpack(data)
	if player then
		player.x = data[1]
		player.y = data[2]
	else
		game:network(peer, {x = data[1], y = data[2]})
	end
end

function server:broadcastEntityInfo()
	local toSend = {}
	
	for k,v in pairs(game.entities) do
		toSend[v.id] = {id = v.id, name = v.name, type = v.type, x = v.x, y = v.y, health = v.health}
	end

	local message = Tserial.pack(toSend,false,false)
	self:broadcast('UPDATE'..message)
end

function server:send(player, data)
	player.peer:send(data)
end

function server:playerJoin(data, peer)
	local info = Tserial.unpack( data:sub(5) )
	local name = info[1]
	local x = game.map.spawnRoom.x * tile.tileSize + game.map.spawnRoom.width * tile.tileSize / 2
	local y = game.map.spawnRoom.y * tile.tileSize + game.map.spawnRoom.height * tile.tileSize / 2

	game:network(peer, {name = name, peer = peer})

	peer:send("MAP"..game.map:getNetworkedMap())

	for k,v in pairs(game.entities) do
		local toSend = {type = v.type, name = v.name, x = v.x, y= v.y, health = v.health, id = v.id}
		peer:send("JOIN"..Tserial.pack(toSend, false, false))
	end
					
	self:broadcast("JOIN"..Tserial.pack( {type = "player",name = name,x = x,y = y}, false, false ))
end

function server:bullet(data, peer)
	local entity = Tserial.unpack(data)

	local bullet = bullet:spawn(#game.entities + 1, game:getLocalPlayer(), 0, 0, 0, 0) --Placeholder bullet
	entity.id = bullet.id

	table.insert(game.entities, bullet)

	self:broadcast("SHOOT"..Tserial.pack(entity, false, false))
end

function server:shoot(hit, bullet)
	if hit.type == "player" or hit.type == "enemy" then

		hit.health = math.max(0, hit.health - 10)
		if hit.health == 0 then
			if hit.type == "enemy" then
				self:broadcast("DIE"..Tserial.pack{hit.type, hit.id})
			else
				hit:die()
			end
		end
	elseif hit.type == "bullet" then

	end
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
					self:playerJoin(data, event.peer)
				elseif data:sub(1,6) == "UPDATE" then
					self:processPlayerInfo(data:sub(7), event.peer)
				elseif data:sub(1,5) == "SHOOT" then
					self:bullet(data:sub(6), event.peer)
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