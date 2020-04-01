require "channel"
local cpml = require("lib/cpml")
local sensor = require("program")
help = [[
sensor (Lampyrid core) 0.1

This program interacts with the ships sensors.

  Usage: sensor <command>

  sweep [range]   Scan for locations. Default: max range
  result [id]     Show entry from result list. ID is optional
  lock [id]       Set destination from result list. Default: 0
  help            Show this help
  ---
  show <id>       result <id>
  select <id>     lock <id>
]]
format = {}

-- Change destination to a planet in the result list
function sensor.lock(choice)
	choice = tonumber(choice) or 0
	local planet = get("result", choice)
	if planet then
		set("navigation", "lock", planet.id)
		set("navigation", "destination", planet.position)
		write(string.format("Locked planet %s\nChanged destination to %s %s %s", planet.name, unpack(planet.position)))
	else
		write("ID " .. choice .. " not found in result list. Try sensor result.")
	end
end

-- Loop planet table for each planet within range
function sensor.sweep(range)

	-- Make sure we're not exceeding the scanning range
	local range_limit = get("ship", "sensorrange")
	range = tonumber(range) or range_limit
	if range > range_limit then
		write("Unable to set range to " .. range)
		write("Sensor range limited to " .. range)
		range = range_limit
	end

	-- Scan is based on All planets and the current position
	local planets = get("planets")
	local position = cpml.vec3.new(get("navigation", "position"))

	-- Store planets withing range in the results table
	local result = {}
	for k, planet in ipairs(planets) do
		local distance = math.ceil(position:dist(cpml.vec3.new(planet.position)))
		if distance <= range then
			write("planet found")
			planet.distance = distance
			table.insert(result, planet)
		end
	end

	-- Store result for future use (e.g. locking coords) and print result
	set("result", result)
	write(format.list(result, #result .. " planets within range: " .. range))
end

	-- Print list of results
	-- or print single result
function sensor.result(choice)
	choice = tonumber(choice) or 0
	local result = get("result")
	local text = ""
	if result and choice <= #result and choice >= 1 then
		text = format.single(result[choice])
	elseif result then
		text = format.list(result, #result .. " planets from last sweep:")
	else
		text = "No previous results found. Try sensor sweep."
	end
	write(text)
end

-- Take a table of results and format it as a list
function format.list(result, title)
	local list = title or "Output as list:"
	for i, planet in ipairs(result) do
		list = list .. string.format("\n[%s]: %s, distance: %s",
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

-- alias
sensor.select = sensor.lock
sensor.show = sensor.result

run("sensor")
