-- Shared library for all programs
local program = {}

-- run the program function which matches the first arg
-- fallback to function get() if it exists. Otherwise print error
function run(name)
	local args = read() -- read terminal input
	local subcommand = args[1]
	table.remove(args, 1)
	if program[subcommand] then
		program[subcommand](unpack(args))
	elseif program.get and not subcommand then
		program.get()
	else
		write("Error: unknown argument. Try " .. name .. " help.")
	end
end

-- This requires that help is a global in the program
function program.help()
	write(help)
end

return program
