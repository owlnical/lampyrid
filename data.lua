-- Store data here, which can be requested from anywhere
local cpml = require("lib/cpml")
local channel = love.thread.getChannel("data")
data = {
	-- Navigation
	position = cpml.vec3.new(0, 0, 0),
	destination = cpml.vec3.new(0, 0, 0),
	distance = 0,
	travel_time = 0,
	speed = 10,
	traveling = true,
	eta = 0
}
while true do
  command = channel:demand()
  if command == "getPosition" then
    channel:supply("000")
  else
    channel:supply(false)
  end
end
