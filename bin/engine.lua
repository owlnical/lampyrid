system = love.thread.getChannel("system")
local sys = require "bin.lib.sys"
local engine = {}

function main()
	print = sys.print
	local cmd, args = sys.get_cmd_args()
	if cmd and engine[cmd] then
		engine[cmd](args)
	elseif cmd then
		print("engine: unknown argument")
	else
		engine.default()
	end
end

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
	print("Engine: stopeed")
end

-- short
engine.default = engine.status

main()
