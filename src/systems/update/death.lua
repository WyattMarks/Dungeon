return function(e, dt)
	if not server.hosting or not e.health or not e.die then return false end

	if e.health <= 0 then
		e:die()
	end

end