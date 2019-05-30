require "channel"
local cpml = require("lib/cpml")
local sensor = require("program")
help = [[
sensor (Lampyrid core) 0.1

This program interacts with the ships sensors.

  Usage: sensor <command>

  sweep <range>   Scan for locations within optional range
  result <id>     Show results from last sweep. ID is optional
  help            Show this help
]]
format = {}

-- Loop planet table for each planet within range
function sensor.sweep(range)
  range = tonumber(range) or get("sensorrange")
  if range > get("sensorrange") then
    range = get("sensorrange")
  end

  -- Store planets within range of ship in results
  local result = {}
  local ship = cpml.vec3.new(get("position"))
  for k, planet in ipairs(get("planets")) do
    local distance = math.ceil(ship:dist(cpml.vec3.new(planet.position)))
    if distance <= range then
      planet.distance = distance
      table.insert(result, planet)
    end
  end
  
  -- Print results and store in data thread
  set("result", result)
  write(format.list(result))
end

  -- Print list of results
  -- or print single result
function sensor.result(choice)
  choice = tonumber(choice) or 0
  local result = get("result")

  if result and choice <= #result and choice >= 1 then
    output = format.single(result[choice])
  elseif result then
    output = format.list(result)
  else
    output = "No previous results found. Try sensor sweep."
  end
  
  write(output)
end

-- Take a table of results and format it as a list
function format.list(result)
  local list = "Planets within range:"
  for i, planet in ipairs(result) do
    list = list .. string.format("\n%s: %s - %s",
      i, planet.name, planet.distance)
  end
  return list
end

-- Take a planet table and format as detailed output
function format.single(planet)
  return string.format([[
name: %s
distance: %s
x: %s
y: %s
z: %s]],
  planet.name, planet.distance, unpack(planet.position))
end

run("sensor")