require "channel"
local timer = require "love.timer"

help = [[
sleep (Lampyrid core) 1.0

This program sleeps X seconds

  Usage: sleep <seconds>

  help                Show this help
]]

function run()
	local args = read() -- Read terminal arguments
	local seconds

	if args[1] == "help" then
		write(help)
	elseif args[1] then
		local seconds = tonumber(args[1])
		if seconds then
			timer.sleep(seconds)
		else
			write("Unable to interpret arg '" .. args[1] .. "' as seconds")
		end
	else
		write("Missing argument <seconds>")
	end
end

run()
