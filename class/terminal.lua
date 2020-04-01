local class = require "lib/middleclass"
local Terminal = class("Terminal")

function Terminal:initialize(name)
	self.name = name

	-- All previous commands/output merged to a single string
	self.text = ""

	-- The current input string edited by the user
	self.input = ""

	-- History of executed commands
	self.command = {}
end

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

function Terminal:draw()

end

return Terminal
