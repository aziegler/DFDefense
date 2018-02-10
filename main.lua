require "audio"
require "game_data"


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

function Audio (a)
   audioConfig = a
end

local mouseModes = {
   pick = 1,
   gui = 2,
   menuPos = {}
}
mouseMode = mouseModes.pick

function mouseGui(x,y,button,istouch)
   print(x,y)
   if button == 1 then

      local building = mouseModes.building
      towers.current_tower.x = building.x
      towers.current_tower.y = building.y
      towers.current_tower.width = building.width
      towers.current_tower.height = building.height
      towers.current_tower.enabled = true
      table.remove(buildings.list,mouseModes.buildingIdx)
      table.insert(towers.list,towers.current_tower)
      towers.current_tower = new_tower()
      mouseMode = mouseModes.pick
   end
end

function mousePick(x,y,button,istouch)
   if button == 2 then
      if not (towers.current_tower.enabled) then
         return
      end
      local idx,building = getBuilding(towers.current_tower.x,towers.current_tower.y)
      if idx > -1 then
         mouseMode = mouseModes.gui
         mouseModes.menuPos = { x= building.x + building.width/2,
                                   y= building.y }
         mouseModes.building = building
         mouseModes.buildingIdx = idx
      end
   end
   if button == 1 then
      local clickedTower = getTower(x,y)
      if clickedTower == nil then
         return
      end
      for _, tower in pairs(towers.list) do
         local infl = tower.friendlyinfluence * 0.1
         tower.friendlyinfluence = tower.friendlyinfluence - infl
         clickedTower.friendlyinfluence = clickedTower.friendlyinfluence + infl
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

function love.load()

   dataLoad(roads, buildings)
   audioLoad(audioConfig)

   if videoSettings.fullscreen == true then
      scale = 1
      --love.window.setMode(1920*scale,1080*scale)
      love.window.setFullscreen(true)
   else
      scale = 0.5
      love.window.setMode(1920*scale,1080*scale)
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
         if distance < enemy.range then
            tower.enemyinfluence = tower.enemyinfluence + enemy.dps * dt
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

   for _,tower in pairs(towers.list) do
      tower.friendlyinfluence = tower.friendlyinfluence + tower.influence_rate * dt
   end

   compute_damage(dt)

   if math.random(0,100) > 99 then
      table.insert(enemies.list, new_enemy(#roads.list))
   end

   towers.current_tower.x = love.mouse.getX()/scale
   towers.current_tower.y = love.mouse.getY()/scale
   towers.current_tower.enabled = true
   
   local idx,building = getBuilding(towers.current_tower.x,towers.current_tower.y)
   if idx > -1 then
      towers.current_tower.enabled = true
   else 
      towers.current_tower.enabled = false
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
   love.graphics.setColor(50, 50, 180, 100)
   love.graphics.circle("fill", ennemy.x, ennemy.y, ennemy.range)
   love.graphics.setColor(0,0,0)
   love.graphics.print(math.floor(ennemy.life),ennemy.x - 7 ,ennemy.y - 5,0)
end

function draw_tower(tower)
   if tower.enabled then
      love.graphics.setColor(tower.color.red,tower.color.green,tower.color.blue)
   else
      love.graphics.setColor(tower.color.red,tower.color.green,tower.color.blue,20)
   end
   love.graphics.rectangle("fill", tower.x, tower.y, tower.width, tower.height)
   local influenceRatio = tower.friendlyinfluence / (tower.friendlyinfluence + tower.enemyinfluence)
   love.graphics.setColor(0,0,255)
   love.graphics.rectangle("fill",tower.x,tower.y,tower.width,10)
   love.graphics.setColor(255,0,0)
   love.graphics.rectangle("fill",tower.x,tower.y,tower.width * influenceRatio ,10)
   love.graphics.print("Friend "..math.floor(tower.friendlyinfluence/10).." Enemy"..math.floor(tower.enemyinfluence/10),tower.x + 10, tower.y + 20)
   love.graphics.setColor(180, 50, 50, 100)
   love.graphics.circle("fill", tower.x, tower.y, tower.range)
end

function drawMenu()
   local SIZE = 100
   local width = #tower_types * SIZE

   print(#tower_types)

   love.graphics.setColor(255,255,255)
   love.graphics.rectangle("fill",
                           mouseModes.menuPos.x-width/2,
                           mouseModes.menuPos.y-SIZE,
                           width, SIZE)

   for k,v in pairs(tower_types) do
      print(k,v)
      love.graphics.setColor(v.color[1], v.color[2], v.color[3])
      love.graphics.rectangle("fill",
                              5+mouseModes.menuPos.x-width/2 + (k-1)*SIZE,
                              5+mouseModes.menuPos.y-SIZE,
                              SIZE-10, SIZE-10)
   end
   print("")
end

function love.draw()
   love.graphics.scale(scale,scale)

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

   if mouseMode == mouseModes.gui then
      drawMenu()
   end

   audioDraw()

end
