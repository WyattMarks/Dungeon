local hall = {}
hall.x = 0
hall.y = 0
hall.width = 1
hall.height = 1
hall.id = 0


function hall:new(id,x,y,w,h)
	local new = util:copyTable(self)

	new.id = id
	new.x = x
	new.y = y
    new.height = h
    new.width = w

	return new
end

function hall:draw()
	love.graphics.setColor(25,100,25)
	love.graphics.rectangle('fill', self.x, self.y, self.width * tile.tileSize, self.height * tile.tileSize)
	love.graphics.setColor(75,180,75)
	for i=1, self.width do
		love.graphics.line(self.x + (i-1) * tile.tileSize, self.y, self.x + (i-1) * tile.tileSize, self.y + self.height * tile.tileSize)
	end

	for i=1, self.height do
		love.graphics.line(self.x, self.y + (i-1) * tile.tileSize, self.x + self.width * tile.tileSize, self.y + (i-1) * tile.tileSize)
	end

	love.graphics.setColor(255,255,255)
	love.graphics.rectangle('line', self.x, self.y, self.width*tile.tileSize, self.height*tile.tileSize)
end

return hall