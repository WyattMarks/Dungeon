local cam = {}
cam.scale = 1
cam.xOffset = 1280/2
cam.yOffset = 720/2

function cam:getMouseWorldPos()
	return self:screenToWorld(love.mouse.getPosition())
end

function cam:screenToWorld(x,y)
	return x / self.scale - self.xOffset, y / self.scale - self.yOffset
end

function cam:worldToScreen(x,y)
	return x * self.scale + self.xOffset, y * self.scale + self.yOffset
end

function cam:wheelmoved(dx,dy)
	local x,y = self:getMouseWorldPos()

	if dy>0 then
		self.scale = self.scale + self.scale/5
	elseif dy<0 then
		self.scale = self.scale - self.scale/5
	end
	
	local x2, y2 = self:getMouseWorldPos()
	
	
	if not self.following then
		self.xOffset = self.xOffset - (x - x2)
		self.yOffset = self.yOffset - (y - y2)
	end
end

function cam:set()
	love.graphics.scale(self.scale, self.scale)
	love.graphics.translate(self.xOffset, self.yOffset)
end

function cam:unset()
	love.graphics.origin()
end

function cam:follow(target)
	self.following = target.id
end

function cam:unfollow()
	self.following = false
end


function cam:mousemoved(x,y,dx,dy)
	if love.mouse.isDown(3) then
		self.xOffset = self.xOffset + dx / self.scale
		self.yOffset = self.yOffset + dy / self.scale
		self:unfollow()
	end
end

return cam