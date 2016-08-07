local settings = {}


settings.binds = {
	shoot = 1,
	tabMenu = "tab",
	pause = 'escape',
	chat = "t",
	right = 'd',
	left = 'a',
	up = 'w',
	down = 's',
}

settings.preferences = {
	name = 'default',
	port = 1337,
	host = 'localhost:1337'
}

function settings:load()
	if not love.filesystem.isFile("dungeon.settings") then
		return false
	end
	
	local file, size = love.filesystem.read("dungeon.settings")
	for k,v in pairs(util:unpack(file)) do
		if type(v) == "table" then
			if not self[k] then
				self[k] = v
			else
				for key,val in pairs(v) do
					self[k][key] = val
				end
			end
		else
			self[k] = v
		end
	end
	
	print("Loaded dungeon.settings")
end

function settings:save()
	love.filesystem.write("dungeon.settings", util:pack(self, true))
end

return settings