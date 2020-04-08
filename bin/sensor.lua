system = love.thread.getChannel("system")
args = love.thread.getChannel("args")
output = love.thread.getChannel("output")
local sensor = {}

function main()
	local a = args:demand()
	if a[1] and sensor[a[1]] then
		sensor[a[1]](a)
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
