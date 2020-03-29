require "channel"
local date = require "program"
help = [[
date (Lampyrid core) 0.1

This program interacts with the ships date coordinates.
Running without a command prints the current date.

  Usage: date <command>

  get                 Get the current date
  help                Show this help
]]

-- Return the real date we started the game + the time we have played
-- Add 400 years
function date.get()
	local time = get("time")
 	local now = os.date("%Y-%m-%d %H:%M", time.played + time.started)
 	write("Current date is: " .. string.gsub(now, "20", "24", 1))
end

run("date")
