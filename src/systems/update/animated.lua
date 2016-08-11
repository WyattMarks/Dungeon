return function(e, dt)
	local components = { "animated", "x", "y"}
	for i=1, #components do
		if not e[components[i]] then
			return false
		end
	end

    e.curAnim:update(dt)
end