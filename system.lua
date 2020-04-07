system = {
	request = love.thread.getChannel("request"),
	delta = love.thread.getChannel("delta")
}

function main()
	ram = load()
	local dt = 0
	local request

	while true do
		dt = system.delta:demand()
		while system.request:getCount() > 0 do
			request = system.request:pop()
			if system[request[1]] then
				system[request[1]](request)
			else
				system:supply(false)
			end
		end
	end
end

function load()
	--[[ ACTUALLY LOAD GAME ]]--
	local ram = {
		nav = {
			position = {0, 0, 0},
			destination = {0, 0, 0}
		}
	}
	return ram
end

main()
