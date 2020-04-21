local class = require "lib.middleclass"
local Planet = class("Planet")
local lsw = require "lib.LuaSVGWriter"

function Planet:initialize(seed, name)
	self.seed = seed
	self.rng = love.math.newRandomGenerator(seed)

	-- random name. Might have prefix and suffix.
	local p = name.prefix[self:random(1, #name.prefix*3)] or ""
	local m = name.main[self:random(1, #name.main)]
	local s = name.suffix[self:random(1, #name.suffix*3)] or ""
	self.name = string.format("%s %s %s", p, m, s):gsub("^%s",""):gsub("%s$","")
end

function Planet:genSVG()
	--self.doc()
	local hue_base = self:random(0.01, 0.85)
	local conf = {
		size = 300,
		canvas = 500,
		r = 150,
		x = 250,
		y = 250,
		color = {
			hue= {
				hue_base,
				hue_base + self:random(0.05, 0.15)
			},
			sat = {
				0.1,
				1
			},
			light = {
				0.25,
				0.6
			}
		},
	}

	local svg = lsw.Document:new(conf.canvas, conf.canvas)

	-- background
	local style = lsw.Style:new()
	style:setFill(self:genColor(conf.color), 1)
	svg:addCircle(conf.x, conf.y, conf.r):setStyle(style)

	-- Texture
	style:setOpacity(0.5)
	for i=1, 1000 do
		style:setFill(self:genColor(conf.color))
		local x1, y1, x2, y2, x3, y3 = self:genTriangle(conf.x, conf.y, conf.r)
		svg:addPolygon():add(x1, y1):add(x2, y2):add(x3, y3):setStyle(style)
	end
	--]]

	-- Stripes
	if self:random() > 0.8 then
		style:setFill("black")
		for i=1, self:random(3, 13) do
			style:setOpacity(self:random(0.4, 0.6))
			local x1, y1, x2, y2, x3, y3, x4, y4 = self:genStripe(conf.r, conf.canvas)
			svg:addPolygon():add(x1, y1):add(x2, y2):add(x3, y3):add(x4, y4):setStyle(style)
		end
	end
	--]]

	-- Gradient
	style:setFill(lsw.LinearGradient:new("black"))
	style:setOpacity(self:random(0.9, 1))
	svg:addCircle(conf.x, conf.y, conf.r):setStyle(style)
	--]]

	-- Black border overlay
	local mask = [[
	<path
    d="M 0 0 L 0 500 L 500 500 L 500 0 L 0 0 z M 250.5 100.5 A 150 150 0 0 1 400.5 250.5 A 150 150 0 0 1 250.5 400.5 A 150 150 0 0 1 100.5 250.5 A 150 150 0 0 1 250.5 100.5 z "
    style="fill:#000000;stroke:none;stroke-width:14.0131"
    id="rect2854" />
	</svg>
	]]
	self.svg = svg:createText()
	self.svg = self.svg:gsub("</svg>", mask)

	-- We're done here
	love.filesystem.write(self.seed .. ".svg", self.svg)
end

function Planet:genColor(hsl)
	hl, hh = unpack(hsl.hue)
	sl, sh = unpack(hsl.sat)
	ll, lh = unpack(hsl.light)
	return lsw.Color.HSL(
		self:random(hl, hh),
		self:random(sl, sh),
		self:random(ll, lh)
	)
end

function Planet:genPoint(cx, cy, r)
	local r = r * math.sqrt(self:random())
	local theta = self:random() * 2 * math.pi
	local x = cx + r * math.cos(theta)
	local y = cy + r * math.sin(theta)
	return x, y
end

function Planet:genTriangle(x, y, r)
	local range = r/3
	local x1, y1 = self:genPoint(x, y, r)
	local x2, y2 = self:random(x1-range,x1+range),self:random(y1-range,y1+range)
	local x3, y3 = self:random(x2-range,x2+range),self:random(y2-range,y2+range)
	return x1, y1, x2, y2, x3, y3
end

function Planet:genStripe(r, canvas)
	local border = (canvas - r*2) / 2
	local size = r*2
	local range = r/8

	--   ___
	-- 1/   \2
	-- 4\   /3
	--   ¯¯¯
	local x1, y1 = self:random(0, border), self:random(border, size+border)
	local x2, y2 = self:random(size+border,size+border*2), self:random(y1-range,y1+range)
	local x3, y3 = self:random(size+border,size+border*2), self:random(y2,y2+range)
	local x4, y4 = self:random(0, border), self:random(y1+1,y3)
	return x1, y1, x2, y2, x3, y3, x4, y4
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
