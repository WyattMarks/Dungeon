local hud = {}

function hud:draw()
	if self.tabOpen then
		love.graphics.setColor(50,50,50,140)
		love.graphics.setFont(font.small)

		local y = screenHeight / 8
		love.graphics.rectangle('fill', screenWidth / 2 - 52, y, 104, #game.players * (font.small:getHeight() + 5)  )

		y = y + 2
		for i=1, #game.players do
			local player = game.players[i]

			love.graphics.setColor(50,50,50,140)
			love.graphics.rectangle('fill', screenWidth / 2 - 48, y, 100, font.small:getHeight() + 4)

			y = y + 2
			love.graphics.setColor(255,255,255)
			love.graphics.print(player.name, screenWidth / 2 - 46, y)


			if player.signal then
				if player.signal == 3 then
					love.graphics.setColor(50,205,50)
				elseif player.signal == 2 then
					love.graphics.setColor(171, 130, 19)
				elseif player.signal == 1 then
					love.graphics.setColor(205,50,50)
				end

				love.graphics.rectangle('fill', screenWidth / 2 + 52 - 2 - 1 - 8, y + 1 + font.small:getHeight() / 2 -4, 8, 8 )
			else
			
			end

			y = y + 3 + font.small:getHeight()
		end
	end
end

function hud:update()

end



return hud