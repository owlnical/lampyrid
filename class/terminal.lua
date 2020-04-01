local class = require "lib/middleclass"
local Terminal = class("Terminal")

function Terminal:initialize(name)
	self.name = name

	-- All previous commands/output merged to a single string
	self.buffer = ""

	-- The current input string edited by the user
	self.input = ""

	-- History of executed commands
	self.command = {}
end

--[[
	INPUT
	Methods handling the current input string.
	Erasing/appending characters etc
--]]

function Terminal:appendInput()

end

function Terminal:backspaceInput()

end

function Terminal:clearInput()

end

function Terminal:getInput()

end

function Terminal:setInput()

end


--[[
	BUFFER
	Methods handling the visible text as a whole.
	A single string of the previoius commands, output, input etc
--]]

function Terminal:setBuffer(text)
	self.buffer = text
end

function Terminal:draw()
	love.graphics.setColor(1, 1, 1)
	love.graphics.printf(self.buffer, 20, 20, 760)
end

return Terminal
