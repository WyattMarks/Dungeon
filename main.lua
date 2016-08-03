io.stdout:setvbuf("no")
game = require("src/game")
bump = require("src/thirdparty/bump")
require("src/thirdparty/Tserial")
settings = require("src/settings")
server = require("src/network/server")
client = require("src/network/client")
require("enet")
bind = require("src/input/bind")

function love.load()
	math.randomseed(os.time())
	screenWidth, screenHeight = love.window.getMode()
	--server:load()
	game:load()
	client:load()
end

function love.update(dt)
	game:update(dt)
	if server.hosting then
		server:update(dt)
	end
	client:update(dt)
end

function love.draw()
	game:draw()
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