local version = 0.2

function love.load()
end

function love.draw()
end

function love.update(dt)
end

function love.textinput(text)
end

function love.keypressed(key)
end

-- Print thread errors instead of stopping the love
function love.threaderror(thread, errorstr)
	print("thread error: " .. "\n" .. errorstr)
end
