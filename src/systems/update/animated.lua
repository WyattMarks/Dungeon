return function(e, dt)
	local components = { "animated", "x", "y"}
	for i=1, #components do
		if not e[components[i]] then
			return false
		end
	end

	if e.curAnim.dir == -1 and e.xvel > 0 then
        e.curAnim.dir = 1
    elseif e.xvel < 0 then
        e.curAnim.dir = -1
    end

    e.curAnim:update(dt)
end