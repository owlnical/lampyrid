system = love.thread.getChannel("system")
output = love.thread.getChannel("output")

function main()
	system:supply({"get", "nav", "position"})
	output:push(string.format(
		"position %s.%s.%s\n",
		unpack(system:demand())
	))
end

main()
