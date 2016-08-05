return function(e, col)
	if e.type ~= "bullet" or not server.hosting then return end
	local hit = col.other

	if hit.health then
		hit.health = math.max(0, hit.health - e.damage)
	end

	game:removeEntity(e)
end