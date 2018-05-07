local version = 0.1
require("util")

position = {
	x = 0,
	y = 0,
	z = 0
}

destination = {
	x = 0,
	y = 0,
	z = 0,
	distance = 0
}

function love.load()
	destination = {
		x = 10,
		y = 10,
		z = 10
	}
end

function love.draw()
	love.graphics.printf("Lampyrid v" .. version, 5, 5, 100)
	love.graphics.printf("Distance: " .. destination.distance, 5, 20, 100)
end

function love.update()
	destination.distance = math.dist(position.x, position.y, position.z, destination.x, destination.y, destination.z)
	destination.distance = math.round(destination.distance)
end
