local version = 0.1
local cpml = require("lib/cpml")
require("util")

function love.load()
	position = cpml.vec3.new(0, 0, 0)
	destination = cpml.vec3.new(0, 0, 0)
	distance = 0
	travel_time = 0
	speed = 10
	traveling = true
	eta = 0
end

function love.draw()
	-- status
	love.graphics.printf("Lampyrid v" .. version, 5, 10, 100)
	love.graphics.printf("Position: " ..  position:to_string(), 5, 25, 600)
	love.graphics.printf("Destination: " ..  destination:to_string() , 5, 40, 600)
	love.graphics.printf("Distance: " ..  distance, 5, 55, 600)
	love.graphics.printf("ETA: " .. eta, 5, 70, 600)
end

function love.update(dt)
	if traveling then travel(dt) end
end

-- Move forward by calculating lerp step from distance, speed and time
function travel(dt)
	distance = position:dist(destination)
	step = (distance / (distance - (dt * speed))) - 1
	if step < 1 then
		position = cpml.vec3.lerp(position, destination, step)
		travel_time = travel_time + dt
		eta = cpml.utils.round(distance / speed / 60)
	else
		print("Arrived after: " .. cpml.utils.round(travel_time / 60).. " minutes", step)
		traveling = false
		travel_time = 0
		distance = 0
		eta = 0
		position = destination:clone()
	end
end
