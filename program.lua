-- Shared library for all programs
local program = {}

-- run the program function which matches the first arg
-- fallback to function get() if it exists. Otherwise print error
function program.__run()
  local args = read()
  if program[args[1]] then
    program[args[1]](args)
  elseif program.get and not args[1] then
    program.get()
  else
    write("Error: unknown argument. Try " .. name .. " help.")
  end
end

-- This requires that help is a global in the program
function program.help()
  write(help)
end

return program