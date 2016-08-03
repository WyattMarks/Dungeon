local server = {}
server.port = 1337
server.updateRate = .02
server.lastUpdate = 0

function server:load()
	self.host = enet.host_create("*:"..tostring(self.port))
	--self.udp:settimeout(0)
	self.hosting = true
end

function server:getPlayer(peer)
	for k,v in pairs(game.players) do
		if v.peer and v.peer == peer then
			return v
		end
	end
	return false
end

function server:broadcast(message)
	local sent = {}
	for k,v in pairs(game.players) do
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
	local player = self:getPlayer(peer)
	data = Tserial.unpack(data)
	if player then
		player.x = data[1]
		player.y = data[2]
	else
		game:network(peer, {x = data[1], y = data[2]})
	end
end

function server:broadcastPlayerInfo()
	local toSend = {}
	for k,v in pairs(game.players) do
		toSend[v.name] = {v.x,v.y,v.health}
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

	for k,v in pairs(game.players) do
		local toSend = {v.name,v.x,v.y}
		peer:send("JOIN"..Tserial.pack(toSend, false, false))
	end
					
	self:broadcast("JOIN"..Tserial.pack( {name, x, y}, false, false ))
end

function server:bullet(data, peer)
	data = Tserial.unpack(data)
	local player = self:getPlayer(peer)

	if not player then return end

	data.name = player.name

	self:broadcast("SHOOT"..Tserial.pack(data, false, false))
end

function server:shoot(hit, bullet)
	if hit.type == "player" then
		hit.health = math.max(0, hit.health - 10)
		if hit.health == 0 then
			hit:die()
		end
	elseif hit.type == "bullet" then

	end
end

function server:update(dt)
	self.lastUpdate = self.lastUpdate + dt
	if self.lastUpdate >= self.updateRate then
		self.lastUpdate = self.lastUpdate - self.updateRate
		
		self:broadcastPlayerInfo()
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
				event.peer:send("READY")
			elseif event.type == "disconnect" then
				--TODO: remove from game and broadcast the problem
			end
		end
		event = self.host:service()
	until not event
end























return server