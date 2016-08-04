local util = {}

-- local binser = require 'src.thirdparty.binser'
local bitser = require 'src.thirdparty.bitser'
-- local knifeser = require 'src.thirdparty.knifeser'

function util:pack(data)
	--return Tserial.pack(data)
	return (bitser.dumps(data))
end

function util:unpack(data)
	--return Tserial.unpack(data)
	return (bitser.loads(data))
end

function util:copyTable(tbl)
	local new = {}
	for k,v in pairs(tbl) do
		if type(v) == "table" then
			new[k] = self:copyTable(v)
		else
			new[k] = v
		end
	end
	
	return new
end

function util:roundMultiple(num, mult)
	return math.floor(num/mult)*mult
end

function util:getRandomPointInEllipse(width, height) 
	local t = 2*math.pi*math.random()
	local u = math.random()+math.random()
	local r = nil
	if u > 1 then r = 2-u else r = u end
	return width*r*math.cos(t), height*r*math.sin(t)
end

function util:rectangleCollision(rect1, rect2)
	return not (rect2.x > rect1.x + rect1.width * tile.tileSize or rect2.x + rect2.width * tile.tileSize < rect1.x or rect2.y > rect1.y + rect1.height * tile.tileSize or rect2.y + rect2.height * tile.tileSize < rect1.y)	
end

function util:distance(x,y,x2,y2)
	return math.sqrt( (x-x2)^2 + (y-y2)^2 )
end


return util;
