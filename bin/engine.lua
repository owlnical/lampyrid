sys = require "bin.lib.sys"
engine = {}

function engine.status()
	local status = sys.get("engine", "engaged")
	local power = sys.get("engine", "power")
	if status then
		print("The engine is running with power:", power)
	else
		print("The engine is stopped")
	end
end

function engine.start()
	sys.set("engine", "engaged", true)
	print("Engine: started")
end

function engine.stop()
	sys.set("engine", "engaged", false)
	print("Engine: stopped")
end

-- short
engine.default = engine.status

-- Run program with generic handler
sys.run_program(engine)
