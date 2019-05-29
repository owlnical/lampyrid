-- Store data here, which can be requested from anywhere
local cpml = require("lib/cpml")
local channel = love.thread.getChannel("data")
data = {
	-- Navigation
	position = {0, 0, 0},
	destination = {0, 0, 0},
	distance = 0,
	travel_time = 0,
	speed = 10,
	traveling = true,
	eta = 0
}

function data.get(name)
  if data[name] then
    return data[name]
  else
    return false
  end
end

while true do
  command, packet = unpack(channel:demand())
  channel:supply(data[packet])
end