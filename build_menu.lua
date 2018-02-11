local SIZE = 80
local border = 0

local pos = {
   { 175, 100 }, -- book
   { 240, 50 },  -- assos
   { 300, 75 }, -- garden
}

function get_menu_bbox(width, k, scale)
      x = border+mouseModes.menuPos.x-width/2 + (k-1)*SIZE
      y = border+mouseModes.menuPos.y-SIZE
      w = SIZE-border*2
      h = SIZE-border*2

      return { x, y, w, h }
end

function get_menu_width()
   return #tower_types * SIZE
end

local menuFromX = 0
local menuFromY = 0

function pickMenu(x, y)
   local idx = 0
   local width = get_menu_width()

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

   local width = get_menu_width()

   menuFromX = mouseModes.menuPos.x-imgUI.Menu_BG:getWidth()
   menuFromY = mouseModes.menuPos.y-SIZE-20

   picked = pickMenu(mouseModes.mousePos[1],
                     mouseModes.mousePos[2])



   love.graphics.setColor(255,255,255)
   love.graphics.draw(imgUI.Menu_BG, menuFromX+imgUI.Menu_BG:getWidth()/2, menuFromY)
   --love.graphics.rectangle("fill",
     --                      menuFromX,menuFromY,
   --                    width, SIZE+20)

   for k,v in pairs(tower_types) do
      local scale = 1
      if picked == k then
         local txt = love.graphics.newText(fonts.small, v.tooltip)
         love.graphics.setColor(255,255,255,255)
         love.graphics.draw(txt, menuFromX+120, menuFromY+135);
         scale = 1.2
      end
      love.graphics.setColor(255,255,255,255)

      local bbox = get_menu_bbox(width, k, scale)
      if v.icon then
         love.graphics.draw(v.icon,
                            menuFromX + pos[k][1] - scale * v.icon:getWidth()/2,
                            menuFromY + pos[k][2] - scale * v.icon:getHeight()/2,
                            0,
                            scale, scale)
      else
         if picked == k then
            love.graphics.setColor(v.color[1]/2, v.color[2]/2, v.color[3]/2)
         else
            love.graphics.setColor(v.color[1], v.color[2], v.color[3])
         end
         love.graphics.rectangle("fill", bbox[1], bbox[2], bbox[3], bbox[4])
      end
   end
end
