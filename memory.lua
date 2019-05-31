local lmath = require("love.math")
local cpml = require("lib/cpml")
local output = {
  channel = love.thread.getChannel("output"),
}

navigation = {
  position = {0, 0, 0},
  destination = {25, 25, 25},
  distance = 0,
  travel_time = 0,
  speed = 5,
  traveling = true,
  arrived = false,
  eta = 0
}

ship = {
  sensorrange = 1000
}

planets = {}
local range = 1000
local amount = 10
rng = lmath.newRandomGenerator(os.time())
for i=1, amount, 1 do
  planets[i] = {
    name = "planet " .. i,
    position = {rng:random(-range, range), rng:random(-range, range), rng:random(-range, range)}
  }
end

local memory = {
  channel = love.thread.getChannel("memory"),
  navigation = navigation,
  ship = ship,
  planets = planets,
  result = {}
}

-- Move forward by calculating lerp step from position, distance, speed and deltatime
function memory.travel(dt)
  local vec3 = {
    destination = cpml.vec3.new(navigation.destination),
    position = cpml.vec3.new(navigation.position)
  }

  -- Current distance to destination
	navigation.distance = vec3.position:dist(vec3.destination)

  -- How far we will move
  -- How I came up with this black magic last year is now beyond me
  -- But it seems to be working
	local step = (navigation.distance / (navigation.distance - (dt * navigation.speed))) - 1

  -- We're not here yet
  -- Move towards the destination from the position based on the step
	if step < navigation.distance then
		vec3.position = cpml.vec3.lerp(vec3.position, vec3.destination, step)
		navigation.travel_time = navigation.travel_time + dt / 60
		navigation.eta = cpml.utils.round(navigation.distance / navigation.speed / 60)

  -- We're here, reset all traveling values
  else
    output.write(string.format("Arrived at destination after %i minutes", math.ceil(navigation.travel_time)))
		navigation.traveling = false
		navigation.travel_time = 0
		navigation.distance = 0
		navigation.eta = 0
		vec3.position = vec3.destination:clone()
	end

  -- Update the position and destination tables with the current vector
  navigation.destination = {cpml.vec3.unpack(vec3.destination)}
  navigation.position = {cpml.vec3.unpack(vec3.position)}
end

-- Write to terminal before current input string.
function output.write(text, position)
	output.channel:push({
      text = text .. "\n",
      position = "before input"
    }
  )
end

function memory.get(db, key)
  if db and key then
    response = memory[db][key]
  elseif db then
    response = memory[db]
  else
    response = false
  end
  memory.channel:supply(response)
end

function memory.set(db, key, value)
  if db and key and value then
    memory[db][key] = value
  elseif db and key then
    newdb = key
    memory[db] = newdb
  end
end

-- Main loop listening for function name and arguments
while true do
  local func, arg1, arg2, arg3 = unpack(memory.channel:demand())
  memory[func](arg1, arg2, arg3)
end