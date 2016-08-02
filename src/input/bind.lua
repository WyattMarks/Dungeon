local bind = {
    binds = {}
}

--[[Bind function setup:
    function bind(bool down, (optional bool isrepeat)
    
    end
]]

function bind:addBind(identifier, key, func)
    self.binds[identifier] = {key, func};
end

function bind:removeBind(identifier)
	self.binds[identifier] = nil;
end


function bind:update(dt)
    
end

function bind:keyreleased(key)
    for k,v in pairs(self.binds) do
        if v[1] == key then
            v[2](false);
        end
    end
end

function bind:keypressed(key, isrepeat)
    for k,v in pairs(self.binds) do
        if v[1] == key then
            v[2](true, isrepeat);
        end
    end
end

return bind;