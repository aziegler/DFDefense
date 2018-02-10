tower_types = {}
enemyBuilding = {}
gameplayVariable = {}

local enemy_types = {}

local layerData

function Video (v)
   videoSettings = v
end

function Tower (t)
   if t.img then
      t.img = love.graphics.newImage(t.img)
   end
   table.insert(tower_types, t)
end

function Enemy (e)
   if e.img then
      e.img = love.graphics.newImage(e.img)
   end
   table.insert(enemy_types, e)
end

function EnemyBuilding(b)
   enemyBuilding = b
end

function GameplayVariable(g)
   gameplayVariable = g
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

function loadRoads(roads)
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
end

function loadSquare(cont, towers, R, G, B)
   for x = 1, layerData:getWidth() - 1 do
      for y = 1, layerData:getHeight() - 1 do
         local r,g,b,a = layerData:getPixel( x,y )
         --print(x,y,r,g,b,a)
         if r == R and g == G and b == B then
            local building = getAddedBuilding(x,y,cont)
            if building == nil then
               local width, height = 0,0
               while r == R and g == G and b == B do
                  width = width + 1
                  r,g,b,a = layerData:getPixel(x + width, y)
               end
               r,g,b,a = layerData:getPixel( x ,y + height )
               while r == R and g == G and b == B do
                  r,g,b,a = layerData:getPixel(x, y + height)
                  height = height + 1
               end
               if x > 1500 then
                  local concertBuilding = {x = x,y = y,width = width,height = height,score = gameplayVariable.initialConcertInfluence}
                  local concertTower = {
                     name = "Concert",
                     range = gameplayVariable.concertRange,
                     dps = gameplayVariable.concertDps,
                     score = gameplayVariable.initialConcertInfluence,
                     influence_rate = gameplayVariable.concertInfluenceRate,
                     color = {red = 255,green = 30,blue = 30},
                     img = love.graphics.newImage("assets/buildings/BtmG_DanielFeryr.png"),
                     x = concertBuilding.x,
                     y = concertBuilding.y,
                     width = concertBuilding.width,
                     height = concertBuilding.height,
                     center = true,
                     enabled = true,
                     building = concertBuilding,
                     name="DF"
                  }
                  concertBuilding.tower = concertTower
                  table.insert (cont.list, concertBuilding)
                  table.insert(towers.list, concertTower)
               else
                  table.insert(cont.list,{x = x,y = y,width = width,height = height,score = 0, name="Tests"})
               end
            end
         end
      end
   end
end

function loadBuildings(B, T)
   loadSquare(B, T, 255, 0, 0)
end

function loadBG(B, T)
   loadSquare(B, T, 0, 0, 255)
end

function dataLoad(roads,buildings, towers, enemy_gq)
	dofile("assets/config.txt")

   for i = 1, roads.count do
      roads.list[i] = {}
      roads.list[i].lastPoint = 1
      roads.list[i].points = {}
   end
   layerData = love.image.newImageData("assets/layer.bmp")
   loadRoads(roads)

   loadBuildings(buildings,towers)
   loadBG(enemy_gq, { list = {} })

end

function new_tower(idx)
   local tower_type = 0
   if idx then
      tower_type = tower_types[idx]
   else
      tower_type = tower_types[math.random(1,#tower_types)]
   end

   local tower = {}
   tower.width = math.random(10,30)
   tower.height = math.random(10,30)
   tower.enabled = false
   tower.color = {}
   tower.color.red = tower_type.color[1]
   tower.color.green = tower_type.color[2]
   tower.color.blue = tower_type.color[3]
   tower.img = tower_type.img
   tower.range = tower_type.range
   tower.dps = tower_type.dps
   tower.score = tower_type.influence
   tower.influence_rate = tower_type.influence_rate
   tower.name = tower_type.name
   return tower
end


function new_enemy(roads)
   local enemy_type = enemy_types[math.random(1,#enemy_types)]
   local enemy = {}
   enemy.color = {}
   enemy.color.red = enemy_type.color[1]
   enemy.color.green = enemy_type.color[2]
   enemy.color.blue = enemy_type.color[3]
   enemy.img = enemy_type.img
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
