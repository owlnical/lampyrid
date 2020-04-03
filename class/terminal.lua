local utf8 = require("utf8")
local class = require "lib/middleclass"
local Terminal = class("Terminal")

function Terminal:initialize(name)
	self.name = name

	-- All previous commands/output merged to a single string
	self.buffer = name

	-- The current input mode
	self.input_enabled = true

	-- History of executed commands
	self.history = {}
	self.history[1] = {
		text        = "",    -- The current command string
		as_executed = ""     -- The string when the command was executed
	}

	-- Set the current command
	-- This changes when the user moves up/down in history
	self.active_command = 1
	self.command = self.history[1]

	-- Style
	self.prefix = "$"
	self.suffix = "█"
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
	self.command.text = self.command.text .. text
end

-- Backspace a character from current command
-- (https://love2d.org/wiki/love.textinput)
function Terminal:backspace()
	local byteoffset = utf8.offset(self.command.text, -1)
	if byteoffset then
		self.command.text = self.command.text:sub(1, byteoffset - 1)
	end
end

function Terminal:clearCommand()
	self.command.text = ""
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

-- Return the current command string
function Terminal:getCommand()
	return self.command.text
end

function Terminal:setCommand()

end

-- add command to history
function Terminal:saveCommand()
	self.history[1] = {
		text = self.command.text,
		as_executed = self.command.text
	}
end

-- Add a new command entry to the top of the history table
-- Set it as the active command
function Terminal:newCommand()
	table.insert(self.history, 1, {text = "", as_executed })
	self:setActiveCommand(1)
end

-- Try to execute the current command string
-- and add it to the history table
function Terminal:execute()
	self:print(self.command.text)
	if self.command.text ~= "" then
		--[[ PARSE AND EXECUTE COMMAND HERE ]]--

		-- If the command is identical to the previous one, just reset the string
		-- otherwise, store it in history and start a new command
		if self.history[2] and (self.command.text == self.history[2].text) then
			self:clearCommand()
		else
			self:saveCommand()
			self:newCommand()
		end
	end
end


--[[
	MISC
--]]

-- Exit terminal/game
function Terminal:exit()
	if self:getCommand() == "" then
		love.event.quit()
	end
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
		self.command.text,
		self.suffix)
	love.graphics.printf(text, 15, 10, 760)
end

return Terminal
