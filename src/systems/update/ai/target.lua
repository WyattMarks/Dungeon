-- check if entity a can see entity b
local function canSee(a, b)
	local function filter(e, other)
		if other.type == "brick" then
			return "slide"
		end
		return false
	end

	local x, y, cols, len = world:check(a, b.x, b.y, filter)

	return len == 0
end

return function (e, dt)

    if not e.targetsPlayers then return false end

	local players = {}
	for _, player in pairs(server.players) do
		players[#players+1] = {
		    util:distance(e.x, e.y, player.x, player.y),
		    player
	    }
	end

	table.sort(players, function( b, a ) return a[1] > b[1] end)

	for i=1, #players do
		local player = players[i][2]

		if canSee(e, player) and players[i][1] < e.range then
		    e.targetX = player.x + player.width / 2
		    e.targetY = player.y + player.height / 2
			return
		end
	end
	
    e.targetX = nil
    e.targetY = nil
end
