channel = {
  input = love.thread.getChannel("input"),
  output = love.thread.getChannel("output"),
  data = love.thread.getChannel("data")
}

function request(data)
  local response = channel.data:supply(data)
  return channel.data:demand()
end

function write(output)
	channel.output:push(output .. "\n")
end

function read()
	return channel.input:demand()
end