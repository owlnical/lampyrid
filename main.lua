local version = 0.2
local cargo = require "lib.cargo"
local moonshine = require "lib.moonshine"
local class = require "lib.middleclass"
local Terminal = require "class.terminal"
local Planet = require "class.planet"

function love.load()
	-- Load assets
	font = cargo.init("assets/fonts")

	-- Enable text input character repeat so we can hold Backspace to erase characters
	love.keyboard.setKeyRepeat(true)

	-- Font settings
	local fontsize = 18 -- 26 rows
	love.graphics.setFont(font.hack_regular(fontsize))

	-- Main terminal
	terminal = Terminal:new("Main Terminal", 26)
	terminal:printf("\nWelcome to Lampyrid v%s\n", version)

	-- System thread for game state etc
	system = {
		thread = love.thread.newThread("system.lua"),
		delta = love.thread.getChannel("delta")
	}
	system.update = function(dt) system.channel:supply(dt) end
	system.thread:start()

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

	-- Planet name files to arrays
	local name = { prefix = {}, main = {}, suffix = {} }
	local planet_names = cargo.init("assets/planet-names")
	for _, list in pairs(name) do
		for s in string.gmatch(planet_names.main, ".-\n") do
			list[#list+1] = s:gsub("\n","")
		end
	end

	-- Generate planets based on current time
	planet = {}
	local seed = os.time()
	for i = 1, 1000 do
		seed = seed + 1
		planet[i] = Planet:new(seed, name)
	end
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
	terminal:update()
	system.delta:supply(dt)

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
		if terminal:isEmpty() then
			love.event.quit()
		end
	elseif ctrl and key == "l" then
		terminal:clearBuffer()
	elseif ctrl and key == "w" then
		terminal:deleteWord()
	end
end

-- Print thread errors instead of stopping the love
function love.threaderror(thread, errorstr)
	print("thread error: " .. "\n" .. errorstr)
end
