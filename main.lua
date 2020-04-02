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
	terminal:appendBuffer("\nWelcome to Lampyrid v" .. version .. "\n")

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
end

-- Add input to the terminal
function love.textinput(text)
	terminal:readInput(text)
end

function love.keypressed(key)
end

-- Print thread errors instead of stopping the love
function love.threaderror(thread, errorstr)
	print("thread error: " .. "\n" .. errorstr)
end
