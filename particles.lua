
function partUpdate(dt, partList)
   for i,p in pairs(partList) do
      if not p.t then
         p.t = 0
         p.ttl = math.random(0.25,0.5)
      end
      p.t = p.t + dt
      if p.t >= p.ttl then
         table.remove(partList,i)
      end
   end
end

function partDraw(partList)
   for i,p in pairs(partList) do
      local t = p.t/p.ttl
      local x = p.from.x + (p.to.x-p.from.x) * t
      local y = p.from.y + (p.to.y-p.from.y) * t

      love.graphics.setColor(255, 255, 0)
      love.graphics.circle("fill", x, y, 10)

   end
end
