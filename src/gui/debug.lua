local debug = {}
debug.on = true
debug.variables = {}
debug.log = {}
debug.offset = 10
debug.otherOffset = 80

function debug:add(key, value)
	value = value or ''
	for k,v in pairs(self.variables) do
		if v[1] == key then
			self.variables[k] = {key, value}
			return
		end
	end
	
	self.variables[#self.variables + 1] = {key, value}
end

function debug:remove(key)
	for i=#self.variables, 1, -1 do
		if self.variables[i][1] == key then
			table.remove(self.variables, i)
		end
	end
end

function debug:print(str)
	print(str)
	self.log[#self.log + 1] = {0, tostring(str)}
end


function debug:draw()
	if not self.on then return end
	
	if not self.font then self.font = font.small end
	
	love.graphics.setColor(255,255,255)
	love.graphics.setFont(self.font)
	
	
	local y = 10

	for i=#self.log, 1, -1 do
		if self.log[i][1] < 5 then
			love.graphics.setColor(255, 255, 255, math.min( 255, (5 / self.log[i][1] - 1) * 255) )
			love.graphics.print(self.log[i][2], 10, y)
			y = y + self.font:getHeight() + 2
		end
	end
	
	love.graphics.setColor(255,255,255)
	
	y = 10
	for i=1, #self.variables do
		
		local str = tostring(self.variables[i][1])
		if self.variables[i][2] ~= '' then
			str = str .. ":"
		end
		love.graphics.print(str, screenWidth - self.otherOffset, y)
		love.graphics.print(tostring(self.variables[i][2]), self.font:getWidth(tostring(self.variables[i][1])..":") + screenWidth - self.otherOffset + self.offset, y)
			
		self.otherOffset = math.max(self.otherOffset, self.font:getWidth(str) + self.font:getWidth(tostring(self.variables[i][2])) + 30)
		
		y = y + self.font:getHeight() + 2
	end
end


function debug:update(dt)
	for k,v in pairs(self.log) do
		v[1] = math.min(v[1] + dt, 5)
	end
end




return debug