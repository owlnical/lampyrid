local class = require "lib.middleclass"
local Planet = class("Planet")

function Planet:initialize(name, position)
	self.name = name
	self.position = position
end

function Planet:getPosition()
	return self.position
end

function Planet:getName()
	return self.name
end

return Planet
