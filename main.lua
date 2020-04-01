local version = 0.2
local cpml = require("lib/cpml")
local utf8 = require("utf8")
local moonshine = require("lib/moonshine")
local string = require("std/string")
local class = require("lib/middleclass")
local Terminal = require("class/terminal")
local Planet = require("class/planet")
local cargo = require('lib/cargo')
require("channel")

function love.load()
	-- Stores current game state
	love.thread.newThread("memory.lua"):start()
	
	-- Load assets
	font = cargo.init("assets/fonts")
	image = cargo.init("assets/images")
	particles = cargo.init("assets/particles")

	-- Enable text input character repeat so we can hold Backspace to erase characters
	love.keyboard.setKeyRepeat(true)

	-- Create a new terminal and set it as initial view
	local fontsize = 20
	love.graphics.setFont(font.hack_regular(fontsize))
	terminal = Terminal:new("Welcome to Lampyrid v" .. version .. "\n", fontsize)
	view = "terminal"

	-- Shaders to emulate a crt monitor
	shader = moonshine(moonshine.effects.crt)
		.chain(moonshine.effects.scanlines)
		.chain(moonshine.effects.vignette)
		.chain(moonshine.effects.glow)
	shader.parameters = {
		crt = {distortionFactor = {1.06, 1.065}, x = 10, y = 50},
		scanlines = {opacity = 0.1},
		vignette = {opacity = 0.1}
	}

	-- A planet
	planet = Planet:new(image.planet)
end

function love.draw()

	-- Calls wrapped in the shader function
	-- will be drawn with shader effects
	shader(function()
		if view == "terminal" then
			terminal:draw()
		elseif view == "space" and isTraveling() then
			particles.draw("stars")
		elseif view == "space" then
			planet:draw()
		end
	end)
end

function love.update(dt)
	updateTime(dt)
	planet:rotate(dt * 0.001)
	if isTraveling() and engineStarted() then
		particles.stars:update(dt)
		updatePosition(dt)
	end
	terminal:update()
end

-- Add input to the terminal
function love.textinput(text)
	if view == "terminal" then
		terminal:appendInput(text)
	end
end

function love.keypressed(key)
	if key == "backspace" then
		terminal:backspace()
	elseif key == "return" then
		terminal:run()
	elseif key == "up" or key == "down" then
		terminal:move(key)
	elseif key == "f1" then
		view = "terminal"
	elseif key == "f2" then
		view = "space"
	elseif love.keyboard.isDown("lctrl","rctrl") then
		if key == "l" then
			terminal:clear()
		elseif key == "c" then
			terminal:interrupt()
		elseif key == "d" then
			terminal:exit()
		elseif key == "w" then
			terminal:deleteWord()
		end
	end
end

-- Print thread errors instead of stopping the love
function love.threaderror(thread, errorstr)
	print("thread error: " .. "\n" .. errorstr)
end
