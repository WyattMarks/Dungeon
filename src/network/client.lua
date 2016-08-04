local client = {}
client.address = "localhost"
client.port = 1337
client.queue = {}
client.updateRate = .02
client.lastUpdate = 0

function client:send(signal, payload)
	local message = signal .. util:pack(payload) 
	if self.ready then
		self.server:send(message)
	else
		self.queue[#self.queue + 1] = message
	end
end

function client:load()
	self.host = enet.host_create()
	self.server = self.host:connect(self.address..":"..tostring(self.port))
	--self.udp:settimeout(0)

	self:send("JOIN", {game.name, server.hosting})
end

function client:update(dt)
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
		self.lastUpdate = self.lastUpdate - dt
		
		--self:sendPlayerInfo()
	end
	
	local event = self.host:service()
	repeat
		if event and event.type == "receive" then
			local data = event.data
			if data == "READY" then
				self.ready = true
			elseif data:sub(1,3) == "MAP" and not server.hosting then
				game.map:loadFromNetworkedMap(data:sub(4))
			elseif data:sub(1,5) == "SPAWN" then
				self:spawn(util:unpack(data:sub(6)))
			elseif data:sub(1,5) == "LOCAL" then
				self.localID = util:unpack(data:sub(6))[1]
			end
		elseif event and event.type == 'disconnect' then 
			error("Network error: "..tostring(event.data))
		end
		event = self.host:service()
	until not event
end

function client:spawn(ent)
	local entity = {}
	print("SPAWNING", ent.type, ent.id, ent.name)
	if ent.type == "player" then
		entity = Player:new(false, ent.name)
		entity.x = ent.x
		entity.y = ent.y
		game:addEntity(entity, ent.id, true)
	elseif ent.type == "enemy" then
		entity = enemy:new(ent.x,ent.y)
		game:addEntity(entity, ent.id, true)
	elseif ent.type == "bullet" then
		entity = bullet:spawn(game.entitiesByID[ent.owner], ent.x, ent.y, ent.xvel, ent.yvel)
		game:addEntity( entity, ent.id, true )
	end
end













return client
