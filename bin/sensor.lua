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
	system:supply({"get", "nav", "position"})
	print("Position:", unpack(system:demand()))
end
sensor.pos = sensor.position

main()
