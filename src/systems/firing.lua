return function (e, dt) 
	if not e.isLocal and not server.hosting then return false end

    if e.cooldown and e.cooldown > 0 then
        e.cooldown = e.cooldown - dt
    elseif e.firing and e.targetX and e.targetY and e.x and e.y and e.bulletSpeed then
	    x, y = e.targetX, e.targetY
	    local pX = e.x + ((e.width / 2) or 0) - bullet.width / 2
	    local pY = e.y + ((e.height / 2) or 0) - bullet.height / 2
	    local angle = math.atan2(x - pX, y - pY)
        local xvel = e.bulletSpeed * math.sin(angle)
        local yvel = e.bulletSpeed * math.cos(angle)

        -- this makes it hard to aim, my bad
        --[[
	    if math.abs(xvel + self.xvel) > math.abs(xvel) then
		    xvel = xvel + self.xvel
	    end

	    if math.abs(yvel + self.yvel) > math.abs(yvel) then
		    yvel = yvel + self.yvel
	    end
	    --]]

		if e.isLocal then
	    	client:send("SHOOT", {x = pX, y = pY, xvel = xvel, yvel = yvel})
		else
	    	game:addEntity(bullet:new(e.id, pX, pY, xvel, yvel))
		end
	
        e.cooldown = (e.cooldown or 0) + (e.fireRate or 0.15)
    end
end
