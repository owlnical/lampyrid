require "channel"
local uname = require("program")
name = "uname"
help = [[
uname (Lampyrid core) 1.0

This program prints the ships OS kernel.

  Usage: uname

  get                 Print kernel
  show                Alias: get
  help                Show this help
]]

function uname.get()
  write(string.format("Love %s.%s.%s %s", love.getVersion()))
end

uname.show = uname.get

uname.__run()