local version = 0.1

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

end

function love.draw()
	love.graphics.printf("Lampyrid v" .. version, 5, 5, 100)
end
