local client = {}
client.address = "localhost"
client.port = 1337

function client:send(signal, payload) 
	local message = signal..util:pack(payload)
	if self.ready then
		self.server:send(message)
	else
		self.queue[#self.queue + 1] = message
	end
end

function client:load()
	self.going = true
	self.queue = {}
	self.updateRate = .02
	self.lastUpdate = 0
	self.host = enet.host_create()
	self.server = self.host:connect(self.address..":"..tostring(self.port))
	--self.udp:settimeout(0)

	self:send("JOIN", {game.name})
end

function client:unload()
	self.going = false
	self.host:destroy()
end

function client:updateEntityInfo(data)
	if server.hosting then return end

	for id, info in pairs(data) do
		local ent = game.entitiesByID[id]
		if ent then
			if ent ~= game:getLocalPlayer() then
				for k,v in pairs(info) do
					ent[k] = v
				end
			else
				game:getLocalPlayer().health = info.health
			end

			world:update(ent, ent.x, ent.y)
		end
	end
end

function client:sendPlayerInfo()
	local player = game:getLocalPlayer()
	if server.hosting or not player then return end

	self:send('UPDATE', {player.x, player.y})
end


function client:update(dt)
	if not self.going then return end 
	if self.ready then
		for k,v in pairs(self.queue) do
			self.server:send(v)
			self.queue[k] = nil
		end
	end

	if self.localID and game.entitiesByID[self.localID] then
		game.entitiesByID[self.localID].isLocal = true
		self.localID = nil
	end
	
	self.lastUpdate = self.lastUpdate + dt
	if self.lastUpdate > self.updateRate then
		self.lastUpdate = self.lastUpdate - self.updateRate
		
		self:sendPlayerInfo()
	end
	
	local event = self.host:service()
	repeat
		if event and event.type == "receive" then
			local data = event.data
			if data == "READY" then
				self.ready = true
			elseif data:sub(1,3) == "MAP" and not server.hosting then
				game.map:loadFromNetworkedMap(util:unpack(data:sub(4)))
			elseif data:sub(1,5) == "SPAWN" then
				self:spawn(util:unpack(data:sub(6)))
			elseif data:sub(1,5) == "LOCAL" then
				self.localID = util:unpack(data:sub(6))[1]
				print(self.localID)
			elseif data:sub(1,6) == "UPDATE" then
				self:updateEntityInfo(util:unpack(data:sub(7)))
			elseif data:sub(1,4) == "KILL" then
				self:kill(util:unpack(data:sub(5)))
			elseif data:sub(1,4) == "MOVE" then
				self:move(util:unpack(data:sub(5)))
			elseif data:sub(1,4) == "PING" then
				self:ping(util:unpack(data:sub(5)))
			elseif data:sub(1,4) == "CHAT" then
				self:chat(util:unpack(data:sub(5)))
			elseif data:sub(1, 6) == "RELOAD" then
				if not server.hosting then game:regenerate() end
			end
		elseif event and event.type == 'disconnect' then 
			error("Network error: "..tostring(event.data))
		end
		event = self.host:service()
	until not event
end

function client:chat(info)
	game.chatbox:message(info[1], info[2])
end

function client:ping(info)
	game.entitiesByID[info.id].signal = info.signal
end

function client:move(info)
	local player = game:getLocalPlayer()
	player.x = info[1]
	player.y = info[2]

	world:update(player, player.x, player.y)
end

function client:kill(data)
	game:removeEntity(game.entitiesByID[data.id], nil, true)	
end

function client:spawn(info)
	local entity = {}
	if info.type == "player" then
		entity = Player:new()
	elseif info.type == "enemy" then
		entity = enemy:new()
	elseif info.type == "bullet" then
		entity = bullet:new()
	end

	for k,v in pairs(info) do
		entity[k] = v
	end

	if not server.hosting then
		if entity.type == "player" then
			game.players[#game.players + 1] = entity
		end
	end

	game:addEntity(entity, info.id, true)			
end






















return client