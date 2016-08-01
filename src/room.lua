local room = {}
room.x = 0
room.y = 0
room.width = 10
room.height = 10
room.id = 0
room.minWidth = 4
room.minHeight = 4
room.maxWidth = 24
room.maxHeight = 12

function room:new(id,x,y)
	local new = util:copyTable(self)

	new.id = id
	new.x = x
	new.y = y

	new.height = math.random(self.minHeight, self.maxHeight)
	new.width = math.random(self.minWidth, self.maxWidth)

	return new
end

function room:draw()
	love.graphics.setColor(25,25,100)
	love.graphics.rectangle('fill', self.x, self.y, self.width * tile.tileSize, self.height * tile.tileSize)
	love.graphics.setColor(75,75,180)
	for i=1, self.width do
		love.graphics.line(self.x + (i-1) * tile.tileSize, self.y, self.x + (i-1) * tile.tileSize, self.y + self.height * tile.tileSize)
	end

	for i=1, self.height do
		love.graphics.line(self.x, self.y + (i-1) * tile.tileSize, self.x + self.width * tile.tileSize, self.y + (i-1) * tile.tileSize)
	end

	love.graphics.setColor(255,255,255)
	love.graphics.rectangle('line', self.x, self.y, self.width*tile.tileSize, self.height*tile.tileSize)

	love.graphics.print(tostring(self.id), self.x + 10, self.y + 10)
end

return room