local timer = require "love.timer"

function main()
	local args = love.thread.getChannel("args"):demand()
	local output = love.thread.getChannel("output")

	if args[1] == nil or tonumber(args[1]) == nil then
		output:push("usage: sleep <seconds>\n")
	else
		timer.sleep(tonumber(args[1]))
	end
end

main()
