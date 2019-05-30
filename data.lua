-- data.lua handles all vars etc
-- vars can be get/set over the channel "data"

local lmath = require("love.math")
local cpml = require("lib/cpml")
local channel = {
  output = love.thread.getChannel("output"),
  data = love.thread.getChannel("data")
}

-- Planet generator
local planets = {}
local range = 1000
local amount = 10
rng = lmath.newRandomGenerator(os.time())
for i=1, amount, 1 do
  planets[i] = {
    name = "planet " .. i,
    position = {rng:random(-range, range), rng:random(-range, range), rng:random(-range, range)}
  }
end

-- Store data here, which can be requested from anywhere
data = {
  -- Navigation
  position = {0, 0, 0},
  destination = {25, 25, 25},
  distance = 0,
  travel_time = 0,
  speed = 5,
  traveling = true,
  arrived = false,
  eta = 0,

  -- Ship
  sensorrange = 1000,

  -- Universe
  planets = planets
}

-- Read a value from the data table
function data.get(name)
  local reply = false
  if data[name] then
    reply = data[name]
  end
  channel.data:supply(reply)
end

-- Assign a value to the data table
function data.set(name, value)
  local reply = false
  if name then
    data[name] = value
    reply = true
  end
  channel.data:supply(reply)
end

-- Move forward by calculating lerp step from position, distance, speed and deltatime
function data.travel(dt)
  local vec3 = {
    destination = cpml.vec3.new(data.destination),
    position = cpml.vec3.new(data.position)
  }

  -- Current distance to destination
	data.distance = vec3.position:dist(vec3.destination)

  -- How far we will move
  -- How I came up with this black magic last year is now beyond me
  -- But it seems to be working
	local step = (data.distance / (data.distance - (dt * data.speed))) - 1

  -- We're not here yet
  -- Move towards the destination from the position based on the step
	if step < data.distance then
		vec3.position = cpml.vec3.lerp(vec3.position, vec3.destination, step)
		data.travel_time = data.travel_time + dt / 60
		data.eta = cpml.utils.round(data.distance / data.speed / 60)

  -- We're here, reset all traveling values
else
    write(string.format("Arrived at destination after %i minutes", math.ceil(data.travel_time)))
		data.traveling = false
		data.travel_time = 0
		data.distance = 0
		data.eta = 0
		vec3.position = vec3.destination:clone()
	end

  -- Update the position and destination tables with the current vector
  data.destination = {cpml.vec3.unpack(vec3.destination)}
  data.position = {cpml.vec3.unpack(vec3.position)}
end

-- Write to terminal before current input string.
function write(text, position)
	channel.output:push({
      text = text .. "\n",
      position = "before input"
    }
  )
end

-- Main loop listening for commands
while true do
  local command, name, value = unpack(channel.data:demand())
  data[command](name, value)
end