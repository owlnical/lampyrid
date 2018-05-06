local version = 0.1
require("util")

local navigation = {
	position = {
		x = 0,
		y = 0,
		z = 0
	},
	destination = {
		x = 0,
		y = 0,
		z = 0,
		distance = 0
	}
}

function love.load()
	navigation.destination = {
		x = 10,
		y = 10,
		z = 10
	}
end

function love.draw()
	love.graphics.printf("Lampyrid v" .. version, 5, 5, 100)
	love.graphics.printf("Distance: " .. navigation.destination.distance, 5, 20, 100)
end

function love.update()
	navigation.destination.distance = math.dist(navigation.position.x, navigation.position.y, navigation.position.z, navigation.destination.x, navigation.destination.y, navigation.destination.z)
	navigation.destination.distance = math.round(navigation.destination.distance)
end
