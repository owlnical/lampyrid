local version = 0.1
local cpml = require("lib/cpml")
local utf8 = require("utf8")
local moonshine = require 'lib/moonshine'
local string = require "std/string"
require("util")

function love.load()
	-- Navigation
	position = cpml.vec3.new(0, 0, 0)
	destination = cpml.vec3.new(0, 0, 0)
	distance = 0
	travel_time = 0
	speed = 10
	traveling = true
	eta = 0

	-- Terminal
	terminal = {
		history = "$ Welcome to Lampyrid v" .. version .. "\n",
		prefix = "$ ",
		command = "",
		suffix = "█"
	}
	font = love.graphics.newFont("Hack-Regular.ttf", 20)
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
end

function love.draw()
	love.graphics.setBackgroundColor(0,0,0)

	-- Draw monitor with shader effects
	monitor(function()
		love.graphics.setColor(0.1, 0.1, 0.1, 1)
		love.graphics.rectangle("fill", 000,000, love.graphics.getDimensions())
		love.graphics.setColor(1, 1, 1)
	  love.graphics.printf(terminal.history .. terminal.prefix .. terminal.command .. terminal.suffix, 20, 20, love.graphics.getWidth()-50)
    end)
end

function love.update(dt)
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
	terminal.command = terminal.command .. text
end

function love.keypressed(key)
	-- Erase UTF-8 characters (https://love2d.org/wiki/love.textinput)
    if key == "backspace" then
        -- get the byte offset to the last UTF-8 character in the string.
        local byteoffset = utf8.offset(terminal.command, -1)

        if byteoffset then
            -- remove the last UTF-8 character.
            terminal.command = string.sub(terminal.command, 1, byteoffset - 1)
        end
	elseif key == "return" then
		run(terminal.command)
    end
end

-- Handle commands
function run(input)
	local output = ""
	local args = string.split(input)
	local command = args[1]
	table.remove(args, 1)
	if command == "q" then
		love.event.quit()
	elseif command == "clear" then
		terminal.history = ""
		terminal.command = ""
		return
	elseif command == "version" then
		output = "\nLampyrid v" .. version .. "\n"
	elseif command == "position" then
		output = "\n" ..  position:to_string() .. "\n"
	elseif command == "destination" then
		output = "\n" ..  destination:to_string() .. "\n"
	elseif command == "eta" then
		output = "\n" .. eta .. " minutes\n"
	elseif command == "distance" then
		output = "\n" .. distance .. " space miles\n"
	else
		output = "\ncommand not found\n"
	end
	terminal.history = terminal.history .. terminal.prefix .. input .. output
	terminal.command = ""
end
