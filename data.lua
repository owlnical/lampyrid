-- Store data here, which can be requested from anywhere
local math = require("love.math")
local cpml = require("lib/cpml")
local channel = love.thread.getChannel("data")

rng = math.newRandomGenerator(os.time())
range = 1000
planets = {}
for i=1, 10, 1 do
  planets[i] = {
    name = "planet " .. i,
    position = {rng:random(range), rng:random(range), rng:random(range)}
  }
end

data = {
  -- Navigation
  position = {0, 0, 0},
  destination = {25, 25, 25},
  distance = 0,
  travel_time = 0,
  speed = 5,
  traveling = true,
  eta = 0,

  -- Universe
  planets = planets,
  sensorrange = 1000
}

vec3 = {}

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

  -- Convert the destination/position tables to vectors
  vec3.destination = cpml.vec3.new(data.destination)
  vec3.position = cpml.vec3.new(data.position)

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
		data.travel_time = data.travel_time + dt
		data.eta = cpml.utils.round(data.distance / data.speed / 60)

    --We're here, reset all traveling values
	else
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

-- Main loop listening for commands
while true do
  local command, name, value = unpack(channel:demand())
  data[command](name, value)
end