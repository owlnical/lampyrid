require "channel"
local echo = require "program"
help = [[
echo (Lampyrid core) 1.0

This program prints all arguments

  Usage: echo <string> <string>...

  help                Show this help
]]

-- Override standard run()
function run()
	local args = read()
	if echo[args[1]] then
		echo[args[1]](args)
	else
		write(table.concat(args, " "))
	end
end

run()
