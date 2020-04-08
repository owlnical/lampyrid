local sys = {}

function sys.get_args()
	return love.thread.getChannel("args"):demand()
end

function sys.unpack_args()
	return unpack(love.thread.getChannel("args"):demand())
end
	

return sys
