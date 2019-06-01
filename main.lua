local version = 0.1
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

  -- Required to delete multiple char with backspace
  love.keyboard.setKeyRepeat(true)

  -- Terminal and initially view the terminal
  local fontsize = 20
  love.graphics.setFont(font.hack_regular(fontsize))
  terminal = Terminal:new("Welcome to Lampyrid v" .. version .. "\n", fontsize)
  view = "terminal"

	-- Shaders
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
  if isTraveling() then
    particles.stars:update(dt)
    updatePosition(dt)
  end
  terminal:listen()
end

-- Add input to the terminal
function love.textinput(text)
	terminal:appendInput(text)
end

function love.keypressed(key)
  if key == "f3" then
    write("space: test")
  elseif key == "backspace" then
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
      terminal:abort()
    elseif key == "d" then
      terminal:exit()
    elseif key == "w" then
      terminal:deleteWord()
    end
  end
end

function love.threaderror(thread, errorstr)
	print("thread error: " .. errorstr) -- Will print error instead of stopping the love
end
