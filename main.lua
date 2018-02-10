require "audio"
require "game_data"
require "build_menu"

local roads = {}
roads.count = 3
roads.list = {}

local enemies = {}
enemies.list = {}

local towers = {}
towers.list = {}

local buildings = {}
buildings.list = {}

function Audio (a)
   audioConfig = a
end

mouseModes = {
   pick = 1,
   gui = 2,
   menuPos = {},
   mousePos = { 0, 0 }
}
mouseMode = mouseModes.pick

function mouseGui(x,y,button,istouch)
   local idx = pickMenu(mouseModes.mousePos[1] ,mouseModes.mousePos[2])
   if idx == 0 then
      mouseMode = mouseModes.pick
      return
   end

   local tower = new_tower(idx)

   local building = mouseModes.building

   tower.x = building.x
   tower.y = building.y
   tower.width = building.width
   tower.height = building.height
   tower.enabled = true
   tower.building = building
   --table.remove(buildings.list,mouseModes.buildingIdx)
   if building.tower then
      for k,v in pairs(towers.list) do
         if v == building.tower then
            table.remove(towers.list,k)
            break
         end
      end
   end

   building.tower = tower
   table.insert(towers.list,tower)

   mouseMode = mouseModes.pick
end

function mousePick(x,y,button,istouch)
   x = mouseModes.mousePos[1]
   y = mouseModes.mousePos[2]
   if button == 2 then
      local idx,building = getBuilding(x, y)

      if idx > -1 and building.score > gameplayVariable.buildingTreshold then
         mouseMode = mouseModes.gui
         mouseModes.menuPos = { x= building.x + building.width/2,
                                   y= building.y }
         mouseModes.building = building
         mouseModes.buildingIdx = idx
      end
   end
   if button == 1 then
      local clickedTower = getTower(x,y)
      if not(clickedTower == nil) then
         for _, tower in pairs(towers.list) do
            local infl = tower.score * 0.1
            tower.score = tower.score - infl
            clickedTower.score = clickedTower.score + infl
         end
      else
      local _, clickedBuilding = getBuilding(x,y)
      if not(clickedBuilding == nil) then
         for _, tower in pairs(towers.list) do
            if tower.score >= 100 then
               local infl = math.min(tower.score * 0.1, 100 - clickedBuilding.score)
               tower.score = tower.score - infl
               clickedBuilding.score = clickedBuilding.score + infl
            end
         end
         for _, building in pairs(buildings.list) do
            if building.score >= 100 then
               local infl = math.min(building.score * 0.1, 100 - clickedBuilding.score)
               building.score = building.score - infl
               clickedBuilding.score = clickedBuilding.score + infl
            end
         end

      end
      end
   end
end

function love.mousepressed(x,y,button,istouch)
   if mouseMode == mouseModes.pick then
      mousePick(x,y,button,istouch)
   else
      mouseGui(x,y,button,istouch)
   end

end

function getBuilding(x,y)
   for idx,building in pairs(buildings.list) do
      if x >= building.x and x <= building.x + building.width and y >= building.y and y <= building.y + building.height then
         return idx,building
      end
   end
   return -1,nil
end

function getTower(x,y)
   for _,tower in pairs(towers.list) do
      if x >= tower.x and x <= tower.x + tower.width and y >= tower.y and y <= tower.y + tower.height then
         return tower
      end
   end

end

function love.load(arg)

   dataLoad(roads, buildings)
   audioLoad(audioConfig)

   for k,v in pairs(buildings.list) do
      for n,v2 in pairs(v) do
         print(k, n,v2)
      end
      print(" ")
   end

   if videoSettings.fullscreen == false or arg[2] == "-w" then
      scale = 0.5
      love.window.setMode(1920*scale,1080*scale)
   else
      scale = 1
      love.window.setFullscreen(true)
   end

end

function compute_damage(dt)
   for en_idx,enemy in pairs(enemies.list) do
      for tw_idx,tower in pairs(towers.list) do
         local width, height = enemy.x-(tower.x+tower.width/2), enemy.y-(tower.y+tower.height/2)
         local distance = (width*width + height*height)^0.5
         if distance  < tower.range then
            enemy.life = enemy.life - tower.dps * dt
            if enemy.life < 0 then
               table.remove(enemies.list,en_idx)
               break
            end
         end
         if distance < enemy.range then
            tower.score = tower.score - enemy.dps * dt
            if tower.score < 0 then
               table.remove(towers.list,tw_idx)
               tower.building.tower = nil
               tower.building.score = tower.score
               break
            end
         end
      end
   end
   for en_idx,enemy in pairs(enemies.list) do
      for _,building in pairs(buildings.list) do
         local width, height = enemy.x-(building.x+building.width/2), enemy.y-(building.y+building.height/2)
         local distance = (width*width + height*height)^0.5
         if distance < enemy.range then
            building.score = building.score - enemy.dps * dt
         end
      end
   end
   for _,building1 in pairs(buildings.list) do
      for _,building2 in pairs(buildings.list) do
         local width, height = building2.x-(building1.x+building1.width/2), building2.y-(building1.y+building1.height/2)
         local distance = (width*width + height*height)^0.5
         if building1.score < -100 and distance < enemyBuilding.range then
            building2.score = building2.score - enemyBuilding.dps * dt
         end
      end
   end
   for _,building1 in pairs(buildings.list) do
      for _,tower in pairs(towers.list) do
         local width, height = tower.x-(building1.x+building1.width/2), tower.y-(building1.y+building1.height/2)
         local distance = (width*width + height*height)^0.5
         if building1.score < -100 and distance < enemyBuilding.range then
            tower.score = tower.score - enemyBuilding.dps * dt
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
   voiceOn = audioUpdate()

   for idx,enemy in pairs(enemies.list) do
      enemy.roadStep = (enemy.roadStep + (enemy.speed * dt))
      if enemy.roadStep > roads.list[enemy.road_index].lastPoint then
         table.remove(enemies.list,en_idx)
      end
      if not (roads.list[enemy.road_index].points[math.floor(enemy.roadStep)] == nil) then
         enemy.y = roads.list[enemy.road_index].points[math.floor(enemy.roadStep)].y
         enemy.x = roads.list[enemy.road_index].points[math.floor(enemy.roadStep)].x
      end
   end

   for _,tower in pairs(towers.list) do
      tower.score = tower.score + tower.influence_rate * dt
   end

   compute_damage(dt)

   if math.random(0,100) > 99 and voiceOn then
      table.insert(enemies.list, new_enemy(roads.count))
   end

   mouseModes.mousePos = { love.mouse.getX()/scale, love.mouse.getY()/scale }
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
   love.graphics.setColor(50, 50, 180, 255)
   love.graphics.circle("line", ennemy.x, ennemy.y, ennemy.range)
   love.graphics.setColor(0,0,0)
   love.graphics.print(math.floor(ennemy.life),ennemy.x - 7 ,ennemy.y - 5,0)
end

function draw_tower(tower)
   if tower.img then
      love.graphics.setColor(255, 255, 255)
      love.graphics.draw(tower.img,
                         tower.x - tower.img:getWidth()/2 + tower.width/2,
                         tower.y - tower.img:getHeight() + tower.height)
   else
      love.graphics.setColor(tower.color.red,tower.color.green,tower.color.blue)
      love.graphics.rectangle("fill", tower.x, tower.y, tower.width, tower.height)
   end
   local influenceRatio = math.max(0,math.min((tower.score + 100) / 300,1))
   love.graphics.setColor(0,0,255)
   love.graphics.rectangle("fill",tower.x,tower.y,tower.width,10)
   love.graphics.setColor(255,0,0)
   love.graphics.rectangle("fill",tower.x,tower.y,tower.width * influenceRatio ,10)
   love.graphics.print("Score "..math.floor(tower.score),tower.x + 10, tower.y + 20)
   love.graphics.setColor(180, 50, 50, 255)
   love.graphics.circle("line",
                        tower.x+tower.width/2,
                        tower.y+tower.height/2, tower.range)
end

function love.draw()
   love.graphics.scale(scale,scale)

   for i = 1, roads.count do
      love.graphics.setColor(100,100,100)
      for j = 1, roads.list[i].lastPoint - 1 do
         love.graphics.points(roads.list[i].points[j].x,roads.list[i].points[j].y)
      end
   end
   for _,building in pairs(buildings.list) do
      if not building.tower then
         if building.score >= gameplayVariable.buildingTreshold then
            love.graphics.setColor(255,0,0,255)
         elseif building.score >= -100 then
            love.graphics.setColor(100,100,100,255)
         else
            love.graphics.setColor(0,0,255,255)
            love.graphics.setColor(50, 50, 180, 255)
            love.graphics.circle("line",
                        building.x+building.width/2,
                        building.y+building.height/2, enemyBuilding.range)
         end
         love.graphics.rectangle("fill",building.x,building.y,building.width,building.height)
         love.graphics.setColor(120,255,120,255)
         love.graphics.print("Score "..math.floor(building.score), building.x + 10, building.y + 50)
         
      end
   end
   for _,enemy in pairs(enemies.list) do
      draw_enemy(enemy)
   end
   for _,tower in pairs(towers.list) do
      draw_tower(tower)
   end

   -- we don't draw a tower on the mouse anymore, do we?
   --   draw_tower(towers.current_tower)

   if mouseMode == mouseModes.gui then
      drawMenu()
   end

   audioDraw()

end
