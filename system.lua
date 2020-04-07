function main()
	local ram = load()
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
