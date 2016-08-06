local pause = {}


function pause:unload()
    bind:removeBind("exitToMenu")
end


function pause:load()
    self.resumeButton = button:new("Resume Game", screenWidth / 2 + screenWidth / 8 - 100, screenHeight / 2, 100, 30, function()
		game.paused = false
	end)

	self.resumeButton.font = font.small
	self.resumeButton.color = 		{150,150,150}
	self.resumeButton.hoverColor = 	{100,100,100}
	self.resumeButton.clickColor = 	{50,50,50}

    self.exitButton = button:new("Exit Game", screenWidth / 2 - screenWidth / 8, screenHeight / 2, 100, 30, function()
		game.paused = false
        game.running = false
        game:unload()
        menu:setCurrentScreen("main")
	end)

	self.exitButton.font = font.small
	self.exitButton.color = 		{150,150,150}
	self.exitButton.hoverColor = 	{100,100,100}
	self.exitButton.clickColor = 	{50,50,50}

    bind:addBind("exitToMenu", "escape", function(down)
        if not down then
            self.exitButton:onClick()
        end
    end)
end

function pause:draw()
    love.graphics.setColor(0,0,0,150)
    love.graphics.rectangle('fill', 0, 0, screenWidth, screenHeight)

    self.resumeButton:draw()
    self.exitButton:draw()

    love.graphics.setColor(255,255,255)
	love.graphics.setFont(font.large)

	local str = "Yo welcome to dungeons"
	love.graphics.print(str, screenWidth / 2 - font.large:getWidth(str) / 2, screenHeight / 3)
end

function pause:update(dt)
    self.resumeButton:update(dt)
    self.exitButton:update(dt)
end

return pause