require "audio"
require "game_data"
require "build_menu"

local roads = {}
roads.count = 3
roads.list = {}

local enemyCoolDown = 0
local enemies = {}
enemies.list = {}

local hoveredName = ""

local towers = {}
towers.list = {}

local buildings = {}
buildings.list = {}

local enemy_gq = {}
enemy_gq.list = {}

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
      local _,clickedTower = getTower(x,y)
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
               local infl = math.max(math.min(building.score * 0.1, 100 - clickedBuilding.score),0)
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
   if x == nil or y == nil then
      return -1,nil
   end
   for idx,building in pairs(buildings.list) do
      if x >= building.x and x <= building.x + building.width and y >= building.y and y <= building.y + building.height then
         return idx,building
      end
   end
   return -1,nil
end

function getTower(x,y)
   if x == nil or y == nil then
      return -1, nil
   end
   for idx,tower in pairs(towers.list) do
      if x >= tower.x and x <= tower.x + tower.width and y >= tower.y and y <= tower.y + tower.height then
         return idx,tower
      end
   end
   return -1, nil
end

function love.load(arg)

   dataLoad(roads, buildings, towers, enemy_gq)

   audioLoad(audioConfig)

   love.graphics.setFont(love.graphics.newFont("assets/ArmWrestler.ttf",24))

   imgBuildings = {
      Drouate = love.graphics.newImage("assets/buildings/BtmD_Tower.png"),
      Goche = love.graphics.newImage("assets/buildings/BtmG_Tower.png"),
      Neutre = love.graphics.newImage("assets/buildings/BtmN_Tower.png")
   }
   imgEnemyGQ = {
      Police = love.graphics.newImage("assets/buildings/BtmD_police.png"),
      Defense = love.graphics.newImage("assets/buildings/BtmD_BigTower.png"),
   }
   imgUI = {
      Jauge = love.graphics.newImage("assets/UI/Jauge.png"),
      Rouge = love.graphics.newImage("assets/UI/Barre_rouge.png"),
      Bleu = love.graphics.newImage("assets/UI/Barre_bleue.png")
   }

   enemy_gq.list[2].img = imgEnemyGQ.Police
   enemy_gq.list[1].img = imgEnemyGQ.Defense

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
      for tw_idx,tower in pairs(towers.list) do
         local width, height = tower.x-(building1.x+building1.width/2), tower.y-(building1.y+building1.height/2)
         local distance = (width*width + height*height)^0.5
         if building1.score < -100 and distance < enemyBuilding.range then
            tower.score = tower.score - enemyBuilding.dps * dt
            if tower.score < 0 then
               table.remove(towers.list,tw_idx)
               tower.building.tower = nil
               tower.building.score = tower.score
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
   voiceOn, tbs = audioUpdate()

   for idx,enemy in pairs(enemies.list) do
      enemy.roadStep = (enemy.roadStep + (enemy.speed * dt))
      if enemy.roadStep > roads.list[enemy.road_index].lastPoint then
         table.remove(enemies.list,idx)
      end
      if not (roads.list[enemy.road_index].points[math.floor(enemy.roadStep)] == nil) then
         enemy.y = roads.list[enemy.road_index].points[math.floor(enemy.roadStep)].y
         enemy.x = roads.list[enemy.road_index].points[math.floor(enemy.roadStep)].x
      end
   end

   totalScore = 0
   for _,tower in pairs(towers.list) do
      tower.score = tower.score + tower.influence_rate * dt
      if tower.score > 0 then
         totalScore = totalScore + tower.score
      end
   end

   if totalScore <= 0 then
      print("GAME OVER!!!")
   end

   compute_damage(dt)

   enemyCoolDown = enemyCoolDown + dt
   if tbs and enemyCoolDown > tbs then --math.random(0,100) > 99 and voiceOn then
      table.insert(enemies.list, new_enemy(roads.count))
      enemyCoolDown = 0
   end

   mouseModes.mousePos = { love.mouse.getX()/scale, love.mouse.getY()/scale }

   local idx, tower = getTower(mouseModes.mousePos[1], mouseModes.mousePos[2])
   local b_idx, building = getBuilding(mouseModes.mousePos[1], mouseModes.mousePos[2])
   hoveredName = nil
   if idx > -1 then
      print("Tower hovered")
      hoveredName = tower.name
   elseif b_idx > -1 then
      if building.score >= gameplayVariable.buildingTreshold then
            hoveredName = gameplayVariable.friendlyName
         elseif building.score >= -100 then
            hoveredName = gameplayVariable.neutralName
         else
            hoveredName = enemyBuilding.name
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

function draw_enemy(enemy)
   if enemy.img then
      love.graphics.setColor(255, 255, 255, 255)
      love.graphics.draw(enemy.img,
                         enemy.x-enemy.img:getWidth()/2,
                         enemy.y-enemy.img:getHeight())
   else
      love.graphics.setColor(enemy.color.red, enemy.color.green, enemy.color.blue)
      love.graphics.rectangle("fill",enemy.x - 20,enemy.y - 20,40,40)
   end

   love.graphics.setColor(50, 50, 180, 255)
   love.graphics.circle("line", enemy.x, enemy.y, enemy.range)
   love.graphics.setColor(255,0,0)
   love.graphics.print(math.floor(enemy.life),enemy.x - 7 ,enemy.y - 5,0)

end

function draw_gauge(influenceRatio,x,y)
   love.graphics.draw(imgUI.Jauge,x + 15,y - imgUI.Jauge:getHeight() - 10)
   love.graphics.draw(imgUI.Rouge,x + 17,y - imgUI.Jauge:getHeight() -5, 0, 72 * influenceRatio / imgUI.Rouge:getWidth(), 1)
   love.graphics.draw(imgUI.Bleu,
                      x + 17 + (72 * influenceRatio),
                      y - imgUI.Jauge:getHeight() -5, 0, 
                      72 * (1 - influenceRatio) / imgUI.Bleu:getWidth(), 1)
end

function draw_tower(tower)
   local h = tower.y
   local x = tower.x
   if tower.img then
      love.graphics.setColor(255, 255, 255)
      h  = tower.y - tower.img:getHeight() + tower.height
      if tower.center == true then
         h = tower.y - tower.img:getHeight()/2 + tower.height/2
      end
      x = tower.x - tower.img:getWidth()/2 + tower.width/2
      love.graphics.draw(tower.img, x , h)

   else
      love.graphics.setColor(tower.color.red,tower.color.green,tower.color.blue)
      love.graphics.rectangle("fill", tower.x, tower.y, tower.width, tower.height)
   end
   local influenceRatio = math.max(0,math.min((tower.score) / 200,1))

   
   draw_gauge(influenceRatio, x, h)
   love.graphics.print("Score "..math.floor(tower.score),tower.x + 10, tower.y + 20,0)
   love.graphics.setColor(180, 50, 50, 255)
   love.graphics.circle("line",
                        tower.x+tower.width/2,
                        tower.y+tower.height/2, tower.range)
end

function drawBuildings(img, building)
   love.graphics.draw(img,
                      building.x+building.width/2-img:getWidth()/2,
                      building.y+building.height-img:getHeight())
end

function drawBuildingsMiddle(img, building)
   love.graphics.draw(img,
                      building.x+building.width/2-img:getWidth()/2,
                      building.y+building.height/2-img:getHeight()/2)
end

function drawHover(text)
   love.graphics.setColor(255,255,255,255)
   love.graphics.rectangle("fill",mouseModes.mousePos[1],mouseModes.mousePos[2],200,100)
   love.graphics.setColor(0,0,0,255)
   love.graphics.printf(text,mouseModes.mousePos[1] + 10,mouseModes.mousePos[2] + 5,180,"center")
end

function sortY(obj1, obj2)
   return obj1.y < obj2.y
end

function love.draw()
   love.graphics.scale(scale,scale)

   for i = 1, roads.count do
      love.graphics.setColor(100,100,100)
      for j = 1, roads.list[i].lastPoint - 1 do
         love.graphics.points(roads.list[i].points[j].x,roads.list[i].points[j].y)
      end
   end

   local drawList = {}
   for _,enemy in pairs(enemies.list) do
      enemy.enemy = true
      table.insert(drawList, enemy)
   end

   for _,building in pairs(buildings.list) do
      table.insert(drawList, building)
   end
   table.insert(drawList, enemy_gq.list[1])
   table.insert(drawList, enemy_gq.list[2])

   table.sort(drawList, sortY)

   for _,building in pairs(drawList) do
      love.graphics.setColor(255,255,255,255)
      if building.enemy then
         draw_enemy(building)
      elseif building.img then
         drawBuildings(building.img, building)
      elseif not building.tower then
         love.graphics.setColor(255,255,255,255)
         if building.score >= gameplayVariable.buildingTreshold then
            drawBuildings(imgBuildings.Goche, building)
         elseif building.score >= -100 then
            --love.graphics.setColor(100,100,100,255)
            drawBuildings(imgBuildings.Neutre, building)
         else
            love.graphics.setColor(50, 50, 180, 255)
            love.graphics.circle("line",
                        building.x+building.width/2,
                        building.y+building.height/2, enemyBuilding.range)
            love.graphics.setColor(255,255,255,255)
            drawBuildings(imgBuildings.Drouate, building)
         end
         --love.graphics.rectangle("fill",building.x,building.y,building.width,building.height)
         love.graphics.setColor(50,50,50,255)
         love.graphics.print("Score "..math.floor(building.score), building.x + 20, building.y - 30, 0)

      else
         draw_tower(building.tower)
      end
   end

   --love.graphics.setColor(255,255,255,255)
   --drawBuildingsMiddle(imgEnemyGQ.Police, enemy_gq.list[2]);
   --drawBuildings(imgEnemyGQ.Defense, enemy_gq.list[1]);


   if mouseMode == mouseModes.gui then
      drawMenu()
   elseif not (hoveredName == nil) then
      drawHover(hoveredName)
   end

   audioDraw()

end
