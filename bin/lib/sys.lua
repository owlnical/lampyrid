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

return sys
