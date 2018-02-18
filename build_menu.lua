local SIZE = 80
local border = 0

local pos = {
   { 175, 100 }, -- book
   { 240, 50 },  -- assos
   { 300, 75 }, -- garden
}

local menuFromX = 0
local menuFromY = 0

function pickMenu(x, y)
   local idx = 0

   x = x - menuFromX
   y = y - menuFromY

   for k,v in pairs(tower_types) do
      local r = ((pos[k][1]-x)*(pos[k][1]-x) + (pos[k][2]-y)*(pos[k][2]-y))^0.5
      if r < 50 then
         idx = k
      end
   end
   return idx
end

function drawMenu()

   menuFromX = mouseModes.menuPos.x-imgUI.Menu_BG:getWidth()
   menuFromY = mouseModes.menuPos.y-SIZE-20

   picked = pickMenu(mouseModes.mousePos[1],
                     mouseModes.mousePos[2])

   if picked > 0 then
      local pos_x = mouseModes.menuPos.x
      local pos_y = mouseModes.menuPos.y + mouseModes.building.height/2
      love.graphics.setColor(212,49,64,100)
      love.graphics.circle("fill", pos_x, pos_y, tower_types[picked].range, 100)
      love.graphics.setColor(255,255,255)
      love.graphics.setLineWidth(5)
      love.graphics.circle("line", pos_x, pos_y, tower_types[picked].range, 100)
      love.graphics.setLineWidth(1)
   end

   love.graphics.setColor(255,255,255)
   love.graphics.draw(imgUI.Menu_BG, menuFromX+imgUI.Menu_BG:getWidth()/2, menuFromY)

   for k,v in pairs(tower_types) do
      local scale = 1
      if picked == k then
         local txt = love.graphics.newText(fonts.small, v.tooltip)
         love.graphics.setColor(255,255,255,255)
         love.graphics.draw(txt, menuFromX+120, menuFromY+135);
         scale = 1.2
      end
      love.graphics.setColor(255,255,255,255)

      if v.icon then
         love.graphics.draw(v.icon,
                            menuFromX + pos[k][1] - scale * v.icon:getWidth()/2,
                            menuFromY + pos[k][2] - scale * v.icon:getHeight()/2,
                            0,
                            scale, scale)
      end
   end
end
