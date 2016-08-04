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
	local message = signal .. util:pack(payload)
	local sent = {}
	for k,v in ipairs(game.entities) do
		if v.peer then
			v.peer:send(message)
			sent[v.peer] = true
		end
	end
end

function server:send(player, signal, payload)
	local data = signal .. util:pack(payload)
	player.peer:send(data)
end

function server:playerJoin(data, peer)
	local info = util:unpack( data:sub(5) )
	local name = info[1]
	local x = game.map.spawnRoom.x * tile.tileSize + game.map.spawnRoom.width * tile.tileSize / 2
	local y = game.map.spawnRoom.y * tile.tileSize + game.map.spawnRoom.height * tile.tileSize / 2


	peer:send("MAP"..game.map:getNetworkedMap())

	local ent = game.entitiesByID[game:addEntity(Player:new(info[2], name))]
	ent.x = x
	ent.y = y
	ent.peer = peer

	peer:send("LOCAL" .. util:pack({ent.id}))

	world:update(ent, x, y)


	for k,v in ipairs(game.entities) do
		local toSend = {type = v.type, name = v.name, x = v.x, y= v.y, health = v.health, id = v.id, xvel = v.xvel, yvel = v.yvel,}
		if v.owner then toSend["owner"] = v.owner.id end
		peer:send("SPAWN" .. util:pack(toSend))
	end
end

function server:spawn(entity)
	local toSend = {type = entity.type, name = entity.name, x = entity.x, y= entity.y, health = entity.health, id = entity.id, xvel = entity.xvel, yvel = entity.yvel}
	if entity.owner then toSend["owner"] = entity.owner.id end
	self:broadcast("SPAWN", toSend)
end

function server:broadcastEntityInfo()
	local toSend = {}

	for i=1, #game.entities do
		local ent = game.entities[i]
		toSend[ent.id] = {x = ent.x, y = ent.y, xvel = ent.xvel, yvel = ent.yvel, health = ent.health}
	end

	self:broadcast("UPDATE", toSend)
end

function server:processPlayerInfo(data, peer)
	local player = self:getEntity(peer)

	if player.isLocal then return end
	
	for k,v in pairs(data) do
		player[k] = v
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
					self:processPlayerInfo(util:unpack(data:sub(7)), event.peer)
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
