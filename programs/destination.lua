require "channel"
local destination = require "program"
help = [[
destination (Lampyrid core) 1.0

This program interacts with the ships destination coordinates

  Usage: destination <command> [options]

  set <x> <y> <z>     Set a new destination
  get                 Get the current destination
  eta                 Get the estimated time of arrival
  distance            Get the distance to the destination
  help                Show this help
]]

function destination.get()
  write(string.format("Current destination: %s.%s.%s", uget("destination")))
end

function destination.eta()
  write(string.format("ETA: %s minutes", get("eta")))
end

function destination.distance()
  write(string.format("Distance to destination: %s", get("distance")))
end

function destination.set(x, y, z)
  x = tonumber(x)
  y = tonumber(y)
  z = tonumber(z)
  if x and y and z then
    -- Here we go!
    set("destination", {x, y, z})
    set("traveling", true)
    write(string.format("Destination set to %s.%s.%s", x, y, z))

    -- Trigger calculation and output data
    channel.data:supply({"travel", 0.01})
    write(string.format("Distance to destination: %s", get("distance")))
    write(string.format("ETA: %s minutes", get("eta")))
  else
    write("Unable to set destination. Try destination help")
  end
end

run("destination")