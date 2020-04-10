local sys = require "bin.lib.sys"
local sensor = {
	_NAME = "Sensor",
	_VERSION = "0.1",
	_HELP = "Interact with the ships sensors"
}

function sensor.position()
	print("Position:", sys.uget("nav", "position"))
end

function sensor.destination(args)
	local cmd, args = sys.to_cmd_args(args)

	if cmd == "set" then
		local coords, x, y, z = sys.validate_coords(args)
		if coords then
			sys.set("nav", "destination", coords)
			print("Destination changed to:", x, y, z)
		else
			print("Error: invalid destination")
		end
	elseif not cmd then
		print("Destination:", sys.uget("nav", "destination"))
	end
end

function sensor.default()
	print("Position:", sys.uget("nav", "position"))
	print("Destination:", sys.uget("nav", "destination"))
end

-- short
sensor.pos = sensor.position
sensor.dest = sensor.destination

-- Run program with generic handler
sys.run_program(sensor)
