io.stdout:setvbuf("no")
planet = require('src/planet')
gravity = require('src/gravity')
spawn = require('src/spawn')
cam = require('src/cam')
debug = require('src/debug')
collision = require('src/collision')
util = require('src/util')
input = require("src/input")

function love.load()
	math.randomseed(os.time())
	debug:load()
	screenWidth, screenHeight = love.window.getMode()
end

function love.update(dt)
	input:update(dt)
	spawn:update(dt)
	collision:update(dt)
	gravity:update(dt)
	cam:update(dt)
end

function love.draw()
	cam:set()
	spawn:draw()
	gravity:draw()
	cam:unset()
	
	debug:draw()
end

function love.wheelmoved(x,y) 
	cam:wheelmoved(x,y)
end

function love.mousemoved(x,y,dx,dy)
	cam:mousemoved(x,y,dx,dy)
end

function love.keypressed(key)
	input:keypressed(key)
end

function love.keyreleased(key)
	input:keyreleased(key)
end

function input:callback(key, isBeingHeld)
	debug:keypressed(key)
	spawn:keypressed(key)
end