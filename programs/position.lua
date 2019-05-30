require "channel"
local position = require "program"
help = [[
position (Lampyrid core) 0.1

This program interacts with the ships position coordinates.
Running without a command prints the current position.

  Usage: position <command>

  get                 Get the current position
  help                Show this help
]]

function position.get()
  write(string.format("Current position: %s.%s.%s", uget("position")))
end

run("position")