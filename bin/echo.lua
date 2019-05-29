require "channel"
local echo = {}

function echo.help()
  write([[
echo (Lampyrid core) 1.0

This program prints all arguments

  Usage: echo <string> <string>...

  help                Show this help
  ]])
end

local args = read()
if echo[args[1]] then
  echo[args[1]](args)
else
  write(table.concat(args, " "))
end