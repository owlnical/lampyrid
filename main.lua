local version = 0.1
local cpml = require("lib/cpml")
local utf8 = require("utf8")
local moonshine = require 'lib/moonshine'
local string = require "std/string"
local class = require "lib/middleclass"
local Terminal = require "class/terminal"

function love.load()
  local data = love.thread.newThread("data.lua")
  data:start()

  local fontsize = 20
  terminal = Terminal:new("$ Welcome to Lampyrid v" .. version .. "\n", fontsize)
  view = "terminal"
	font = love.graphics.newFont("Hack-Regular.ttf", fontsize)
	love.graphics.setFont(font)

	-- Shaders
	monitor = moonshine(moonshine.effects.crt)
		.chain(moonshine.effects.scanlines)
		.chain(moonshine.effects.vignette)
		.chain(moonshine.effects.glow)
	monitor.parameters = {
		crt = {distortionFactor = {1.06, 1.065}, x = 10, y = 50},
		scanlines = { opacity = 0.1},
		vignette = { opacity = 0.1}
	}

  --images
  stars = love.graphics.newImage( "img/stars.jpg" )
  planet = love.graphics.newImage( "img/planet.png" )
  rotation = 0
end

function love.draw()
	-- Draw monitor with shader effects
	monitor(function()
    if view == "terminal" then
      love.graphics.setColor(0.1, 0.1, 0.1)
      love.graphics.rectangle("fill", 000,000, love.graphics.getDimensions())
      love.graphics.setColor(1, 1, 1)
      love.graphics.printf(terminal:getContent(), 20, 20, love.graphics.getWidth()-50)
    elseif view == "space" then
      love.graphics.setColor(1, 1, 1)
      love.graphics.draw(stars, 0,0)
      love.graphics.draw(planet, 600, 600, rotation, 1.1, 1.1, 500, 500)--, 3, 3)
      love.graphics.setColor(0.1, 0.1, 0.1, 0.3)
      love.graphics.rectangle("fill", 000,000, love.graphics.getDimensions())
    end
  end)
end

function love.update(dt)
  rotation = rotation + (dt * 0.001)
	if traveling then travel(dt) end
end

-- Move forward by calculating lerp step from distance, speed and time
function travel(dt)
	distance = position:dist(destination)
	step = (distance / (distance - (dt * speed))) - 1
	if step < 1 then
		position = cpml.vec3.lerp(position, destination, step)
		travel_time = travel_time + dt
		eta = cpml.utils.round(distance / speed / 60)
	else
		print("Arrived after: " .. cpml.utils.round(travel_time / 60).. " minutes", step)
		traveling = false
		travel_time = 0
		distance = 0
		eta = 0
		position = destination:clone()
	end
end

-- Add input to the terminal
function love.textinput(text)
	terminal:appendInput(text)
end

function love.keypressed(key)
    if key == "backspace" then
		terminal:backspace()
	elseif key == "return" then
		terminal:run()
	elseif key == "up" or key == "down" or key == "left" or key == "right" then
		terminal:move(key)
  elseif key=="l" and love.keyboard.isDown("lctrl","rctrl") then
    terminal:clear()
  elseif key == "f1" then
    view = "terminal"
  elseif key == "f2" then
    view = "space"
    end
end

function love.threaderror(thread, errorstr)
	print("thread error: " .. errorstr) -- Will print error instead of stopping the love
end
