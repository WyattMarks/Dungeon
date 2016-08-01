io.stdout:setvbuf("no")
Dungeon = require("src/Dungeon")
cam = require("src/cam")

function love.load()
	math.randomseed(os.time())
	screenWidth, screenHeight = love.window.getMode()
	Dungeon:generate()
end

function love.update(dt)
	Dungeon:update(dt)
end

function love.draw()
	cam:set()
		Dungeon:draw()
	cam:unset()
end

function love.wheelmoved(x,y) 
	cam:wheelmoved(x,y)
end

function love.mousemoved(x,y,dx,dy)
	cam:mousemoved(x,y,dx,dy)
end

function love.keypressed(key)
	if key == "r" then
		Dungeon:generate()
	end
end
