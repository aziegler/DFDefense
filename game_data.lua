tower_types = {}

local enemy_types = {}

local layerData
function Video (v)
   videoSettings = v
end

function Tower (t)
   table.insert(tower_types, t)
end

function Enemy (e)
   table.insert(enemy_types, e)
end

function getAddedBuilding(x,y,buildings)
   for idx,building in pairs(buildings.list) do
      if x >= building.x and x <= building.x + building.width and y >= building.y and y <= building.y + building.height then
         return idx,building
      end
   end
end

function getEndPoint(roads, index)
   if roads.list[index] == nil then
      return nil
   end
   return getPoint(roads,index,roads.list[index].lastPoint - 1)
end

function getPoint(roads,roadIndex, pointIndex)
   if roads.list[roadIndex] == nil or pointIndex < 1 then
      return nil
   end
   return roads.list[roadIndex].points[pointIndex]
end

function addPoint(roads,index,x,y)
   if roads.list[index] == nil then
      return nil
   end
   if x < 1 or y < 1 then
      return
   end
   roads.list[index].points[roads.list[index].lastPoint] = {}
   roads.list[index].points[roads.list[index].lastPoint].x = x
   roads.list[index].points[roads.list[index].lastPoint].y = y 
   roads.list[index].lastPoint = roads.list[index].lastPoint + 1
end

function contains(roads,index,x,y)
   if roads.list[index] == nil then
      return nil
   end
   for _,point in pairs(roads.list[index].points) do
      if point.x == x and point.y == y then
         return true
      end
   end
   return false
end

function getNextPoint(roads,index)
   local endPoint = getEndPoint(roads,index)
   local previousPoint = getPoint(roads,index,roads.list[index].lastPoint - 2)
   for xStep = -1, 1 do
      for yStep = -1, 1 do   
         local nextX = math.max(math.min(endPoint.x + xStep,layerData:getWidth()),1)
         local nextY = math.max(math.min(endPoint.y + yStep,layerData:getHeight()),1)      
         local r,g,b,a = layerData:getPixel(nextX, nextY)
         if (r < 10 and g < 10 and b < 10) then
            if not(contains(roads,index,nextX,nextY)) then
               return nextX, nextY
            end
         end
      end
   end
   return -1,-1
end

function dataLoad(roads,buildings)
	dofile("assets/config.txt")

   for i = 1, roads.count do
      roads.list[i] = {}
      roads.list[i].lastPoint = 1
      roads.list[i].points = {}
   end
   layerData = love.image.newImageData("assets/layer.bmp")
   local road_index = 1   
   for y = 1, layerData:getHeight() - 1 do
      local x = 1
      local r,g,b,a = layerData:getPixel( x,y )
      if (r < 10 and g < 10 and b < 10) then
         local road = roads.list[road_index]
         road.points[road.lastPoint] = {}
         road.points[road.lastPoint].x = x
         road.points[road.lastPoint].y = y
         road.lastPoint = road.lastPoint + 1
         road_index = road_index + 1
      end
   end
   for j = 1, roads.count do
      x,y = 0,0
      while x > -1 do
         x,y = getNextPoint(roads,j)
         addPoint(roads,j,x,y)
      end
   end
   for x = 1, layerData:getWidth() - 1 do   
      for y = 1, layerData:getHeight() - 1 do
         local r,g,b,a = layerData:getPixel( x,y )
         if r == 255 and g == 0 and b == 0 then
            local building = getAddedBuilding(x,y,buildings)
            if building == nil then
               local width, height = 0,0
               while r == 255 and g == 0 and b == 0 do
                  width = width + 1
                  r,g,b,a = layerData:getPixel(x + width, y)
               end
               r,g,b,a = layerData:getPixel( x ,y + height )
               while r == 255 and g == 0 and b == 0 do
                  r,g,b,a = layerData:getPixel(x, y + height)
                  height = height + 1
               end
               table.insert(buildings.list,{x = x,y = y,width = width,height = height})
            end
         end
      end
   end
   print ("Road Count "..roads.count)
end

function new_tower()
   local tower_type = tower_types[math.random(1,#tower_types)]
   local tower = {}
   tower.width = math.random(10,30)
   tower.height = math.random(10,30)
   tower.enabled = false
   tower.color = {}
   tower.color.red = tower_type.color[1]
   tower.color.green = tower_type.color[2]
   tower.color.blue = tower_type.color[3]
   tower.range = tower_type.range
   tower.dps = tower_type.dps
   tower.enemyinfluence = 0
   tower.friendlyinfluence = tower_type.influence
   tower.influence_rate = tower_type.influence_rate
   return tower
end


function new_enemy(roads)
   local enemy_type = enemy_types[math.random(1,#enemy_types)]
   local enemy = {}
   enemy.color = {}
   enemy.color.red = enemy_type.color[1]
   enemy.color.green = enemy_type.color[2]
   enemy.color.blue = enemy_type.color[3]
   enemy.speed = enemy_type.speed
   enemy.dps = enemy_type.dps
   enemy.range = enemy_type.range
   enemy.road_index = math.random(1,roads)
   enemy.x = 5
   enemy.y = 5
   enemy.roadStep = 1
   enemy.life = enemy_type.life
   return enemy
end
