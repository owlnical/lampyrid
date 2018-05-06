local version = 0.1

function love.load()

end

function love.draw()
	love.graphics.printf("Lampyrid v" .. version, 5, 5, 100)
end
