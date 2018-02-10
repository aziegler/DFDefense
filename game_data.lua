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

function dataLoad(roads,buildings)
	dofile("assets/config.txt")

   for i = 1, roads.count do
      roads.list[i] = {}
   end
   layerData = love.image.newImageData("assets/layer.bmp")
   for x = 1, layerData:getWidth() - 1 do
      local road_index = 1
      for y = 1, layerData:getHeight() - 1 do
         local r,g,b,a = layerData:getPixel( x,y )
         if (r == 0 and g == 0 and b == 0) then
            if not(roads.list[road_index][x] == nil) and math.abs(roads.list[road_index][x] - y) > 10 then
               road_index = road_index + 1
            end
            local road = roads.list[road_index]
            if (#road == 0 or x == 1 or math.abs(road[(x-1)] - y) < 10) then
               road[x] = y
            else
               road[x] = road[x-1]
            end
         elseif r == 255 and g == 0 and b == 0 then
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
   print ("Building Count "..#buildings.list)
end

function new_tower()
   local tower_type = tower_types[math.random(1,#tower_types)]
   local tower = {}
   tower.width = math.random(10,30)
   tower.height = math.random(10,30)
   tower.enabled = false
   tower.color = {}
   tower.color.red = tower_type.color[1]
   tower.color.blue = tower_type.color[2]
   tower.color.green = tower_type.color[3]
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
   enemy.color.blue = enemy_type.color[2]
   enemy.color.green = enemy_type.color[3]
   enemy.speed = enemy_type.speed
   enemy.dps = enemy_type.dps
   enemy.range = enemy_type.range
   enemy.road_index = math.random(1,roads)
   enemy.x = 5
   enemy.y = 5
   enemy.life = enemy_type.life
   return enemy
end
