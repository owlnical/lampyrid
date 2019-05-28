channel = {
  input = love.thread.getChannel("input"),
  output = love.thread.getChannel("output")
}

function write(output)
	channel.output:push(output .. "\n")
end

function read()
	return channel.input:demand()
end