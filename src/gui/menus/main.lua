local main = {}

function main:load()
	self.font = font.large
	self.hostButton = button:new("Host game", screenWidth / 2 - screenWidth / 8, screenHeight / 2, 100, 30, function()
		menu:setCurrentScreen("host")
	end)

	self.hostButton.font = font.small
	self.hostButton.color = 		{200,200,200}
	self.hostButton.hoverColor = 	{150,150,150}
	self.hostButton.clickColor = 	{100,100,100}

	self.joinButton = button:new("Join game", screenWidth / 2 + screenWidth / 8 - 100, screenHeight / 2, 100, 30, function()
		menu:setCurrentScreen("join")
	end)

	self.joinButton.font = font.small
	self.joinButton.color = 		{200,200,200}
	self.joinButton.hoverColor = 	{150,150,150}
	self.joinButton.clickColor = 	{100,100,100}

	bind:addBind("escapeExit", "escape", function(down)
		if not down then
			love.event.quit()
		end
	end)
end

function main:unload()
	bind:removeBind("escapeExit")
end

function main:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.setFont(self.font)

	local str = "Yo welcome to dungeons"
	love.graphics.print(str, screenWidth / 2 - self.font:getWidth(str) / 2, screenHeight / 3)

	self.hostButton:draw()
	self.joinButton:draw()
end

function main:update( dt )
	self.hostButton:update(dt)
	self.joinButton:update(dt)
end

function main:keypressed(key)
end

function main:textinput(t)
end

return main