return function (e, dt)
    if not (e.isAI and e.speed) then return false end

	e.timer = (e.timer or 0) - dt

	if e.timer <= 0 then
		e.timer = math.random(1,4)
        e.xvel = math.random() * 2 * e.speed - e.speed
        e.yvel = math.random() * 2 * e.speed - e.speed
	end
end

