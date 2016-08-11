return function(e)
	local components = { "animated", "x", "y" }
	for i=1, #components do
		if not e[components[i]] then
			return false
		end
	end

	local xscale = 1
	local x = e.x
	if e.xvel < 0 then
		xscale = -1
		x = x + e.curAnim.frameWidth * e.curAnim.scale
	end

    e.curAnim:draw(x, e.y, xscale)
end