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
  local reply = false
  if data[name] then
    reply = data[name]
  end
  channel:supply(reply)
end

function data.set(name, value)
  local reply = false
  if name and value then
    data[name] = value
    reply = true
  end
  channel:supply(reply)
end

while true do
  local command, name, value = unpack(channel:demand())
  data[command](name, value)
end