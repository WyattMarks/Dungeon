local bindings = {}


function bindings:load()
	bind:addBind("tabMenu", settings.binds.tabMenu, function(down)
		hud.tabOpen = down
	end)
	bind:addBind("playerRight", settings.binds.right, function(down)
		game:getLocalPlayer().right = down
	end)
	bind:addBind("playerLeft", settings.binds.left, function(down)
		game:getLocalPlayer().left = down
	end)
	bind:addBind("playerUp", settings.binds.up, function(down)
		game:getLocalPlayer().up = down
	end)
	bind:addBind("playerDown", settings.binds.down, function(down)
		game:getLocalPlayer().down = down
	end)
	bind:addMouseBind("playerShoot", settings.binds.shoot, function(down, x, y)
		if down then
			game:getLocalPlayer():shoot(x, y)
		end
	end)
	
end

function bindings:unload()
	bind:removeBind("playerRight")
	bind:removeBind("playerLeft")
	bind:removeBind("playerUp")
	bind:removeBind("playerDown")
end











return bindings