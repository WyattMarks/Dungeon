local bindings = {}


function bindings:load()
	bind:addBind("tabMenu", settings.binds.tabMenu, function(down)
		hud.tabOpen = down
	end)
	bind:addBind("chat", settings.binds.chat, function(down)
		if not down then
			chatbox.open = true
		end
	end)
	bind:addBind("playerRight", settings.binds.right, function(down)
		if down and game.running and chatbox.open then return end
		game:getLocalPlayer().right = down
	end)
	bind:addBind("playerLeft", settings.binds.left, function(down)
		if down and game.running and chatbox.open then return end
		game:getLocalPlayer().left = down
	end)
	bind:addBind("playerUp", settings.binds.up, function(down)
		if down and game.running and chatbox.open then return end
		game:getLocalPlayer().up = down
	end)
	bind:addBind("playerDown", settings.binds.down, function(down)
		if down and game.running and chatbox.open then return end
		game:getLocalPlayer().down = down
	end)
	bind:addMouseBind("playerShoot", settings.binds.shoot, function(down, x, y)
		if game.running and chatbox.open then return end
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
	bind:removeBind("tabMenu")
end











return bindings