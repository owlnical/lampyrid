system = love.thread.getChannel("system")
output = love.thread.getChannel("output")
local sys = require "bin.lib.sys"
local sensor = {}

function main()
	print = sys.print
	local subcommand = sys.unpack_args()
	if subcommand and sensor[subcommand] then
		sensor[subcommand]()
	else
		output:push("sensor: unknown argument\n")
	end
end

function sensor.position()
	system:supply({"get", "nav", "position"})
	print("Position:", unpack(system:demand()))
end

main()
