local cpml = require "lib.cpml"
channel = {
	system = love.thread.getChannel("system"),
	delta = love.thread.getChannel("delta"),
	output = love.thread.getChannel("output")
}
system = {}

function main()
	ram, nav, engine = load()
	local dt = 0
	local request

	while true do
		-- move ship depending on framerate
		dt = channel.delta:demand()
		if engine.engaged then
			nav.position = update_position(dt)
		end

		-- Match requests no func in the system table
		-- e.g. { "get", "nav", "position" }
		while channel.system:getCount() > 0 do
			request = channel.system:pop()
			if system[request[1]] then
				system[request[1]](request)
			else
				channel.system:supply(false)
			end
		end
	end
end

-- Restore game state from file
function load()
	--[[ ACTUALLY LOAD GAME ]]--
	-- Hardcoded test data
	local ram = {
		nav = {
			position = {0, 0, 0},
			destination = {100, 100, 100}
		},
		engine = {
			engaged = true,
			power = 100
		}
	}
	return ram, ram.nav, ram.engine
end

-- push requested data from ram to the system channel
function system.get(request)
	local _, t, k = unpack(request)
	channel.system:supply(ram[t][k])
end

-- set ram value from request
function system.set(request)
	local _, t, k, v = unpack(request)
	ram[t][k] = v
end

function system.stop_engine()
	ram.engine.engaged = false
end

-- Return position depending on destination and engine power
function update_position(dt)
	local dest = cpml.vec3.new(nav.destination)
	local pos = cpml.vec3.new(nav.position)
	local dist = pos:dist(dest)

	if dist > 1 then
		local step = (dist / (dist - (dt * (engine.power / 100)))) - 1 -- It works, dunno how
		pos = cpml.vec3.lerp(pos, dest, step)
	else
		pos = dest
		system.stop_engine()
	end

	return {cpml.vec3.unpack(pos)}
end

main()
