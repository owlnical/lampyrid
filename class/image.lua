local class = require "lib/middleclass"
local Image = class("Image")

function Image:initialize(x, y, w, h)
  self.x = x
  self.y = y
  self.w = w or love.graphics.getWidth()
  self.h = h or love.graphics.getHeight()
end

function Image:drawOverlay(alpha)
  love.graphics.setColor(0.1, 0.1, 0.1, alpha)
  love.graphics.rectangle("fill", 0, 0, love.graphics.getDimensions())
end

return Image