require "audio"
require "game_data"
require "build_menu"
require "particles"

local roads = {}
roads.count = 3
roads.list = {}

local enemyCoolDown = 0
local enemies = {}
enemies.list = {}

local hovered = nil

local towers = {}
towers.list = {}

local buildings = {}
buildings.list = {}

local enemy_gq = {}
enemy_gq.list = {}

local gameState = {
   title = true,
   gameOver = false,
   info = false,
   win = false
}

local partList = {}


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
   tower.anim_ttl = math.pi/4
   tower.anim_ref = tower.anim_ttl
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

      if idx > -1 and building.enabled then
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
            if not (tower == clickedtower) then
               tower.score = tower.score - infl
               clickedTower.score = clickedTower.score + infl
               table.insert(partList, { ttl = 0.5,
                                        from = {
                                           x = tower.x + tower.width/2,
                                           y = tower.y + tower.height/2  },
                                        to = {
                                           x = clickedTower.x + clickedTower.width/2,
                                           y = clickedTower.y + clickedTower.height/2}})
            end
         end
      else
      local _, clickedBuilding = getBuilding(x,y)
      if not(clickedBuilding == nil) then
         for _, tower in pairs(towers.list) do
            if tower.score >= 100 then
               local infl = math.min(tower.score * 0.1, 100 - clickedBuilding.score)
               tower.score = tower.score - infl
               clickedBuilding.score = clickedBuilding.score + infl
               table.insert(partList, { ttl = 0.5,
                                        from = {
                                           x = tower.x + tower.width/2,
                                           y = tower.y + tower.height/2  },
                                        to = {
                                           x = clickedBuilding.x + clickedBuilding.width/2,
                                           y = clickedBuilding.y + clickedBuilding.height/2}})

            end
         end
         for _, building in pairs(buildings.list) do
            if building.score >= 100 then
               local infl = math.max(math.min(building.score * 0.1, 100 - clickedBuilding.score),0)
               if not (building == clickedBuilding) then
                  building.score = building.score - infl
                  clickedBuilding.score = clickedBuilding.score + infl
                  table.insert(partList, { ttl = 0.5,
                                           from = {
                                              x = building.x + building.width/2,
                                              y = building.y + building.height/2 },
                                           to = {
                                              x = clickedBuilding.x + clickedBuilding.width/2,
                                              y = clickedBuilding.y + clickedBuilding.height/2}})
               end
            end
         end

      end
      end
   end
end

function love.mousepressed(x,y,button,istouch)
   if gameState.title then
      local x_mouse = mouseModes.mousePos[1]
      local y_mouse = mouseModes.mousePos[2]
      if gameState.info then
         gameState.info = false
         gameState.title = false
         audioStart()
      else
         if 300 < x_mouse and 900 > x_mouse and 400 < y_mouse and 1000 > y_mouse then
            gameState.title = false
            audioStart()
         elseif 800 < x_mouse and 1500 > x_mouse and 400 < y_mouse and 1000 > y_mouse then
            gameState.info = true
         end
      end
   else
      if mouseMode == mouseModes.pick then
         mousePick(x,y,button,istouch)
      else
         mouseGui(x,y,button,istouch)
      end
   end
end

function getBuilding(x,y)
   if x == nil or y == nil then
      return -1,nil
   end
   for idx,building in pairs(buildings.list) do

      local X = building.x + building.width/2 - imgBuildings.Neutre:getWidth()/2
      local Y = building.y + building.height - imgBuildings.Neutre:getHeight()
      local W = imgBuildings.Neutre:getWidth()
      local H = imgBuildings.Neutre:getHeight()

      if x >= X and x <= X + W and y >= Y and y <= Y + H then
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

function init()
   roads = {}
   roads.count = 3
   roads.list = {}

   enemyCoolDown = 0
   enemies = {}
   enemies.list = {}

   hovered = nil

   towers = {}
   towers.list = {}

   buildings = {}
   buildings.list = {}

   enemy_gq = {}
   enemy_gq.list = {}

   gameState.gameOver = false
   gameState.win = false
   partList = {}
   gameState.title = true
end

function love.load(arg)
   math.randomseed(os.time())

   fonts = {
      title_large = love.graphics.newFont("assets/i8080.ttf",90),
      title_small = love.graphics.newFont("assets/steelfish rg.ttf",35),
      title_x_small = love.graphics.newFont("assets/steelfish rg.ttf",22),
      large = love.graphics.newFont("assets/arial.ttf",20),
      small = love.graphics.newFont("assets/arial.ttf",16)
   }
   love.graphics.setFont(fonts.large)

   partLoad()
   dataLoad(roads, buildings, towers, enemy_gq)

   audioLoad(audioConfig)

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
      BigJauge = love.graphics.newImage("assets/UI/big_jauge.png"),
      Rouge = love.graphics.newImage("assets/UI/Barre_rouge.png"),
      BigRouge = love.graphics.newImage("assets/UI/Barre_rouge_large.png"),
      Bleu = love.graphics.newImage("assets/UI/Barre_bleue.png"),
      BigBleu = love.graphics.newImage("assets/UI/Barre_bleue_large.png"),
      Hover_up = love.graphics.newImage("assets/UI/haut_texte.png"),
      Hover_down = love.graphics.newImage("assets/UI/bas_texte.png"),
      Hover_middle = love.graphics.newImage("assets/UI/milieu_texte.png"),
      Logo = love.graphics.newImage("assets/UI/Logogentryfight.png"),
      Button_play = love.graphics.newImage("assets/UI/btn_Jouer.png"),
      Button_info = love.graphics.newImage("assets/UI/btn_Info.png"),
      Menu_BG = love.graphics.newImage("assets/UI/SupportIcon.png"),
      Avis_Demolition = love.graphics.newImage("assets/avisDeDEmolition.png"),
      Victoire = love.graphics.newImage("assets/UI/victoire.png")
   }

   enemy_gq.list[2].img = imgEnemyGQ.Police
   enemy_gq.list[1].img = imgEnemyGQ.Defense
   enemy_gq.list[1].hasGauge = false
   enemy_gq.list[2].hasGauge = false

   love.window.setMode(0, 0)
   local screen_width = love.graphics.getWidth()
   local screen_height = love.graphics.getHeight()
   local diff = math.abs((screen_width/screen_height)-(1920/1080))
   if screen_width ~= 1920 or screen_height ~= 1080 then
      if diff < 0.001 then
	 scale = screen_width/1920
	 love.window.setFullscreen(true)
      else
	 scale = 0.5
	 love.window.setMode(1920*scale,1080*scale)
      end
   else
      scale = 1
      love.window.setFullscreen(true)
   end

   persoLoad(1920*scale, 1080*scale, roads)

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
               if tower.isBase then
                  gameState.gameOver = true
                  tower.score = 0
               else
                  table.remove(towers.list,tw_idx)
                  tower.building.tower = nil
                  tower.building.score = tower.score
                  break
               end
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
      building1.enabled = false
      for tw_idx,tower in pairs(towers.list) do
         local width, height = tower.x-(building1.x+building1.width/2), tower.y-(building1.y+building1.height/2)
         local distance = (width*width + height*height)^0.5
         if building1.score < -100 and distance < enemyBuilding.range then
            tower.score = tower.score - enemyBuilding.dps * dt
            if tower.score < 0 then
               if tower.isBase then
                  gameState.gameOver = true
                  tower.score = 0
               else
                  table.remove(towers.list,tw_idx)
                  tower.building.tower = nil
                  tower.building.score = tower.score
                  break
               end
            end
         end
         if building1.score > gameplayVariable.buildingTreshold and
         (building1.tower == nil or  not building1.tower.isBase ) then
            building1.enabled = true
         end
      end
   end
end

function love.keypressed(key)
   if key == "escape" then
      love.event.quit()
   end
   if key == "space" and (gameState.gameOver or gameState.win) then
      gameState.gameOver = false
      gameState.win = false
      init()
      love.load()
   end
end

function love.update (dt)
   voiceOn, tbs = audioUpdate(gameState.title == false and gameState.info == false)
   if not gameState.gameOver and not gameState.title and not gameState.win then


      if tbs == -1 then
         gameState.win = true
      end

      compute_damage(dt)

      local baseTower = {}
      for _,tower in pairs(towers.list) do
         tower.score = tower.score + tower.influence_rate * dt
         if tower.anim_ttl and tower.anim_ttl > 0 then
            tower.anim_ttl = tower.anim_ttl - dt
         else
            tower.anim_ttl = 0
         end
         if tower.isBase then
            baseTower = tower
         end
      end

      for _,p in pairs(persos) do
         p.time = p.time + dt
      end

      for idx,enemy in pairs(enemies.list) do
         enemy.time = enemy.time + dt
         enemy.roadStep = (enemy.roadStep + (enemy.speed * dt))
         if enemy.roadStep > roads.list[enemy.road_index].lastPoint then
            --table.remove(enemies.list,idx)
         end
         if not (roads.list[enemy.road_index].points[math.floor(enemy.roadStep)] == nil) then
            enemy.y = roads.list[enemy.road_index].points[math.floor(enemy.roadStep)].y
            enemy.x = roads.list[enemy.road_index].points[math.floor(enemy.roadStep)].x
         end
          if enemy.roadStep > roads.list[enemy.road_index].lastPoint then
            baseTower.score = baseTower.score - enemy.life
            if baseTower.score < 0 then
               gameState.gameOver = true
               baseTower.score = 0
            end
            table.remove(enemies.list,idx)
         end
      end


      partUpdate(dt, partList)
      voiceOn, tbs = audioUpdate()


      enemyCoolDown = enemyCoolDown + dt
      if tbs and enemyCoolDown > tbs then --math.random(0,100) > 99 and voiceOn then
         table.insert(enemies.list, new_enemy(roads.count))
         enemyCoolDown = 0
      end

   end

   mouseModes.mousePos = { love.mouse.getX()/scale, love.mouse.getY()/scale }

   local idx, tower = getTower(mouseModes.mousePos[1], mouseModes.mousePos[2])
   local b_idx, building = getBuilding(mouseModes.mousePos[1], mouseModes.mousePos[2])
   hovered = nil
   if idx > -1 then
      hovered = tower
   elseif b_idx > -1 then
      if building.score >= gameplayVariable.buildingTreshold then
         building.name = gameplayVariable.friendlyName
      elseif building.score >= -100 then
         building.name = gameplayVariable.neutralName
      else
         building.name = enemyBuilding.name
      end
      hovered = building
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
      local speed = enemy.anim_speed
      local idx = 1 + math.floor(#enemy.img * (enemy.time % speed)/speed)
      local img = enemy.img[idx]
      love.graphics.setColor(255, 255, 255, 255)

      if not (enemy.life and enemy.life < 20 and (enemy.time % speed)/speed < 0.5) then
         love.graphics.draw(img,
                         enemy.x-img:getWidth()/2,
                         enemy.y-img:getHeight())
      end
   else
      love.graphics.setColor(enemy.color.red, enemy.color.green, enemy.color.blue)
      love.graphics.rectangle("fill",enemy.x - 20,enemy.y - 20,40,40)
   end
end

function drawGauge(influenceRatio,x,y,small)
   if small then
      love.graphics.draw(imgUI.Rouge,x + 17,y - imgUI.Jauge:getHeight() -5, 0, 72 * influenceRatio / imgUI.Rouge:getWidth(), 1)
      love.graphics.draw(imgUI.Bleu,
                         x + 17 + (72 * influenceRatio),
                         y - imgUI.Jauge:getHeight() -5, 0,
                         72 * (1 - influenceRatio) / imgUI.Bleu:getWidth(), 1)
      love.graphics.draw(imgUI.Jauge,x + 15,y - imgUI.Jauge:getHeight() - 10,0)
   else
      love.graphics.draw(imgUI.BigRouge,x + 34,y - imgUI.BigJauge:getHeight() - 5, 0, 144 * influenceRatio / imgUI.BigRouge:getWidth(), 1)
      love.graphics.draw(imgUI.BigBleu,
                         x + 34 + (144 * influenceRatio),
                         y - imgUI.BigJauge:getHeight() -5, 0,
                         144 * (1 - influenceRatio) / imgUI.BigBleu:getWidth(), 1)
      love.graphics.draw(imgUI.BigJauge,x + 30,y - imgUI.BigJauge:getHeight() - 10,0)

   end
end

function draw_tower(tower)
   local h = tower.y
   local x = tower.x
   if tower.img then
      love.graphics.setColor(255, 255, 255)

      local img_scale = 1
      if tower.anim_ttl and tower.anim_ttl > 0 then
         local t = 1+tower.anim_ref-tower.anim_ttl
         img_scale = 1+ (math.cos(math.pi+(t)*math.pi*6)/(t^3))/2
      end

      h  = tower.y - tower.img:getHeight()*img_scale + tower.height
      if tower.center == true then
         h = tower.y - img_scale*tower.img:getHeight()/2 + tower.height/2
      end
      x = tower.x - img_scale*tower.img:getWidth()/2 + tower.width/2

      love.graphics.draw(tower.img, x , h, 0, img_scale, img_scale)

   else
      love.graphics.setColor(tower.color.red,tower.color.green,tower.color.blue)
      love.graphics.rectangle("fill", tower.x, tower.y, tower.width, tower.height)
   end
   local influenceRatio = math.max(0,math.min((tower.score + 200) / 400,1))

   if tower.hasGauge then
      drawGauge(influenceRatio, x, h, true)
   elseif tower.isBase then
      influenceRatio = math.max(0,math.min(tower.score / 1000,1))
      drawGauge(influenceRatio, x + tower.img:getWidth()/2 - 144 ,h +10, false)
   end
end

function drawBuildings(img, building)

   love.graphics.draw(img,
                      building.x+building.width/2-img:getWidth()/2,
                      building.y+building.height-img:getHeight())
    local influenceRatio = math.max(0,math.min((building.score + 200) / 400,1))
    if building.hasGauge then
      drawGauge(influenceRatio, building.x+building.width/2-img:getWidth()/2, building.y+building.height-img:getHeight(), true)
    end
end

function drawBuildingsMiddle(img, building)
   love.graphics.draw(img,
                      building.x+building.width/2-img:getWidth()/2,
                      building.y+building.height/2-img:getHeight()/2)
end

function drawHover(title,text,x,y)
   local width = 450
   local height = 300
   if not text then
      width = 200
      height = 100
   end
   love.graphics.setColor(255,255,255,255)
   love.graphics.draw(imgUI.Hover_up,x,y,0,width/imgUI.Hover_up:getWidth(),1)
   love.graphics.draw(imgUI.Hover_down,x,y + height - imgUI.Hover_down:getHeight(),0,width/imgUI.Hover_down:getWidth(),1)
   love.graphics.draw(imgUI.Hover_middle,x,y + imgUI.Hover_up:getHeight(),0,width/imgUI.Hover_middle:getWidth(),(height - imgUI.Hover_up:getHeight() - imgUI.Hover_down:getHeight()) / imgUI.Hover_middle:getHeight())
   love.graphics.setColor(255,255,255,255)
   love.graphics.setFont(fonts.large)
   love.graphics.printf(title,x + 10,y + 5,width - 20,"center")
   if text then
      love.graphics.setFont(fonts.small)
      love.graphics.printf(text,x + 10,y + 75,width - 20,"center")
   end

end

function sortY(obj1, obj2)
   return obj1.y < obj2.y
end

function love.draw()
   love.graphics.scale(scale,scale)

   love.graphics.setColor(255,255,255)

   if gameState.title then
      love.graphics.setColor(130, 130, 130, 150)
      love.graphics.draw(title_bg,0,0)
      local width = love.graphics.getWidth() / scale
      local height = love.graphics.getHeight() /scale
      love.graphics.rectangle("fill", 20, 50, width - 40,  height - 100)

      if not gameState.info then
         love.graphics.setColor(255, 255, 255, 255)
         love.graphics.draw(imgUI.Logo,40, 300)
         love.graphics.draw(imgUI.Button_play,400,700)
         love.graphics.draw(imgUI.Button_info,width - 800,700)
      else
         love.graphics.setFont(fonts.title_small)
         love.graphics.setColor(255, 255, 255, 255)
         love.graphics.printf(gameplayVariable.text, 80, 80, 3 * width / 5)
         love.graphics.draw(imgUI.Button_play,
			    width - imgUI.Button_play:getWidth() - 40,
			    height - imgUI.Button_play:getHeight() - 60)
      end

      return
   end

   love.graphics.draw(map,0,0)

   local drawList = {}

   if not gameState.gameOver then
      for _,enemy in pairs(enemies.list) do
         enemy.enemy = true
         table.insert(drawList, enemy)
      end
      for _,p in pairs(persos) do
         p.enemy = true
         table.insert(drawList, p)
      end
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
            love.graphics.setColor(255,255,255,255)
            drawBuildings(imgBuildings.Drouate, building)
         end
         --love.graphics.rectangle("fill",building.x,building.y,building.width,building.height)
         love.graphics.setColor(50,50,50,255)

      else
         draw_tower(building.tower)
      end
   end

   if gameState.gameOver then
      love.graphics.setColor(255, 255, 255, 200)
      local width = love.graphics.getWidth()
      local height = love.graphics.getHeight()
      love.graphics.rectangle("fill", 20, 50, width - 40,  height - 100)
      love.graphics.setColor(255, 255, 255, 255)
      love.graphics.draw(imgUI.Avis_Demolition,30,60)
      love.graphics.setColor(0, 0, 0, 255)
      love.graphics.setFont(fonts.title_small)
      love.graphics.printf("Espace pour réessayer", love.graphics.getWidth()/2 - 200,love.graphics.getHeight() - 150,500)
      love.graphics.printf(gameplayVariable.textCredits,love.graphics.getWidth()/2 + 200, 300, 700)
   end

   if gameState.win then
      love.graphics.setColor(255, 255, 255, 200)
      local width = love.graphics.getWidth()
      local height = love.graphics.getHeight()
      love.graphics.rectangle("fill", 20, 50, width - 40,  height - 100)
      love.graphics.setColor(255, 255, 255, 255)
      love.graphics.draw(imgUI.Victoire,100,200,0,2,2)
      love.graphics.setColor(0, 0, 0, 255)
      love.graphics.setFont(fonts.title_small)
      love.graphics.printf("Espace pour réessayer", love.graphics.getWidth()/2 - 200,love.graphics.getHeight() - 150,500)
      love.graphics.printf(gameplayVariable.textCredits,love.graphics.getWidth()/2 + 200, 300, 700)
   end

   --love.graphics.setColor(255,255,255,255)
   --drawBuildingsMiddle(imgEnemyGQ.Police, enemy_gq.list[2]);
   --drawBuildings(imgEnemyGQ.Defense, enemy_gq.list[1]);


   if mouseMode == mouseModes.gui then
      drawMenu()
   elseif not (hovered == nil) then
      local x = hovered.x+hovered.width
      local y = hovered.y-hovered.height/2
      if hovered.isBase then
         x = hovered.x - hovered.width/2
         y = hovered.y + hovered.height
      end
      drawHover(hovered.name.."\n"..math.floor(hovered.score),hovered.text,x,y)
   end

   partDraw(partList)
   love.graphics.setColor(255,255,255)

end
