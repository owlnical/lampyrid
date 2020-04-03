local version = 0.2
local cargo = require('lib/cargo')
local moonshine = require("lib/moonshine")
local class = require "lib/middleclass"
local Terminal = require("class/terminal")

function love.load()
	-- Load assets
	font = cargo.init("assets/fonts")

	-- Enable text input character repeat so we can hold Backspace to erase characters
	love.keyboard.setKeyRepeat(true)

	-- Font settings
	local fontsize = 18 -- 26 rows
	love.graphics.setFont(font.hack_regular(fontsize))

	-- Main terminal
	terminal = Terminal:new("Main Terminal")
	terminal:printf("\nWelcome to Lampyrid v%s\n", version)

	-- Shaders to emulate a crt monitor
	shader = moonshine(moonshine.effects.scanlines)
		.chain(moonshine.effects.vignette)
		.chain(moonshine.effects.glow)
		.chain(moonshine.effects.godsray)
		.chain(moonshine.effects.crt)
	shader.parameters = {
		crt = {distortionFactor = {1.06, 1.065}, x = 10, y = 50},
		scanlines = {opacity = 0.1},
		godsray = {exposure = 0.01 },
		vignette = {opacity = 0.1}
	}
end

function love.draw()
	shader(function()
		-- Monitor glass and terminal text
		love.graphics.setColor(0.1, 0.1, 0.1, alpha)
		love.graphics.rectangle("fill", 0, 0, love.graphics.getDimensions())
		terminal:draw()
	end)
end

function love.update(dt)
	-- Subtle scanlines flickr
	shader.scanlines.width = love.math.random(2, 3)
end

-- Add input to the terminal
function love.textinput(text)
	terminal:readInput(text)
end

function love.keypressed(key)
	local ctrl = love.keyboard.isDown("lctrl", "rctrl")

	if key == "backspace" then
		terminal:backspace()
	elseif key == "return" then
		terminal:execute()
	elseif key == "up" then
		terminal:up()
	elseif key == "down" then
		terminal:down()
	elseif ctrl and key == "c" then
		terminal:interrupt()
	elseif ctrl and key == "d" then
		terminal:exit()
	elseif ctrl and key == "l" then
		terminal:clearBuffer()
	end
end

-- Print thread errors instead of stopping the love
function love.threaderror(thread, errorstr)
	print("thread error: " .. "\n" .. errorstr)
end
