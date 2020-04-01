local version = 0.2
local cargo = require('lib/cargo')
local class = require "lib/middleclass"
local Terminal = require("class/terminal")

function love.load()
	-- Load assets
	font = cargo.init("assets/fonts")

	-- Enable text input character repeat so we can hold Backspace to erase characters
	love.keyboard.setKeyRepeat(true)

	-- Font settings
	local fontsize = 20
	love.graphics.setFont(font.hack_regular(fontsize))

	-- Main terminal
	terminal = Terminal:new("Main Terminal")
	terminal:appendBuffer("\nWelcome to Lampyrid v" .. version .. "\n")
end

function love.draw()
	terminal:draw()
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
