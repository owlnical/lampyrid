local program = {}

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

function program.help()
  write(help)
end

return program