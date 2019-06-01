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

function date.get()
  local now = os.date("%Y-%m-%d %H:%M", os.time())
  local weAre400YearsIntoTheFuture = string.gsub(now, "20", "24", 1)
  write("Current date is: " .. weAre400YearsIntoTheFuture)
end

run("date")