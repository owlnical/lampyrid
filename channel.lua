input = love.thread.getChannel("input")    -- Input from terminal
output = love.thread.getChannel("output")  -- Output to terminal
memory = love.thread.getChannel("memory")  -- Contact with memory thread

-- Shortcut for get request
function get(...)
  memory:supply({"get", ...})
  return memory:demand()
end

-- Shortcut for get request with unpack
function uget(...)
  return unpack(get(...))
end

-- Shortcut for set request
function set(...)
  memory:supply({"set", ...})
end

-- Write to terminal
function write(text, position)
  position = position or "after input"
	output:push({
      text = text .. "\n",
      position = position
    }
  )
end

function engineStarted()
  return get("ship", "engine")
end

function isTraveling()
  return get("navigation", "traveling")
end

function updatePosition(dt)
  memory:supply({"updatePosition", dt})
end

function updateTime(dt)
  memory:push({"updateTime", dt})
end

function findPlanet(range)
  memory:supply({"findPlanet", range})
  return memory:demand()
end

-- Read from terminal
function read()
	return input:demand()
end