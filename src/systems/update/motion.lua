local function filter(a, b)
	if (a.owner and a.owner == b.id) or b.type == 'bullet' then
		return false
	else
		return "slide"
	end
end

return function (e, dt)
	local components = { "xvel", "yvel" }
	for i=1, #components do
		if not e[components[i]] then
			return false
		end
	end
	
	local xMove, yMove = e.x + e.xvel * dt, e.y + e.yvel * dt

	local actualX, actualY, cols = world:move(e, xMove, yMove, filter)
	e.x, e.y = actualX, actualY
	for i=1, #cols do
		for iterator=1, #game.systems.collide do
			game.systems.collide[iterator](e, cols[i])
		end
	end
end

