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
		size = 30,
		r = 15,
		x = 25,
		y = 25,
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
		canvas = {
			size = 50,
			cx = 25,
			cy = 25
		}
	}

	local svg = lsw.Document:new(conf.canvas.size, conf.canvas.size)

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

	-- Black border overlay
	local mask = [[  <path
     d="M 0 0 L 0 50 L 50 50 L 50 0 L 0 0 z M 24.964844 10.099609 A 14.9 14.9 0 0 1 25 10.099609 A 14.9 14.9 0 0 1 39.900391 25 A 14.9 14.9 0 0 1 25 39.900391 A 14.9 14.9 0 0 1 10.099609 25 A 14.9 14.9 0 0 1 24.964844 10.099609 z "
     style="fill:#000000"
     id="rect2864" />
</svg>]]
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
	local range = 5
	local x1, y1 = self:genPoint(x, y, r)
	local x2, y2 = self:random(x1-range,x1+range),self:random(y1-range,y1+range)
	local x3, y3 = self:random(x2-range,x2+range),self:random(y2-range,y2+range)
	return x1, y1, x2, y2, x3, y3
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
