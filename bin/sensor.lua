system = love.thread.getChannel("system")
local sys = require "bin.lib.sys"
local sensor = {}

function main()
	print = sys.print
	local subcommand = sys.unpack_args()
	if subcommand and sensor[subcommand] then
		sensor[subcommand]()
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
