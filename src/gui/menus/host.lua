local host = {}

function host:load()
	self.errors = {}

	self.hostButton = button:new("Host game", screenWidth / 2 - screenWidth / 8, screenHeight / 2, 100, 30, function()
        game.name = self.nameBox.text

        local port = tonumber(self.portBox.text)

		if port <= 1025 then
			self.portBox.text = "1337"
			self.errors[#self.errors+1] = "Ports 1024 and under are reserved."
			self.portBox.firstInput = nil
			return
		end

		client.port = port
		server.port = port
		menu:setCurrentScreen('main')
		menu.currentScreen:unload()

        server:load()
		game:load()
		client:load()
	end)

	self.hostButton.font = font.small
	self.hostButton.color = 		{200,200,200}
	self.hostButton.hoverColor = 	{150,150,150}
	self.hostButton.clickColor = 	{100,100,100}

	self.backButton = button:new("Back", screenWidth / 2 + screenWidth / 8 - 100, screenHeight / 2, 100, 30, function()
		menu:setCurrentScreen("main")
	end)

	self.backButton.font = font.small
	self.backButton.color = 		{200,200,200}
	self.backButton.hoverColor = 	{150,150,150}
	self.backButton.clickColor = 	{100,100,100}

    self.portBox = textbox:new("1337", font.small, screenWidth / 2 - screenWidth / 8 - 25 + 20, screenHeight / 12 * 5, 150)
	self.portBox.errorText = "Ports can only contain numbers." --Little mod of textbox that is number only

	self.portBox.textinput = function(portBox, t)
		if portBox.active then
			if tonumber(t) then
        		if not portBox.firstInput then portBox.firstInput = true portBox.text = '' end
				portBox.text = portBox.text..t
				
				for i=#self.errors, 1, -1 do
					if self.errors[i] == self.portBox.errorText then
						table.remove(self.errors, i)
					end
				end
			else
				self.errors[#self.errors + 1] = self.portBox.errorText
			end
		end
	end

	self.portBox.keypressed = function(portBox, key, isrepeat)
		if key == "backspace" and portBox.active then
			if not portBox.firstInput then portBox.firstInput = true portBox.text = '' end

			if self.portBox.text ~= "" then
				for i=#self.errors, 1, -1 do
					if self.errors[i] == self.portBox.errorText then
						table.remove(self.errors, i)
					end
				end
			end

			local byteoffset = utf8.offset(portBox.text, -1)
		
			if byteoffset then
				portBox.text = string.sub(portBox.text, 1, byteoffset - 1)
			end
		end
	end


    self.nameBox = textbox:new("Player"..tostring(math.random(1,10)), font.small, screenWidth / 2 + screenWidth / 8 - 150 + 25 + 20, screenHeight / 12 * 5, 150)

	bind:addBind("enterText", "return", function(down)
		if not down and (self.nameBox.active or self.portBox.active) then
			self.hostButton:onClick()
			return
		end
	end)

	bind:addBind("tabText", "tab", function(down)
		if not down then
			if self.portBox.active or self.nameBox.active then
				self.portBox.active = not self.portBox.active
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

function host:unload()
	bind:removeBind("enterText")
	bind:removeBind("tabText")
	bind:removeBind("escapeExit")
end

function host:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.setFont(font.large)

	local str = "Host Game"
	love.graphics.print(str, screenWidth / 2 - font.large:getWidth(str) / 2, screenHeight / 4)

    love.graphics.setFont(font.small)

	str = "Error: " .. ( self.errors[#self.errors] or '' )

	if #self.errors > 0 then
		love.graphics.setColor(205,50,50)

		love.graphics.print(str, screenWidth / 2 - font.small:getWidth(str) / 2, screenHeight / 3 * 2)

		love.graphics.setColor(255,255,255)
	end

    str = "Port: "
    love.graphics.print(str, self.portBox.x - font.small:getWidth(str), self.portBox.y)

    str = "Name: "
    love.graphics.print(str, self.nameBox.x - font.small:getWidth(str), self.nameBox.y)

	self.backButton:draw()
	self.hostButton:draw()

    self.portBox:draw()
    self.nameBox:draw()
end

function host:update( dt )
	self.backButton:update(dt)
	self.hostButton:update(dt)

    self.portBox:update(dt)
    self.nameBox:update(dt)
end

function host:keypressed(key)
    self.portBox:keypressed(key)
    self.nameBox:keypressed(key)
end

function host:textinput(t)
    self.portBox:textinput(t)
    self.nameBox:textinput(t)
end

return host