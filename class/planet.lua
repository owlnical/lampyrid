local class = require "lib.middleclass"
local Planet = class("Planet")
local lsw = require "lib.LuaSVGWriter"

function Planet:initialize(seed, name)
	self.seed = seed
	self.rng = love.math.newRandomGenerator(seed)

	-- random name. Might have prefix and suffix.
	local p = name.prefix[self.rng:random(1, #name.prefix*3)] or ""
	local m = name.main[self.rng:random(1, #name.main)]
	local s = name.suffix[self.rng:random(1, #name.suffix*3)] or ""
	self.name = string.format("%s %s %s", p, m, s):gsub("^%s",""):gsub("%s$","")
end

function Planet:genSVG()
	local hue_low, hue_high, sat_low, sat_high, light_low, light_high
	local color_scheme = self:random(1,2)
	if color_scheme == 1 then
		hue_low    = self:random(0, 0.80)
		hue_high   = hue_low + self:random(0, 0.2)
		sat_low    = self:random(0, 0.8)
		sat_high   = self:random(0.5, 1)
		light_low  = self:random(0, 0.5)
		light_high = self:random(0.5, 1)
	else
		hue_low    = self:random(-0.1, 0.90)
		hue_high   = hue_low + self:random(0, 0.15)
		sat_low    = self:random(0.4, 0.7)
		sat_high   = self:random(0.7, 1)
		light_low  = self:random(0.25, 0.5)
		light_high = self:random(0.5, 0.75)
	end
	local conf = {
		w = 800,
		h = 600,
		size = 400,
		r = 200,
		x = 400,
		y = 300,
		color = {
			hue = { hue_low, hue_high },
			sat = { sat_low, sat_high },
			light = { light_low, light_high }
		}
	}


	local svg = lsw.Document:new(conf.w, conf.h)

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
			local x1, y1, x2, y2, x3, y3, x4, y4 = self:genStripe(conf.r, conf.w, conf.h, conf.x, conf.y)
			svg:addPolygon():add(x1, y1):add(x2, y2):add(x3, y3):add(x4, y4):setStyle(style)
		end
	end
	--]]

	-- Placeholder rect for custom mask inserted Before gradients
	svg:addRect(-5)

	-- Gradient
	local x, y = conf.x - conf.r - 1, conf.y - conf.r - 1
	local w, h = conf.size + 2, conf.size + 2
	local angle = self:random(1, 360)
	local gradient = lsw.LinearGradient:new("black")

	style:setFill(gradient)
	for i=1, self:random(1,3) do
		style:setOpacity(self:random(0.8, 1))
		svg:addRect(x, y, w, h):
			setStyle(style):
			rotate(self:random(angle-10, angle+10), conf.x, conf.y
		)
	end
	--]]

	-- Stars
	style:setFill("white")
	for i=1, self:random(500, 1500) do
		style:setOpacity(self:random(0.8, 1))
		local x, y = self:genStar(conf.x, conf.y, conf.r, conf.w, conf.h)
		svg:addCircle(x, y, self:random(0, conf.r/250)):setStyle(style)
	end


	-- Black border overlay
	local mask = [[
  <defs
     id="defs2042">
    <linearGradient
       id="mask-gradient">
      <stop
         id="stop4872"
         style="stop-color:#ff1717;stop-opacity:0"
         offset="0" />
      <stop
         offset="0.55797428"
         style="stop-color:#7f0b0b;stop-opacity:0"
         id="stop4950" />
      <stop
         id="stop4954"
         style="stop-color:#fff9f9;stop-opacity:0.5"
         offset="0.59" />
      <stop
         id="stop4952"
         style="stop-color:#000000;stop-opacity:1"
         offset="0.6" />
      <stop
         id="stop4874"
         style="stop-color:#000000;stop-opacity:1"
         offset="1" />
    </linearGradient>
    <radialGradient
       xlink:href="#mask-gradient"
       id="radialGradient4958"
       cx="%d"
       cy="%d"
       fx="%d"
       fy="%d"
       r="%d"
       gradientUnits="userSpaceOnUse"
       gradientTransform="matrix(0.83400118,0,0,0.83743359,66.399515,48.803407)" />
  </defs>
  <rect
     style="opacity:1;fill:url(#radialGradient4958);fill-opacity:1;stroke:none"
     id="mask"
     width="%d"
     height="%d"
     x="0"
     y="0" />
	]]
	mask = mask:format(
		conf.x, conf.y, -- cx, cy
		conf.x, conf.y, -- fx, fy
		conf.size, conf.w, conf.h
	)

	self.svg = svg:createText()
	self.svg = self.svg:gsub('<rect x="%-5".->', mask)

	-- We're done here
	self.filename = string.gsub(self.seed .. "_" .. self.name .. ".svg", "[%s']", "_"):lower()
	self.filename = string.format("%s_%s.svg", self.seed, self.name):gsub("[%s']", "_"):lower()
	love.filesystem.write(self.filename, self.svg)
end

-- Return random HSL from high/low base range
function Planet:genColor(hsl)
	return lsw.Color.HSL(
		self:random(unpack(hsl.hue)),
		self:random(unpack(hsl.sat)),
		self:random(unpack(hsl.light))
	)
end

function Planet:genPoint(cx, cy, r)
	local r = r * math.sqrt(self:random())
	local theta = self:random() * 2 * math.pi
	local x = cx + r * math.cos(theta)
	local y = cy + r * math.sin(theta)
	return x, y
end

function Planet:genStar(cx, cy, r, w, h)
	local sx, sy
	while true do
		sx, sy = self:random(0, w), self:random(0, h)
		if math.dist(sx,sy, cx,cy)  > r then
			return sx, sy
		end
	end
end


function Planet:genTriangle(x, y, r)
	local range = r/3
	local x1, y1 = self:genPoint(x, y, r)
	local x2, y2 = self:random(x1-range,x1+range),self:random(y1-range,y1+range)
	local x3, y3 = self:random(x2-range,x2+range),self:random(y2-range,y2+range)
	return x1, y1, x2, y2, x3, y3
end

function Planet:genStripe(r, w, h, x, y)
	local size = r*2
	local range = r/8

	-- Left points
	local lx1, lx2 = x-r-50, x-r-5
	local ly1, ly2 = y-r, y+r

	-- Right points
	local rx1, rx2 = x+r, x+r+50
	local ry1, ry2 = y-r, y+r

	--   ___
	-- 1/   \2
	-- 4\   /3
	--   ¯¯¯
	local x1, y1 = self:random(lx1, lx2), self:random(ly1, ly2)
	local x2, y2 = self:random(rx1, rx2), self:random(y1-range,y1+range)
	local x3, y3 = self:random(rx1, rx2), self:random(y2,y2+range)
	local x4, y4 = self:random(lx1, lx2), self:random(y1+1,y3)
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

function math.dist(x1,y1, x2,y2)
	return ((x2-x1)^2+(y2-y1)^2)^0.5
end

return Planet
