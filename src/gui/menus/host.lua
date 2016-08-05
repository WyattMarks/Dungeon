local host = {}

function host:load()
	self.hostButton = button:new("Host game", screenWidth / 2 - screenWidth / 8, screenHeight / 2, 100, 30, function()
        game.name = self.nameBox.text

        local port = tonumber(self.portBox.text)

	
		client.port = port
		server.port = port
		menu:setCurrentScreen('main')

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
    self.nameBox = textbox:new("Player"..tostring(math.random(1,10)), font.small, screenWidth / 2 + screenWidth / 8 - 150 + 25 + 20, screenHeight / 12 * 5, 150)
end

function host:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.setFont(font.large)

	local str = "Host Game"
	love.graphics.print(str, screenWidth / 2 - font.large:getWidth(str) / 2, screenHeight / 4)

    love.graphics.setFont(font.small)

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