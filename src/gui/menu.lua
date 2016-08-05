local menu = {}
menu.screens = {}
menu.currentScreen = {}

function menu:load()
	button = require("src.gui.button")
	self:setCurrentScreen("main")
end

function menu:setCurrentScreen(screen)
	self.currentScreen = require("src.gui.menus."..screen)
	self.currentScreen:load()
end

function menu:draw()
	self.currentScreen:draw()
end

function menu:update(dt)
	self.currentScreen:update(dt)
end


return menu