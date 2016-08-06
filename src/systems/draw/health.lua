return function(e)
    local components = { "width", "health" }
	for i=1, #components do
		if not e[components[i]] then
			return false
		end
	end

    love.graphics.setColor(205,50,50)
	love.graphics.rectangle('fill', e.x, e.y - 10, e.width, 5)
	love.graphics.setColor(50,205,50)
	love.graphics.rectangle('fill', e.x, e.y - 10, e.health/100 * e.width, 5)
end