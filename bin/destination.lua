require "channel"

local destination = {}

function destination.help()
  write([[
destination (Lampyrid core) 0.1

This program interacts with the ships destination coordinates

  Usage: destination <command> [options]

  set <x> <y> <z>     Set a new destination
  get                 Get the current destination
  eta                 Get the estimated time of arrival
  help                Show this help
  ]])
end

function destination.get()
  write(string.format("Current destination: %s.%s.%s", uget("destination")))
end

function destination.eta()
  write(string.format("ETA: %s minutes", get("eta")))
end

function destination.set(args)
  local command, x, y, z = unpack(args)
  x = tonumber(x)
  y = tonumber(y)
  z = tonumber(z)
  if x and y and z then
    set("destination", {x, y, z})
    write(string.format("Destination set to %s.%s.%s", x, y, z))
  else
    write("Unable to set destination. Try destination help")
  end
end

local args = read()

if destination[args[1]] then
  destination[args[1]](args)
else
  write("Unknown command. Try destination help")
end  