delta = love.thread.getChannel("delta")
system = love.thread.getChannel("system")

function main()
	local ram = load()
	local dt = 0
	while true do
		dt = delta:demand()
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
