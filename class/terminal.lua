local utf8 = require("utf8")
local class = require "lib/middleclass"
local Terminal = class("Terminal")
local Command = require("class/command")

function Terminal:initialize(name)
	self.name = name

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
	self.command:append(text)
end

function Terminal:backspace()
	self.command:backspace()
end

function Terminal:isEmpty()
	if self.command:isEmpty() then
		return true
	else
		return false
	end
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
		local previous = self.history[2]
		if self.command:get() == previous:getSaved() then
			return true
		end
	else
		return false
	end
end

-- Try to execute the current command string
-- and add it to the history table
function Terminal:execute()
	self:printCommand()
	if not self.command:isEmpty() then
		local commandstring = self.command:get()
		-- Some commands are built in
		for name, cmd in pairs(self.built_in) do
			if commandstring == name then
				cmd(self)
			end
		end
		--[[ PARSE AND EXECUTE COMMAND HERE ]]--

		-- Do not store identical commands in history
		if self:isRepeatedCommand() then
			self.command:restore()
			self:setActiveCommand(1)
			self.command:clear()
		else
			self.command:restore()
			self:setActiveCommand(1)
			self.command:set(commandstring)
			self.command:save()
			self:newCommand()
		end
	else
		self.command:restore()
		self:setActiveCommand(1)
	end
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

function Terminal:setBuffer(text)
	self.buffer = text
end

function Terminal:clearBuffer()
	self.buffer = ""
end

function Terminal:print(text)
	self:printf("%s %s\n", self.prefix, text)
end

function Terminal:printf(text, ...)
	self.buffer = self.buffer .. string.format(text, ...)
end

function Terminal:draw()
	love.graphics.setColor(1, 1, 1)
	local text = string.format("%s%s %s%s",
		self.buffer,
		self.prefix,
		self.command:get(),
		self.suffix)
	love.graphics.printf(text, 15, 10, 760)
end

return Terminal
