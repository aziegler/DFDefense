local tower_types = {}

local enemy_types = {}

function Tower (t)
   table.insert(tower_types, t)
end

function Enemy (e)
   table.insert(enemy_types, e)
end

function dataLoad()
	dofile("assets/config.txt")
end

function new_tower()
   local tower_type = tower_types[math.random(1,#tower_types)]
   local tower = {}
   tower.width = math.random(10,30)
   tower.height = math.random(10,30)
   tower.enabled = false
   tower.color = {}
   tower.color.red = tower_type.color[1]
   tower.color.blue = tower_type.color[2]
   tower.color.green = tower_type.color[3]
   tower.range = tower_type.range
   tower.dps = tower_type.dps
   return tower
end


function new_enemy(roads)
   local enemy_type = enemy_types[math.random(1,#enemy_types)]
   local enemy = {}
   enemy.color = {}
   enemy.color.red = enemy_type.color[1]
   enemy.color.blue = enemy_type.color[2]
   enemy.color.green = enemy_type.color[3]
   enemy.speed = enemy_type.speed
   enemy.dps = enemy_type.dps
   enemy.range = enemy_type.range
   enemy.road_index = math.random(1,roads)
   enemy.x = 5
   enemy.y = 5
   enemy.life = enemy_type.life
   return enemy
end