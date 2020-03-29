require "channel"
local helper = require "program"
help = [[
help (Lampyrid core) 1.0

This program show which commands/programs are available

  Usage: help

  get                 Show program (default argument)
  help                Show this help
]]

local programs = [[
date            Print current date
destination     set and/or set ship destination
echo            Print text
engine          Interact with the ships engine
exit            Exit the ships terminal without prompt
help            Print this help message
position        Print the ships current position
sensor          Scan for nearby planets
sleep           Sleep <x> seconds
uname           Print the system kernel

See additional help by passing the argument help to programs]]

-- Override standard run()
function helper.get()
	write(programs)
end

run("help")
