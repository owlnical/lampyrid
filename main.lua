local version = 0.2
local cargo = require('lib/cargo')

function love.load()
	-- Load assets
	font = cargo.init("assets/fonts")

	-- Enable text input character repeat so we can hold Backspace to erase characters
	love.keyboard.setKeyRepeat(true)

	local fontsize = 20
	love.graphics.setFont(font.hack_regular(fontsize))

end

function love.draw()
end

function love.update(dt)
end

-- Add input to the terminal
function love.textinput(text)
end

function love.keypressed(key)
end

-- Print thread errors instead of stopping the love
function love.threaderror(thread, errorstr)
	print("thread error: " .. "\n" .. errorstr)
end
