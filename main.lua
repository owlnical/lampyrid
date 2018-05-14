local version = 0.1
local cpml = require("lib/cpml")
local utf8 = require("utf8")
local moonshine = require 'lib/moonshine'
local string = require "std/string"
-- Terminal
terminal = {
	text = "$ Welcome to Lampyrid v" .. version .. "\n",
	prefix = "$ ",
	input = "",
	suffix = "█",
	history = {""},
	current = 1
}

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
	  love.graphics.printf(terminal.text .. terminal.prefix .. terminal.input .. terminal.suffix, 20, 20, love.graphics.getWidth()-50)
    end)
end

-- Erase UTF-8 characters (https://love2d.org/wiki/love.textinput)
function terminal:backspace()
	local byteoffset = utf8.offset(self.input, -1)
	if byteoffset then
		self.input = string.sub(self.input, 1, byteoffset - 1)
	end
end

-- Move up or down in terminal history
function terminal:move(direction)
	self.history[self.current] = self.input
	if direction == "up" and self.current > 1 then
			self.current = self.current - 1
	elseif direction == "down" and self.current < #self.history then
			self.current = self.current + 1
	end
	self.input = "" .. self.history[self.current]
end

-- Print text to terminal
function terminal:print(text)
	self.text = self.text .. text
end

-- Split input string into command and args
function terminal:splitInput(input)
	local args = string.split(input or self.input)
	local command = args[1]
	self.text = self.text .. self.prefix .. self.input .. "\n"
	table.remove(args, 1)
	return command, args
end

-- Add current input to history and and clear input
function terminal:commandToHistory()
	self.history[#self.history] = self.input
	self.history[#self.history + 1] = ""
	self.input = ""
	self.current = #self.history
end

-- Run current input
function terminal:run()
	local command, arg = terminal:splitInput()
	if command ~= "" then
		if false then
			-- find commands
		else
			terminal:print("Command not found\n")
		end
		terminal:commandToHistory()
	end
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
	terminal.input = terminal.input .. text
end

function love.keypressed(key)
    if key == "backspace" then
		terminal:backspace()
	elseif key == "return" then
		terminal:run()
	elseif key == "up" or key == "down" then
		terminal:move(key)
    end
end

function love.threaderror(thread, errorstr)
	print("thread error: " .. errorstr) -- Will print error instead of stopping the love
end
