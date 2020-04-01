local class = require "lib/middleclass"
local Image = require("class/image")
local Planet = class("Planet", Image)

function Planet:initialize(image)
	Image.initialize(self, 50, 50)
	self.image = image
	self.r = 0
	self.s = 1
end

function Planet:rotate(r)
	self.r = self.r + r
end

function Planet:draw()
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(self.image, self.x, self.y, self.r, self.s, self.s)
	Planet:drawOverlay(0.3)
end

return Planet
