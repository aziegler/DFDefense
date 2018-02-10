
local layerData

local roads = {}
roads.count = 3
roads.list = {}

local ennemies = {}
ennemies.list = {}
ennemies.speed = 10

local towers = {}
towers.list = {}
towers.current_tower = {}

local buildings = {}
buildings.list = {}

function new_tower()
	local tower = {}
	tower.width = math.random(10,30)
	tower.height = math.random(10,30)
	tower.enabled = false
	tower.color = {}
	tower.color.red = math.random(0,255)
	tower.color.blue = math.random(0,255)
	tower.color.green = math.random(0,255)
	tower.range = math.random(300,600)
	tower.dps = 3
	towers.current_tower = tower
end

function new_ennemy() 
	local ennemy = {}
	ennemy.color = {}
	ennemy.color.red = math.random(0,255)
	ennemy.color.blue = math.random(0,255)
	ennemy.color.green = math.random(0,255)
	ennemy.road_index = math.random(1,#roads.list)
	ennemy.x = 5
	ennemy.y = 5
	ennemy.life = math.random(0,30)
	table.insert(ennemies.list, ennemy)
end

function love.mousepressed(x,y,button,istouch)
	if not (towers.current_tower.enabled) then
		return
	end
	table.insert(towers.list,towers.current_tower)
	new_tower()
end

function love.load()
	love.window.setFullscreen(true)
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
        	elseif r == 255 and g == 0 and b == 0 then
        		table.insert(buildings.list,{x,y})
        	end
    	end
	end
	for i,road in pairs(roads.list) do
		if(#road < 20) then
			table.remove(roads.list,i)
		end
	end
	new_ennemy()
	new_tower()
end

function compute_damage(dt)
	for en_idx,ennemy in pairs(ennemies.list) do
		for _,tower in pairs(towers.list) do
			local width, height = ennemy.x-tower.x, ennemy.y-tower.y
    		local distance = (width*width + height*height)^0.5
    		if distance  < tower.range then
    			ennemy.life = ennemy.life - tower.dps * dt
    			if ennemy.life < 0 then
    				table.remove(ennemies.list,en_idx)
    			end
    		end
		end
	end
end

function love.update (dt)
	for _,ennemy in pairs(ennemies.list) do
		ennemy.x = (ennemy.x + (ennemies.speed * dt))
		if not (roads.list[ennemy.road_index][math.floor(ennemy.x)] == nil) then
			ennemy.y = roads.list[ennemy.road_index][math.floor(ennemy.x)]
		end
	end

	compute_damage(dt)

	if math.random(0,100) > 99 then
		new_ennemy()
	end


	towers.current_tower.x = love.mouse.getX()
	towers.current_tower.y = love.mouse.getY()

	towers.current_tower.enabled = false

	local r,g,b,a = layerData:getPixel(towers.current_tower.x,towers.current_tower.y)
	if r == 255 and g == 0 and b == 0 then
		towers.current_tower.enabled = true		
		for _,tower in pairs(towers.list) do
			if collide(tower,towers.current_tower) then
				towers.current_tower.enabled = false
			end						
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

function draw_ennemy(ennemy)
		love.graphics.setColor(ennemy.color.red, ennemy.color.green, ennemy.color.blue)
		love.graphics.rectangle("fill",ennemy.x - 10,ennemy.y - 10,20,20)
		love.graphics.setColor(0,0,0)
		love.graphics.print(math.floor(ennemy.life),ennemy.x - 7 ,ennemy.y - 5,0)
end

function draw_tower(tower)
		if tower.enabled then
			love.graphics.setColor(tower.color.red,tower.color.green,tower.color.blue)
		else
			love.graphics.setColor(tower.color.red,tower.color.green,tower.color.blue,100)
		end
		love.graphics.rectangle("fill",tower.x - (tower.width / 2),tower.y - (tower.height / 2),tower.width,tower.height)
		love.graphics.setColor(tower.color.red,tower.color.green,tower.color.blue,50)
		love.graphics.circle("fill", tower.x, tower.y, tower.range)
		
end

function love.draw()
	for i = 1, #roads.list do
		love.graphics.setColor(100,100,100)
		for j = 1, #roads.list[i] do
			love.graphics.points(j,roads.list[i][j])
		end
	end
	love.graphics.setColor(200, 100, 100, 30)
	for _,building in pairs(buildings.list) do
		love.graphics.points(building[1],building[2])
	end
	for _,ennemy in pairs(ennemies.list) do
		draw_ennemy(ennemy)
	end
	for _,tower in pairs(towers.list) do
		draw_tower(tower)
	end
	draw_tower(towers.current_tower)
end