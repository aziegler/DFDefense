local SIZE = 128+10
local border = 5

function get_menu_bbox(width, k)
      x = border+mouseModes.menuPos.x-width/2 + (k-1)*SIZE
      y = border+mouseModes.menuPos.y-SIZE
      w = SIZE-border*2
      h = SIZE-border*2

      return { x, y, w, h }
end

function get_menu_width()
   return #tower_types * SIZE
end

function pickMenu(x, y)
   local idx = 0
   local width = get_menu_width()

   for k,v in pairs(tower_types) do
      local bbox = get_menu_bbox(width, k)
      if x >= bbox[1] and x <= bbox[1] + bbox[3] then
         if y >= bbox[2] and y <= bbox[2] + bbox[4] then
            idx = k
         end
      end
   end
   return idx
end

function drawMenu()

   local width = get_menu_width()

   picked = pickMenu(mouseModes.mousePos[1], mouseModes.mousePos[2])

   local fromX = mouseModes.menuPos.x-width/2
   local fromY = mouseModes.menuPos.y-SIZE-20
   love.graphics.setColor(255,255,255)
   love.graphics.rectangle("fill",
                           fromX,fromY,
                           width, SIZE+20)
   for k,v in pairs(tower_types) do
      local bbox = get_menu_bbox(width, k)
      if picked == k then
         local txt = love.graphics.newText(arialFont, v.tooltip)
         love.graphics.setColor(0,0,0,255)
         love.graphics.draw(txt, fromX+2, fromY+2);
         love.graphics.setColor(255,255,255,155)
      else
         love.graphics.setColor(255,255,255,255)
      end

      if v.icon then
         love.graphics.draw(v.icon,bbox[1],bbox[2])
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
