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
		size = 1200,
		border = 400,
		canvas = 2000,
		r = 600,
		x = 1000,
		y = 1000,
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

	-- Placeholder rect for custom mask inserted Before gradients
	svg:addRect(-5)

	-- Gradient
	local x, y = conf.border - 1, conf.border - 1
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
		local x, y = self:genStar(conf.canvas, conf.r)
		svg:addCircle(x, y, self:random()*3):setStyle(style)
	end


	-- Black border overlay
	local mask = [[
  <defs>
    <linearGradient
       id="mask-gradient">
      <stop
         offset="0"
         style="stop-color:#ff1717;stop-opacity:0"
         id="stop4872" />
      <stop
         id="stop4950"
         style="stop-color:#7f0b0b;stop-opacity:0"
         offset="0.55797428" />
      <stop
         offset="0.59"
         style="stop-color:#fff9f9;stop-opacity:0.5"
         id="stop4954" />
      <stop
         offset="0.6"
         style="stop-color:#000000;stop-opacity:1"
         id="stop4952" />
      <stop
         offset="1"
         style="stop-color:#000000;stop-opacity:1"
         id="stop4874" />
    </linearGradient>
    <radialGradient
       gradientTransform="translate(-1.6953125e-5,2.5390625e-5)"
       gradientUnits="userSpaceOnUse"
       r="%d"
       fy="%d"
       fx="%d"
       cy="%d"
       cx="%d"
       id="radialGradient4958"
       xlink:href="#mask-gradient" />
  </defs>
  <rect
     y="0"
     x="0"
     height="%d"
     width="%d"
     id="mask"
     style="opacity:1;fill:url(#radialGradient4958);fill-opacity:1;stroke:none;stroke-width:334.611;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:0.0355919" />
	]]
	mask = mask:format(conf.x, conf.x, conf.x, conf.x, conf.x, conf.canvas, conf.canvas)
	self.svg = svg:createText()
	self.svg = self.svg:gsub('<rect x="%-5".->', mask)

	-- We're done here
	love.filesystem.write(self.seed .. ".svg", self.svg)
	love.filesystem.write("latest.svg", self.svg)
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

function Planet:genStar(canvas, r)
	local cx, cy = canvas/2, canvas/2
	local sx, sy
	while true do
		sx, sy = self:random(0, canvas), self:random(0, canvas)
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

function math.dist(x1,y1, x2,y2)
	return ((x2-x1)^2+(y2-y1)^2)^0.5
end

return Planet
