require "channel"
local echo = require "program"
name = "echo"
help = [[
echo (Lampyrid core) 1.0

This program prints all arguments

  Usage: echo <string> <string>...

  help                Show this help
]]

-- Override standard run()
function echo.run()
  local args = read()
  if echo[args[1]] then
    echo[args[1]](args)
  else
    write(table.concat(args, " "))
  end
end

echo.run()