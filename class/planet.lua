local class = require "lib.middleclass"
local Planet = class("Planet")

function Planet:initialize(seed, name)
	self.seed = seed
	self.rng = love.math.newRandomGenerator(seed)

	-- random name. Might have prefix and suffix.
	local p = name.prefix[self:random(1, #name.prefix*3)] or ""
	local m = name.main[self:random(1, #name.main)]
	local s = name.suffix[self:random(1, #name.suffix*3)] or ""
	self.name = string.format("%s %s %s", p, m, s):gsub("^%s",""):gsub("%s$","")
end

function Planet:getPosition()
	return self.position
end

function Planet:getName()
	return self.name
end

function Planet:random(l, h)
	if l and h then
		return self.rng:random(l*100, h*100)/100
	else
		return self.rng:random()
	end
end


return Planet
