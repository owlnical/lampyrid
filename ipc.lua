local input = {
	channel = love.thread.getChannel("input")
}
local output = {
	channel = love.thread.getChannel("output")
}

function input.read()
	return input.channel:demand()
end

function output.write(text)
	output.channel.supply(text)
end
