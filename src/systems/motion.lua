function filter(a, b)
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

	e.x, e.y = world:move(e, xMove, yMove, filter)
end

