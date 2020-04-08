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

function sys.uget(t, k)
	return unpack(sys.get(t, k))
end

return sys