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
	self.command = {
		history = {
			{ text = "" }
		}
	}

	-- The command currentl being edited
	self.command.current = self.command.history[1]

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
	self.command.current.text = self.command.current.text .. text
end

-- Backspace a character from current command
-- (https://love2d.org/wiki/love.textinput)
function Terminal:backspace()
	local command = self.command.current
	local byteoffset = utf8.offset(command.text, -1)
	if byteoffset then
		command.text = command.text:sub(1, byteoffset - 1)
	end
end

function Terminal:clearCommand()

end

-- Return the current command string
function Terminal:getCommand()
	return self.command.current.text
end

function Terminal:setCommand()

end

-- Try to execute the current command string
-- and add it to the history table
function Terminal:executeCommand()

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

function Terminal:appendBuffer(text)
	self.buffer = self.buffer .. text
end

function Terminal:draw()
	love.graphics.setColor(1, 1, 1)
	local text = string.format("%s%s %s%s",
		self.buffer,
		self.prefix,
		self.command.current.text,
		self.suffix)
	love.graphics.printf(text, 15, 10, 760)
end

return Terminal
