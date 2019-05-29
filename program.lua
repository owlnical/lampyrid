local program = {}

function program.run()
  local args = read()
  if program[args[1]] then
    program[args[1]](args)
  else
    program.get()
  end
end

function program.help()
  write(help)
end

return program