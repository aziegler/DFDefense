require "audio"
require "game_data"

local layerData

local roads = {}
roads.count = 3
roads.list = {}

local enemies = {}
enemies.list = {}

local towers = {}
towers.list = {}
towers.current_tower = {}

local buildings = {}
buildings.list = {}



function love.mousepressed(x,y,button,istouch)
   if not (towers.current_tower.enabled) then
      return
   end
   for idx, building in pairs(buildings.list) do
      if collide(towers.current_tower,building) then
         towers.current_tower.x = building.x
         towers.current_tower.y = building.y
         towers.current_tower.width = building.width
         towers.current_tower.height = building.height
         table.remove(buildings.list,idx)
         table.insert(towers.list,towers.current_tower)
         towers.current_tower = new_tower()
         return
      end
   end
end

function love.load()
   audioLoad()
   dataLoad()

   love.window.setFullscreen(true)
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
            local already_added = false
            for _,building in pairs(buildings.list) do
               if x >= building.x and x <= building.x + building.width and y >= building.y and y <= building.y + building.height then
                  already_added = true
               end
            end
            if not already_added then
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
   for i,road in pairs(roads.list) do
      if(#road < 20) then
         table.remove(roads.list,i)
      end
   end
   towers.current_tower = new_tower()
end

function compute_damage(dt)
   for en_idx,enemy in pairs(enemies.list) do
      for _,tower in pairs(towers.list) do
         local width, height = enemy.x-tower.x, enemy.y-tower.y
         local distance = (width*width + height*height)^0.5
         if distance  < tower.range then
            enemy.life = enemy.life - tower.dps * dt
            if enemy.life < 0 then
               table.remove(enemies.list,en_idx)
               break
            end
         end
      end
   end
end

function love.keypressed(key)
   if key == "escape" then
      love.event.quit()
   end
end

function love.update (dt)
   audioUpdate()

   for _,enemy in pairs(enemies.list) do
      enemy.x = (enemy.x + (enemy.speed * dt))
      if not (roads.list[enemy.road_index][math.floor(enemy.x)] == nil) then
         enemy.y = roads.list[enemy.road_index][math.floor(enemy.x)]

      end
   end


   compute_damage(dt)

   if math.random(0,100) > 99 then
      table.insert(enemies.list, new_enemy(#roads.list))
   end


   towers.current_tower.x = love.mouse.getX()
   towers.current_tower.y = love.mouse.getY()

   towers.current_tower.enabled = false

   local r,g,b,a = layerData:getPixel(towers.current_tower.x,towers.current_tower.y)
   if r == 255 and g == 0 and b == 0 then
      towers.current_tower.enabled = true
      for _,tower in pairs(towers.list) do
         if collide(tower,towers.current_tower) then
            towers.current_tower.enabled = false
         end
      end
   end
end



function collide(tower1,tower2)
   if (tower1.x < tower2.x + tower2.width and
      tower1.x + tower1.width > tower2.x and
      tower1.y < tower2.y + tower2.height and
      tower1.height + tower1.y > tower2.y) then
         return true
      end
   return false
end

function draw_enemy(ennemy)
   love.graphics.setColor(ennemy.color.red, ennemy.color.green, ennemy.color.blue)
   love.graphics.rectangle("fill",ennemy.x - 10,ennemy.y - 10,20,20)
   love.graphics.setColor(0,0,0)
   love.graphics.print(math.floor(ennemy.life),ennemy.x - 7 ,ennemy.y - 5,0)
end

function draw_tower(tower)
   if tower.enabled then
      love.graphics.setColor(tower.color.red,tower.color.green,tower.color.blue)
   else
      love.graphics.setColor(tower.color.red,tower.color.green,tower.color.blue,100)
   end
   love.graphics.rectangle("fill", tower.x, tower.y, tower.width, tower.height)
   love.graphics.setColor(tower.color.red, tower.color.green, tower.color.blue, 50)
   love.graphics.circle("fill", tower.x, tower.y, tower.range)
end

function love.draw()
   for i = 1, #roads.list do
      love.graphics.setColor(100,100,100)
      for j = 1, #roads.list[i] do
         love.graphics.points(j,roads.list[i][j])
      end
   end
   love.graphics.setColor(255, 0, 0, 255)
   for _,building in pairs(buildings.list) do
      love.graphics.rectangle("fill",building.x,building.y,building.width,building.height)
   end
   for _,enemy in pairs(enemies.list) do
      draw_enemy(enemy)
   end
   for _,tower in pairs(towers.list) do
      draw_tower(tower)
   end
   draw_tower(towers.current_tower)

   love.graphics.setColor(0,0,255)
   love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),20)
   
   audioDraw()

end
