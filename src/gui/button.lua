local button = {}
button.x = 0
button.y = 0
button.width = 10
button.height = 10
button.text = "A button!"
button.color = {255,255,255}
button.hoverColor = button.color
button.clickColor = button.color
button.textColor = button.color
button.textHoverColor = button.color
button.textClickColor = button.color

local buttonMeta = {__index = button}

function button:new(text, x, y, width, height, onClick)
	local new = setmetatable({}, buttonMeta)
	new.x = x
	new.y = y
	new.width = width
	new.height = height
	new.onClick = onClick
	new.text = text

	return new
end

function button:draw()
	if self.wasDown and self.hover then
		love.graphics.setColor(self.clickColor)
	elseif self.hover then
		love.graphics.setColor(self.hoverColor)
	else
		love.graphics.setColor(self.color)
	end
	
	love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)

	if self.wasDown then
		love.graphics.setColor(self.textClickColor)
	elseif self.hover then
		love.graphics.setColor(self.textHoverColor)
	else
		love.graphics.setColor(self.textColor)
	end

	love.graphics.print( self.text, math.floor(self.x + self.width / 2 - self.font:getWidth(self.text) / 2), math.floor(self.y + self.height / 2 - self.font:getHeight() / 2) )
end

function button:update(dt)
	local mouseX, mouseY = love.mouse.getPosition()
	self.hover = util:rectPointCollision(self, mouseX, mouseY)

	local down = love.mouse.isDown(1)

	if self.wasDown and self.hover and not down then
		self.onClick()
	end

	self.wasDown = down
end


return button