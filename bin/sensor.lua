system = love.thread.getChannel("system")
args = love.thread.getChannel("args")
output = love.thread.getChannel("output")
local sys = require "bin.lib.sys"
local sensor = {}

function main()
	local subcommand = sys.unpack_args()
	if subcommand and sensor[subcommand] then
		sensor[subcommand]()
	else
		output:push("sensor: unknown argument\n")
	end
end

function sensor.position()
	system:supply({"get", "nav", "position"})
	output:push(string.format(
		"position %s.%s.%s\n",
		unpack(system:demand())
	))
end

main()
