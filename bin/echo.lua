require "channel"
local optparse = require "std/optparse"
local help = [[
echo (Lampyrid core) 0.1

This test program comes with ABSOLUTELY NO WARRANTY.

    Usage: echo [<options>] <string>...

    Options:

      -h, --help               display help, then exit
          --version            display version, then exit
      --                       end of options
    
    ]]


local parser = optparse(help)
local arg, opt = parser:parse(read())
local output

if opt.help == true then
	output = parser.helptext
elseif opt.version == true then
	output = parser.versiontext
else
	output = table.concat(arg, " ")
end
--los.print(output)
write(output)
