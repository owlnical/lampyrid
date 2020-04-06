local class = require "lib.middleclass"
local Command = require "class.command"
local Terminal = class("Terminal")

function Terminal:initialize(name, max_lines)
	self.name = name
	self.max_lines = max_lines

	-- All previous commands/output merged to a single string
	-- does not include the current command
	self.buffer = name

	-- The current input mode
	self.input_enabled = true

	-- History of executed commands, higher is older
	self.history = {}
	self.history[1] = Command:new()	

	-- The active command is currently the newest command
	-- this will change when the user moved up/back in history
	self.active_command = 1
	self.command = self.history[1]

	-- Style
	self.prefix = "$"
	self.suffix = "█"

	-- Some commands are built in
	self.built_in = {
		clear = self.clearBuffer,
		exit = self.exit
	}

	-- program thread and channels
	self.program = love.thread.newThread("--\n")
	self.channel = {
		args = love.thread.getChannel("args"),
		output = love.thread.getChannel("output")
	}

end


--[[
	INPUT AND COMMANDS
	Methods handling the current input string.
	Erasing/appending characters etc
--]]

function Terminal:readInput(text)
	if self.input_enabled then
		self:appendInput(text)
	end
end

function Terminal:appendInput(text)
	if self.program:isRunning() then
		self:printf(text)
	else
		self.command:append(text)
	end
end

function Terminal:backspace()
	self.command:backspace()
end

function Terminal:deleteWord()
	self.command:deleteWord()
end

function Terminal:isEmpty()
	return self.command:isEmpty()
end

-- Change active command to the specified id
function Terminal:setActiveCommand(id)
	if self.history[id] then
		self.active_command = id
		self.command = self.history[id]
	end
end

-- Move backward in command history
function Terminal:up()
	self:setActiveCommand(self.active_command + 1)
end

-- Move forward in command history
function Terminal:down()
	self:setActiveCommand(self.active_command - 1)
end

-- Print the command to the buffer
function Terminal:printCommand()
	self:print(self.command:get())
end

-- Add a new command entry to the top of the history table
-- Set it as the active command
function Terminal:newCommand()
	table.insert(self.history, 1, Command:new())
	self:setActiveCommand(1)
end

-- Interrupt the current command
function Terminal:interrupt()
	--[[ INTERRUPT RUNNING COMMAND HERE ]]--
	self:printf("%s %s^C\n", self.prefix, self.command:get())
	self.command:clear()
end

-- Return true if the previoius command is identical to the current command
function Terminal:isRepeatedCommand()
	if self.history[2] then
		return self.history[1]:get() == self.history[2]:getSaved()
	end
	return false
end

-- Try to execute the current command string
-- and add it to the history table
function Terminal:execute()
	if self.program:isRunning() then
		self:printf("\n")
		return
	end
	self:printCommand()

	-- Any old commands need to be restored to their original value
	if self.active_command > 1 then
		self.history[1]:set(self.command:get())
		self.command:restore()
		self:setActiveCommand(1)
	end

	if self.command:notEmpty() then
		-- The bin/file we want to execute and the arguments
		local bin, args = self.command:getArgs()

		-- Some basic commnads are built in functions (exit, clear etc)
		for name, func in pairs(self.built_in) do
			if bin == name then
				func(self)
			end
		end

		-- start new thread with lua files in the bin directory
		local path = "bin/" .. bin .. ".lua"
		if love.filesystem.getInfo(path) then
			self.program = love.thread.newThread(path)
			self.channel.args:clear()
			self.channel.args:push(args)
			self.program:start()
		end

		-- Store the command in the latest object unless it's repeated
		if not self:isRepeatedCommand() then
			self.command:save()
			self:newCommand()
		end
	end

	self.command:clear()
end


--[[
	MISC
--]]

-- Exit terminal/game
function Terminal:exit()
	love.event.quit()
end

--[[
	BUFFER
	Methods handling the visible text as a whole.
	A single string of the previoius commands, output, input etc
--]]

function Terminal:clearBuffer()
	self.buffer = ""
end

function Terminal:print(text)
	self:printf("%s %s\n", self.prefix, text)
end

function Terminal:printf(text, ...)
	self.buffer = self.buffer .. string.format(text, ...)
	self:clean()
end

-- There's only so much room in our terminal
-- so we remove the oldest line, from the start of the string
function Terminal:clean()
	while select(2, self.buffer:gsub('\n', '\n')) > self.max_lines do
		self.buffer = self.buffer:gsub("^.-\n", "", 1)
	end
end

function Terminal:draw()
	love.graphics.setColor(1, 1, 1)
	local text
	if self.program:isRunning() then
		text = self.buffer .. self.suffix
	else
		text = string.format("%s%s %s%s",
			self.buffer,
			self.prefix,
			self.command:get(),
			self.suffix)
	end
	love.graphics.printf(text, 15, 10, 760)
end

function Terminal:update()
	while self.channel.output:getCount() > 0 do
		self:printf(self.channel.output:pop())
	end
end

return Terminal
