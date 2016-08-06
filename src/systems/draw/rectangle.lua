return function(e)
	local components = { "color", "width", "height", "x", "y" }
	for i=1, #components do
		if not e[components[i]] then
			return false
		end
	end

	love.graphics.setColor(e.color)
	love.graphics.rectangle('fill', e.x, e.y, e.width, e.height)
end