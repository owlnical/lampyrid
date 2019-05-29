channel = {
  input = love.thread.getChannel("input"),
  output = love.thread.getChannel("output"),
  data = love.thread.getChannel("data")
}

function request(command, packet, value)
  channel.data:supply({command, packet, value or false})
  return channel.data:demand(1)
end

function get(name)
  return request("get", name)
end

function uget(name)
  return unpack(request("get", name))
end

function set(name, value)
  return request("set", name, value)
end

function write(output)
	channel.output:push(output .. "\n")
end

function read()
	return channel.input:demand()
end