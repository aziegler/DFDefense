function partLoad()
   partImgs = {
      love.graphics.newImage("assets/Prtcl_ampoule.png"),
      love.graphics.newImage("assets/Prtcl_attack_allie.png"),
      love.graphics.newImage("assets/Prtcl_attack_note.png")
   }
end

function partUpdate(dt, partList)
   for i,p in pairs(partList) do
      if not p.t then
         p.t = 0.0001
         p.ttl = math.random(0.25,0.5)
         p.to.x = p.to.x + math.random(-20,20)
         p.to.y = p.to.y + math.random(-20,20)
         p.from.x = p.from.x + math.random(-20,20)
         p.from.y = p.from.y + math.random(-20,20)
         p.img = partImgs[math.random(1,#partImgs)]
      end
      p.t = p.t + dt
      if p.t >= p.ttl then
         table.remove(partList,i)
      end
   end
end

function partDraw(partList)
   for i,p in pairs(partList) do
      if p.t then
         local t = p.t/p.ttl
         local x = p.from.x + (p.to.x-p.from.x) * t
         local y = p.from.y + (p.to.y-p.from.y) * t

         love.graphics.setColor(255, 255, 255)
         love.graphics.draw(p.img, x-p.img:getWidth()/2, y-p.img:getHeight()/2)
      end
   end
end
