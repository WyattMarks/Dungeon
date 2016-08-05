local main = {}

function main:load()
	self.font = love.graphics.newImageFont("assets/font.png", " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.,!?-+/():;%&`'*#=[]\"")
	self.hostButton = button:new("Host game", screenWidth / 2 - screenWidth / 8, screenHeight / 2, 100, 30, function()
		server:load()
		game:load()
		client:load()
	end)

	self.hostButton.font = self.font
	self.hostButton.color = 		{200,200,200}
	self.hostButton.hoverColor = 	{150,150,150}
	self.hostButton.clickColor = 	{100,100,100}

	self.joinButton = button:new("Join game", screenWidth / 2 + screenWidth / 8 - 100, screenHeight / 2, 100, 30, function()
		game:load()
		client:load()
	end)

	self.joinButton.font = self.font
	self.joinButton.color = 		{200,200,200}
	self.joinButton.hoverColor = 	{150,150,150}
	self.joinButton.clickColor = 	{100,100,100}
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

return main