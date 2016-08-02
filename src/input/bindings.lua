local bindings = {}


function bindings:load()

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
	
end

function bindings:unload()
	bind:removeBind("playerRight")
	bind:removeBind("playerLeft")
	bind:removeBind("playerUp")
	bind:removeBind("playerDown")
end











return bindings