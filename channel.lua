channel = {
  input = love.thread.getChannel("input"),
  output = love.thread.getChannel("output"),
  data = love.thread.getChannel("data")
}

-- Send requests to the data thread
function request(...)
  channel.data:supply({...})
  return channel.data:demand()
end

-- Shortcut for get request
function get(name)
  return request("get", name)
end

-- Shortcut for get request with unpack
function uget(name)
  return unpack(request("get", name))
end

-- Shortcut for set request
function set(name, value)
  return request("set", name, value)
end

-- Write to terminal
function write(text, position)
  position = position or "after input"
	channel.output:push({
      text = text .. "\n",
      position = position
    }
  )
end

-- Read from terminal
function read()
	return channel.input:demand()
end