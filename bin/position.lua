request = love.thread.getChannel("request")
output = love.thread.getChannel("output")

function main()
	request:supply({"get", "nav", "position"})
	output:push(string.format("position %s.%s.%s\n", unpack(request:demand())))
end

main()
