io.stdout:setvbuf("no")
game = require("src/game")
menu = require("src/gui/menu")
bump = require("src/thirdparty/bump")
require("src/thirdparty/Tserial")
settings = require("src/settings")
server = require("src/network/server")
client = require("src/network/client")
require("enet")
bind = require("src/input/bind")
util =  require("src/util")

function love.load()
	math.randomseed(os.time())
	screenWidth, screenHeight = love.window.getMode()

	menu:load()
end

function love.update(dt)
	if game.running then
		game:update(dt)
		if server.hosting then
			server:update(dt)
		end
		client:update(dt)
	else
		menu:update(dt)
	end
end

function love.draw()
	if game.running then
		game:draw()
	else
		menu:draw()
	end
end


function love.keypressed(key)
	bind:keypressed(key)
end

function love.keyreleased(key)
	bind:keyreleased(key)
end

function love.mousepressed(x, y, button, istouch)
	bind:mousepressed(x, y, button, istouch)
end

function love.mousereleased(x, y, button, istouch)
	bind:mousereleased(x, y, button, istouch)
end