return function (e, dt)
    if not server.hosting or not (e.isAI and e.speed) then return false end

	e.timer = (e.timer or 0) - dt

	if e.timer <= 0 then
		if e.targetX and e.targetY then
			e.timer = math.random() * 2
			local x, y = e.targetX, e.targetY
			local pX = e.x + ((e.width / 2) or 0)
			local pY = e.y + ((e.height / 2) or 0)
			local angle = math.atan2(x - pX, y - pY)
			local speed = math.random() * 2 * e.speed
			e.xvel = speed * math.sin(angle)
			e.yvel = speed * math.cos(angle)
		else
			e.timer = math.random(1,4)
			e.xvel = math.random() * 2 * e.speed - e.speed
			e.yvel = math.random() * 2 * e.speed - e.speed
		end
	end
end

