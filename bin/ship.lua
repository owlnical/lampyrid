require "channel"
local optparse = require "std/optparse"
local help = [[
ship (Lampyrid core) 0.1
Request data from the ships systems

    Usage: ship [<options>]

    Options:

      -h, --help               display help, then exit
      -v, --version            display version, then exit
      -p, --position           print current position
      --                       end of options
    
    ]]


local parser = optparse(help)
local arg, opt = parser:parse(read())
local output

if opt.help == true then
	output = parser.helptext
elseif opt.version == true then
	output = parser.versiontext
elseif opt.position == true then
	output = "Current position: " .. request("getPosition")
else
	output = "Unknow command. See ship -h for help"
end

write(output)
