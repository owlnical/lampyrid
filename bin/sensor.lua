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

function sensor.destination()
	print("Destination:", sys.uget("nav", "destination"))
end

-- short
sensor.pos = sensor.position
sensor.dest = sensor.destination

main()
