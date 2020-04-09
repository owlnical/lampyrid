local sys = {
	channel = {
		output = love.thread.getChannel("output"),
		args = love.thread.getChannel("args"),
		system = love.thread.getChannel("system")
	}
}

function sys.get_args()
	return sys.channel.args:demand()
end

function sys.unpack_args()
	return unpack(sys.get_args())
end

function sys.get_cmd_args()
	local args = sys.get_args()
	local cmd = args[1]
	table.remove(args, 1)
	return cmd, args
end

function sys.to_cmd_args(args)
	local cmd = args[1]
	table.remove(args, 1)
	return cmd, args
end

function sys.print(...)
	local text = ""
	for _, v in ipairs({...}) do
		text = text .. "%s "
	end
	sys.printf(text .. "\n", ...)
end

function sys.printf(...)
	sys.channel.output:push(string.format(...))
end

function sys.get(t, k)
	sys.channel.system:supply({"get", t, k})
	return sys.channel.system:demand()
end

function sys.set(t, k, v)
	sys.channel.system:supply({"set", t, k, v})
end

function sys.uget(t, k)
	return unpack(sys.get(t, k))
end

function sys.validate_coords(c)
	local x = tonumber(c[1])
	local y = tonumber(c[2])
	local z = tonumber(c[3])
	if x and y and z then
		return {x, y, z}, x, y, z
	else
		return false
	end
end

function sys.run_program(program)
	local cmd, args = sys.get_cmd_args()
	print = sys.print

	if cmd and program[cmd] then
		program[cmd](args)
	elseif cmd then
		sys.print("Error: unknown argument")
	else
		program.default()
	end
end

return sys
