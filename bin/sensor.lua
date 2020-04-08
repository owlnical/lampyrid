system = love.thread.getChannel("system")
local sys = require "bin.lib.sys"
local sensor = {}

function main()
	print = sys.print
	local cmd, args = sys.get_cmd_args()
	if cmd and sensor[cmd] then
		sensor[cmd](args)
	else
		print("sensor: unknown argument")
	end
end

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

-- short
sensor.pos = sensor.position
sensor.dest = sensor.destination

main()
