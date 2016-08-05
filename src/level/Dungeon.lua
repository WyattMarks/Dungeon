tile = require("src/level/tile")
room = require("src/level/room")
hall = require("src/level/hall")
delauney = require("src/thirdparty/delauney")
kruskals = require("src/thirdparty/kruskals")

local Dungeon = {}
Dungeon.rooms = {}
Dungeon.halls = {}
Dungeon.maxRooms = 150 --Max rooms that would generate (Only would realistically get this many with a HUGE spread)
Dungeon.mapWidth = 120 --Ellipse x axis
Dungeon.mapHeight = 60 --Ellipse y axis 
Dungeon.minSpread = 200 --The minimum amount the room qill move outward
Dungeon.maxSpread = 2000 --Maximum of ^
Dungeon.roomSizeThreshold = .8 --The percentage of the average size that a room must be to keep it
Dungeon.minRooms = 5 --The minimum number of rooms in the dungeon
Dungeon.edgeAddBack = .15 --Adding back hallways for a better traversal

function Dungeon:generate()
	self.rooms = {}
	self.halls = {}
	self:generateRooms()
	self:generateMST()
	self:addRandomEdges()
	self:generateHalls()
end

function Dungeon:getRoomFromPoint(p)
	for k,room in pairs(self.rooms) do
		if p.x >= room.x and p.y >= room.y and p.x <= room.x + room.width*tile.tileSize and p.y <= room.y + room.height*tile.tileSize then
			return room
		end
	end

	return false
end

function Dungeon:generateHalls()
	for k, edge in pairs(self.MST) do
		local room1 = self:getRoomFromPoint(edge.p1)
		local room2 = self:getRoomFromPoint(edge.p2)

		local topRoom = room1
		local bottomRoom = room2
		if room2.y < room1.y then topRoom = room2 bottomRoom = room1 end

		local yDistance = bottomRoom.y - topRoom.y

		local rightRoom = room2
		local leftRoom = room1
		if room2.x < room1.x then rightRoom = room1 leftRoom = room2 end

		local xDistance = rightRoom.x - leftRoom.x

		local hallX, hallY = 0,0
		local hallW, hallH = 1,1
		local generated = false

		if yDistance < topRoom.height * tile.tileSize then --If it is possible to make just a horizontal hallway
			local y = util:roundMultiple(math.random(yDistance + topRoom.y, topRoom.y + topRoom.height * tile.tileSize), tile.tileSize)
			local x = leftRoom.x + leftRoom.width * tile.tileSize
			local h = 1
			local w = (rightRoom.x - (leftRoom.x + leftRoom.width * tile.tileSize))/tile.tileSize
			self.halls[#self.halls+1] = hall:new(#self.halls + 1, x, y, w, h)
			generated = true
		end

		if not generated then
			if xDistance < leftRoom.width * tile.tileSize then --Possible to just be a vertical hall?
				hallX = util:roundMultiple(math.random(xDistance + leftRoom.x, leftRoom.x + leftRoom.width * tile.tileSize), tile.tileSize)
				hallY = topRoom.y + topRoom.height * tile.tileSize
				hallW = 1
				hallH = (bottomRoom.y - (topRoom.y + topRoom.height * tile.tileSize))/tile.tileSize
				self.halls[#self.halls+1] = hall:new(#self.halls + 1, hallX, hallY, hallW, hallH)
				generated = true
			end
		end

		if not generated then --Must be a L shape then
			local y = topRoom.y + topRoom.height * tile.tileSize - math.random(1,room.minHeight) * tile.tileSize
			local x = leftRoom.x + leftRoom.width * tile.tileSize
			local h = 1
			local w = 0

			if x < topRoom.x then
				x = x - math.random(1,room.minWidth) * tile.tileSize
			else
				w = w + math.random(1, room.minWidth)
			end

			w = w + (rightRoom.x - x)/tile.tileSize

			self.halls[#self.halls+1] = hall:new(#self.halls + 1, x, y, w, h)
			if x > topRoom.x then
				x = x + w * tile.tileSize - tile.tileSize
			end
			y = y + tile.tileSize
			w = 1
			h = (bottomRoom.y - y) / tile.tileSize
			self.halls[#self.halls+1] = hall:new(#self.halls + 1, x, y, w, h)
			generated = true
		end
	end
end

function Dungeon:addRandomEdges()
	local addBack = math.floor(#self.edges * self.edgeAddBack)

	for i=1, addBack do
		local edge = self.edges[math.random(1,#self.edges)]
		while self:edgeAdded(self.MST, edge) do
			edge = self.edges[math.random(1,#self.edges)]
		end

		self.MST[#self.MST + 1] = edge
	end
end

function Dungeon:generateMST()
	local Edge = delauney.Edge
	local Point = delauney.Point


	self.points = {}
	for k, room in pairs(self.rooms) do
		self.points[#self.points+1] = Point(math.floor(room.x + room.width * tile.tileSize / 2), math.floor(room.y + room.height * tile.tileSize / 2))
	end

	local triangles = delauney.triangulate(unpack(self.points))
	self.edges = {}

	for i=1, #triangles do
		local p1 = triangles[i].p1
		local p2 = triangles[i].p2
		local p3 = triangles[i].p3

		local edge1 = Edge(p1,p2)
		local edge2 = Edge(p3,p2)
		local edge3 = Edge(p1,p3)

		if not self:edgeAdded(self.edges, edge1) then
			self.edges[#self.edges + 1] = edge1
		end
		if not self:edgeAdded(self.edges, edge2) then
			self.edges[#self.edges + 1] = edge2
		end
		if not self:edgeAdded(self.edges, edge3) then
			self.edges[#self.edges + 1] = edge3
		end
	end

	local function compare(a, b) if a:length() < b:length() then return a end end
	table.sort(self.edges, compare)

	self.MST = kruskals(self.points, self.edges)
end

function Dungeon:edgeAdded(edges, edge)
	for i=1, #edges do
		if edges[i]:same(edge) then return true end
	end
	return false
end

function Dungeon:generateRooms()
	local widthAvg = 0
	local heightAvg = 0
	for i=1, self.maxRooms do
		local x,y = util:getRandomPointInEllipse(self.mapWidth/2, self.mapHeight/2)
		local angle = math.atan2(x, y)
		x = util:roundMultiple(math.cos(angle) * math.random(self.minSpread, self.maxSpread), tile.tileSize)
		y = util:roundMultiple(math.sin(angle) * math.random(self.minSpread, self.maxSpread), tile.tileSize)
		self.rooms[i] = room:new(i, x, y)
		widthAvg = widthAvg + self.rooms[i].width
		heightAvg = heightAvg + self.rooms[i].height
	end
	widthAvg = widthAvg / #self.rooms
	heightAvg = heightAvg / #self.rooms

	self:removeSmallRooms(widthAvg, heightAvg)
	self:removeCollidingRooms()

	local numRooms = 0
	for k,v in pairs(self.rooms) do numRooms = numRooms + 1 end
	if numRooms < self.minRooms then
		self:generate()
	end
end


function Dungeon:removeCollidingRooms()
	for k,room1 in pairs(self.rooms) do
		for l,room2 in pairs(self.rooms) do
			if room1 ~= room2 and util:rectangleCollision(room1, room2) then
				self.rooms[room1.id] = nil
			end
		end
	end
end

function Dungeon:removeSmallRooms(widthAvg, heightAvg)
	for k, room in pairs(self.rooms) do
		if room.width < widthAvg * self.roomSizeThreshold or room.height < heightAvg * self.roomSizeThreshold then
			self.rooms[room.id] = nil
		end
	end
end

function Dungeon:draw()
	for k, hall in pairs(self.halls) do
		hall:draw()
	end
	for k, room in pairs(self.rooms) do
		room:draw()
	end
end

function Dungeon:update(dt)
end


return Dungeon