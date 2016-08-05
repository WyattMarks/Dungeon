local bindings = {}


function bindings:load()

	bind:addBind("playerRight", settings.binds.right, function(down)
	    local e = game:getLocalPlayer()
		e.xvel = down and e.speed or 0
	end)
	bind:addBind("playerLeft", settings.binds.left, function(down)
	    local e = game:getLocalPlayer()
		e.xvel = down and -e.speed or 0
	end)
	bind:addBind("playerUp", settings.binds.up, function(down)
	    local e = game:getLocalPlayer()
		e.yvel = down and -e.speed or 0
	end)
	bind:addBind("playerDown", settings.binds.down, function(down)
	    local e = game:getLocalPlayer()
		e.yvel = down and e.speed or 0
	end)
	bind:addMouseBind("playerShoot", settings.binds.shoot, function(down, x, y)
		game:getLocalPlayer().firing = down
		-- if down then game:getLocalPlayer():shoot(x, y) end
	end)
	
end

function bindings:unload()
	bind:removeBind("playerRight")
	bind:removeBind("playerLeft")
	bind:removeBind("playerUp")
	bind:removeBind("playerDown")
end











return bindings
