require "channel"
local engine = require "program"
help = [[
engine (Lampyrid core) 0.1

This program interacts with the ships engine.

  Usage: engine <command>

  status              Show the engine status
  start               Start the engine
  stop                Stop the engine
  help                Show this help
]]

function engine.get()
	local status = get("ship", "engine")
	if get("ship", "engine") then
		write("Engine is running")
	else
		write("The engine is stopped")
	end
end

function engine.stop()
	set("ship", "engine", false)
	write("Engine stopped")
end

function engine.start()
	set("ship", "engine", true)
	write("Engine started")
end

engine.status = engine.get

run("engine")
