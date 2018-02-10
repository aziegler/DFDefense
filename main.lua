
local layerData

local roads = {}
roads.count = 4
roads.list = {}

local ennemies = {}
ennemies.list = {}
ennemies.speed = 10

function new_ennemy() 
	local ennemy = {}
	ennemy.color = {}
	ennemy.color.red = math.random(0,255)
	ennemy.color.blue = math.random(0,255)
	ennemy.color.green = math.random(0,255)
	ennemy.road_index = math.random(1,#roads.list)
	ennemy.x = 5
	ennemy.y = 5
	table.insert(ennemies.list, ennemy)
end

function love.load()
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
        	end
    	end
	end
	for i,road in pairs(roads.list) do
		if(#road < 20) then
			table.remove(roads.list,i)
		end
	end
	new_ennemy()
end

function love.update (dt)
	for _,ennemy in pairs(ennemies.list) do
		ennemy.x = (ennemy.x + (ennemies.speed * dt))
		if not (roads.list[ennemy.road_index][math.floor(ennemy.x)] == nil) then
			ennemy.y = roads.list[ennemy.road_index][math.floor(ennemy.x)]
		end
	end
	if math.random(0,100) > 99 then
		new_ennemy()
	end
end

function love.draw()
	for i = 1, #roads.list do
		love.graphics.setColor(100,100,100)
		for j = 1, #roads.list[i] do
			love.graphics.points(j,roads.list[i][j])
		end
	end
	for _,ennemy in pairs(ennemies.list) do
		love.graphics.setColor(ennemy.color.red, ennemy.color.green, ennemy.color.blue)
		love.graphics.rectangle("fill",ennemy.x,ennemy.y,10,10)
	end
end