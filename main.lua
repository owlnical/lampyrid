local version = 0.1
local cpml = require("lib/cpml")
require("util")

function love.load()
	position = cpml.vec3.new(0, 0, 0)
	destination = cpml.vec3.new(10, 10, 10)
	distance = 0
end

function love.draw()
	love.graphics.printf("Lampyrid v" .. version, 5, 10, 100)
	love.graphics.printf("Position: " ..  cpml.vec3.to_string(position) , 5, 25, 300)
	love.graphics.printf("destination: " ..  cpml.vec3.to_string(destination) , 5, 40, 300)
	love.graphics.printf("Distance: " ..  distance, 5, 55, 300)
end

function love.update()
	distance = cpml.vec3.dist(position, destination)
end
