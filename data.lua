-- Store data here, which can be requested from anywhere
local cpml = require("lib/cpml")
local channel = love.thread.getChannel("data")
data = {
  -- Navigation
  position = {0, 0, 0},
  destination = {25, 25, 25},
  position3 = cpml.vec3.new(0, 0, 0),
  destination3 = cpml.vec3.new(25, 25, 25),
  distance = 0,
  travel_time = 0,
  speed = 5,
  traveling = true,
  eta = 0
}

function data.get(name)
  local reply = false
  if data[name] then
    reply = data[name]
  end
  channel:supply(reply)
end

function data.set(name, value)
  local reply = false
  if name and value then
    data[name] = value
    reply = true
  end
  channel:supply(reply)
end

-- Move forward by calculating lerp step from position, distance, speed and deltatime
function data.travel(dt)

  -- Current distance to destination
	data.distance = data.position3:dist(data.destination3)

  -- How far we will move
	local step = (data.distance / (data.distance - (dt * data.speed))) - 1

  -- We're not here yet
	if step < 1 then

    -- Move towards the destination from the position based on the step
		data.position3 = cpml.vec3.lerp(data.position3, data.destination3, step)
		data.travel_time = data.travel_time + dt
		data.eta = cpml.utils.round(data.distance / data.speed / 60)

    --We're here
	else
		data.traveling = false
		data.travel_time = 0
		data.distance = 0
		data.eta = 0
		data.position3 = data.destination3:clone()
	end

  -- Update the position and destination tables with the current vector
  local x, y, z = cpml.vec3.unpack(data.destination3)
  data.destination = {x, y, z}
  x, y, z = cpml.vec3.unpack(data.position3)
  data.position = {x, y, z}
end

-- Main loop listening for commands
while true do
  local command, name, value = unpack(channel:demand())
  data[command](name, value)
end