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

function Terminal:backspace()

end

function Terminal:clearCommand()

end

function Terminal:getCommand()

end

function Terminal:setCommand()

end

-- Try to execute the current command string
-- and add it to the history table
function Terminal:executeCommand()

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
	local text = string.format("%s\n%s", self.buffer, self.command.current.text)
	love.graphics.printf(text, 20, 20, 760)
end

return Terminal
