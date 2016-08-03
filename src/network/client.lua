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

function client:updatePlayerInfo(data)
	if server.hosting then return end
	data = Tserial.unpack(data)
	local player = game:getLocalPlayer()
	for name, info in pairs(data) do
		if name ~= player.name then
			local ply = game:getPlayer(name)
			if ply then
				ply.x = info[1]
				ply.y = info[2]
				ply.health = info[3]
			end
		else
			player.health = info[3]
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
				self:playerJoin( Tserial.unpack( data:sub(5) ) )
			elseif data:sub(1,6) == "UPDATE" then
				data = data:sub(7)
				self:updatePlayerInfo(data)
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
			end
		elseif event and event.type == 'disconnect' then 
			error("Network error: "..tostring(event.data))
		end
		event = self.host:service()
	until not event
end

function client:bullet(data)
	data = Tserial.unpack(data)
	local name = data.name
	local x = data.x
	local y = data.y
	local xvel = data.xvel
	local yvel = data.yvel

	table.insert(game.bullets, bullet:spawn(game:getPlayer(name), x, y, xvel, yvel))
end

function client:playerJoin(data)
	local name = data[1]
	local x = data[2]
	local y = data[3]
					
	local player = game:getLocalPlayer()
	if name == player.name then
		player.x = x
		player.y = y
		world:update(player, x, y)
		return
	end

	game:addPlayer(name, false)
	player = game:getPlayer(name)
	player.x = tonumber(x)
	player.y = tonumber(y)
	world:update(player, tonumber(x), tonumber(y))
end






















return client