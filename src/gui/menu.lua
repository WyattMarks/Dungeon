local menu = {}
menu.screens = {}

function menu:load()
	button = require("src.gui.button")
	textbox = require("src.gui.textbox")

	self.currentScreen = require("src.gui.menus.main")
	self.currentScreen:load()
end

function menu:setCurrentScreen(screen)
	self.currentScreen:unload()
	self.currentScreen = require("src.gui.menus."..screen)
	self.currentScreen:load()
end

function menu:draw()
	self.currentScreen:draw()
end

function menu:update(dt)
	self.currentScreen:update(dt)
end

function menu:textinput(t)
	self.currentScreen:textinput(t)
end

function menu:keypressed(key)
	self.currentScreen:keypressed(key)
end


return menu