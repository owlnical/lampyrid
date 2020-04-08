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
	local cmd, arg = sys.to_cmd_args(args)

	if cmd == "set" then
		local x = tonumber(arg[1])
		local y = tonumber(arg[2])
		local z = tonumber(arg[3])
		if x and y and z then
			sys.set("nav", "destination", arg)
			print("Destination changed to", x, y, z)
		else
			print("Error: invalid destination:", x, y, z)
		end
	elseif args[1] == nil then
		print("Destination:", sys.uget("nav", "destination"))
	end
end

-- short
sensor.pos = sensor.position
sensor.dest = sensor.destination

main()
