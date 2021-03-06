local join = {}

function join:validIP(str)
	if str == "localhost" then
		return true
	end

	if not str:find(".", 1, true) then
		return false
	end

	if str:len() < 4 then
		return false
	end

	local index = 0

	while str:find('.', index + 1, true) do 
		local i, startPos, endPos = str:find('.', index + 1, true)
		index = i

		if i == 1 then
			return false
		end

		if str:sub(index + 1, index + 1) == "." then 
			return false
		end
	end


	return true
end

function join:load()
	self.bgImage = love.graphics.newImage("assets/background.png")
	self.errors = {}

	self.joinButton = button:new("Join game", screenWidth / 2 - screenWidth / 8, screenHeight / 2, 100, 30, function()
        game.name = self.nameBox.text

        local ip = self.ipBox.text
		local port = 1337


		if ip:find(":") then
			local index = ip:find(":")
			port = tonumber(ip:sub(index + 1))
			ip = ip:sub(1, index - 1)
		end

		local socket = require("socket")
		local a,b = socket.dns.toip(ip)


		if b == "host not found" then
			self.errors[#self.errors + 1] = "Failed to resolve hostname."
			return
		else
			if not self:validIP(ip) then
				self.errors[#self.errors + 1] = "Enter a valid IP address or URL."
				return
			else
				for i=#self.errors, 1, -1 do
					if self.errors[i] == "Enter a valid IP address or URL." then
						self.errors[i] = nil
					end
				end
			end
		end


		settings.preferences.name = self.nameBox.text
		settings.preferences.host = ip..":"..tostring(port)

		if self.nameBox.orignal then
			settings.preferences.name = "default"
		end

		settings:save()


		client.address = ip
		client.port = port
        menu:setCurrentScreen("main")
		menu.currentScreen:unload()

		game:load()
		client:load()
	end)

	self.joinButton.font = font.small
	self.joinButton.color = 		{200,200,200}
	self.joinButton.hoverColor = 	{150,150,150}
	self.joinButton.clickColor = 	{100,100,100}

	self.backButton = button:new("Back", screenWidth / 2 + screenWidth / 8 - 100, screenHeight / 2, 100, 30, function()
		menu:setCurrentScreen("main")
	end)

	self.backButton.font = font.small
	self.backButton.color = 		{200,200,200}
	self.backButton.hoverColor = 	{150,150,150}
	self.backButton.clickColor = 	{100,100,100}

    self.ipBox = textbox:new(settings.preferences.host, font.small, screenWidth / 2 - screenWidth / 8 - 25 + 10, screenHeight / 12 * 5, 150)
    self.nameBox = textbox:new(settings.preferences.name, font.small, screenWidth / 2 + screenWidth / 8 - 150 + 25 + 10, screenHeight / 12 * 5, 150)

	if self.nameBox.text == "default" then
		self.nameBox.orignal = true
		local num = math.random(1,168)
		local count = 0

		local file = love.filesystem.read("assets/names")

		for line in file:gmatch"[^\n]+" do
			count = count + 1
			if count == num then
				self.nameBox.text = line
				break
			end
		end	
	end

	if self.ipBox.text:find(":") then
		local i = self.ipBox.text:find(":")
		if self.ipBox.text:sub(i+1) == "1337" then
			self.ipBox.text = self.ipBox.text:sub(1, i-1)
		end
	end

	bind:addBind("enterText", "return", function(down)
		if not down and (self.ipBox.active or self.nameBox.active) then
			self.joinButton:onClick()
			return
		end
	end)

	bind:addBind("tabText", "tab", function(down)
		if not down then
			if self.ipBox.active or self.nameBox.active then
				self.ipBox.active = not self.ipBox.active
				self.nameBox.active = not self.nameBox.active
			end
		end
	end)

	bind:addBind("escapeExit", "escape", function(down)
		if not down then
			menu:setCurrentScreen("main")
		end
	end)
end

function join:unload()
	bind:removeBind("enterText")
	bind:removeBind("tabText")
	bind:removeBind("escapeExit")
end

function join:draw()
	love.graphics.setColor(255,255,255)

	love.graphics.draw(self.bgImage, 0, 0)

	love.graphics.setFont(font.large)

	local str = "Join Game"
	love.graphics.print(str, screenWidth / 2 - font.large:getWidth(str) / 2, screenHeight / 4)

    love.graphics.setFont(font.small)

	str = "Error: " .. ( self.errors[#self.errors] or '' )

	if #self.errors > 0 then
		love.graphics.setColor(205,50,50)

		love.graphics.print(str, screenWidth / 2 - font.small:getWidth(str) / 2, screenHeight / 3 * 2)

		love.graphics.setColor(255,255,255)
	end

    str = "IP: "
    love.graphics.print(str, self.ipBox.x - font.small:getWidth(str), self.ipBox.y)

    str = "Name: "
    love.graphics.print(str, self.nameBox.x - font.small:getWidth(str), self.nameBox.y)

	self.backButton:draw()
	self.joinButton:draw()
    self.ipBox:draw()
    self.nameBox:draw()
end

function join:update( dt )
	self.backButton:update(dt)
	self.joinButton:update(dt)
    self.ipBox:update(dt)
    self.nameBox:update(dt)
end

function join:keypressed(key)
    self.ipBox:keypressed(key)
    self.nameBox:keypressed(key)
end

function join:textinput(t)
    self.ipBox:textinput(t)
    self.nameBox:textinput(t)
end

return join