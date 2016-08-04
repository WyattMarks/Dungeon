local client = {}
client.address = "localhost"
client.port = 1337
client.queue = {}
client.updateRate = .02
client.lastUpdate = 0

function client:send(message) 
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
	
	local player = game:getLocalPlayer()
	local toSend = {player.name}
	self:send("JOIN"..Tserial.pack(toSend, false, false))
end

function client:updateEntityInfo(data)
	if server.hosting then return end
	data = Tserial.unpack(data)
	local player = game:getLocalPlayer()

	for k, entity in pairs(data) do

		if entity.type == "player" then
			print(entity.name, player.name, entity.id, player.id)
			if entity.name ~= player.name then
				local ply = game:getEntity(entity.id)
				if ply then
					for k,v in pairs(entity) do
						ply[k] = v
					end
					world:update(ply, ply.x, ply.y)
				end
			else
				player.health = entity.health
			end
		elseif type == "enemy" then
			local enemy = game.entities[id]
			if enemy then
				for k,v in pairs(entity) do
					enemy[k] = v
				end
				world:update(enemy, enemy.x, enemy.y)
			end
		end
	end
end

function client:sendPlayerInfo()
	if server.hosting then return end
	local player = game:getLocalPlayer()
	local toSend = {player.x, player.y}
	
	local message = Tserial.pack(toSend,false,false)
	self:send('UPDATE'..message)
end


function client:update(dt)
	if self.ready then
		for k,v in pairs(self.queue) do
			self.server:send(v)
			self.queue[k] = nil
		end
	end
	
	self.lastUpdate = self.lastUpdate + dt
	if self.lastUpdate > self.updateRate then
		self.lastUpdate = self.lastUpdate - dt
		
		self:sendPlayerInfo()
	end
	
	local event = self.host:service()
	repeat
		if event and event.type == "receive" then
			local data = event.data
			if data == "READY" then
				self.ready = true
			elseif data:sub(1,4) == "JOIN" then
				self:entityJoin( Tserial.unpack( data:sub(5) ) )
			elseif data:sub(1,6) == "UPDATE" then
				data = data:sub(7)
				self:updateEntityInfo(data)
			elseif data:sub(1,3) == "MAP" and not server.hosting then
				game.map:loadFromNetworkedMap(data:sub(4))
			elseif data:sub(1,4) == "MOVE" then
				data = Tserial.unpack(data:sub(5))
				local player = game:getLocalPlayer()
				player.x = data[1]
				player.y = data[2]
				world:update(player, data[1], data[2])
			elseif data:sub(1,5) == "SHOOT" then
				self:bullet(data:sub(6))
			elseif data:sub(1,3) == "DIE" then
				self:kill(data:sub(4))
			end
		elseif event and event.type == 'disconnect' then 
			error("Network error: "..tostring(event.data))
		end
		event = self.host:service()
	until not event
end

function client:kill(data)
	data = Tserial.unpack(data)
	local type = data[1]
	local id = data[2]

	if type == "enemy" then
		local dead = game.enemies[id]
		dead:die()
	end
end

function client:bullet(data)
	local entity = Tserial.unpack(data)

	local b = game:getEntity(entity.id)

	if b then
		for k,v in pairs(entity) do
			b[k] = v
		end
		b.owner = game:getEntity(b.owner)
		world:update(b, b.x, b.y)
	else
		table.insert(game.entities, bullet:spawn(entity.id, game:getEntity(entity.owner), entity.x, entity.y, entity.xvel, entity.yvel))
	end

	--print(entity.id)
end

function client:entityJoin(entity)

--	print(entity.id, entity.type, entity.name)


	if entity.type == "player" then			
		local player = game:getLocalPlayer()
		if entity.name == player.name then
			for k,v in pairs(entity) do
				player[k] = v
			end

			game.entities[player.id] = player

			world:update(player, player.x, player.y)
			return
		end

		player = game:getEntity(entity.id)
		if not player then
			game:addPlayer(#game.entities + 1, false, entity.name)
			player = game:getEntity(#game.entities)
		end

		for k,v in pairs(entity) do
			player[k] = v
		end

		world:update(player, player.x, player.y)
	elseif entity.type == "enemy" and not server.hosting then

		local enemy = enemy:new(entity.id, entity.x, entity.y)
		for k,v in pairs(entity) do
			enemy[k] = v
		end

		if game.entities[enemy.id] then
			local ent = game.entities[enemy.id]
			ent.id = #game.entities + 1
			game.entities[ent.id] = ent
		end

		game.entities[enemy.id] = enemy
	end
end






















return client