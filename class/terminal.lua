local class = require "lib/middleclass/middleclass"
local string = require "std/string"
local utf8 = require "utf8"
local Terminal = class("Terminal")


function Terminal:initialize(text, prefix, suffix)
	self.text = text or ""
	self.prefix = prefix or "$ "
	self.suffix = suffix or "█"
	self.input = ""
	self.history = {""}
	self.current = 1
end

-- Erase UTF-8 characters (https://love2d.org/wiki/love.textinput)
function Terminal:backspace()
	local byteoffset = utf8.offset(self.input, -1)
	if byteoffset then
		self.input = string.sub(self.input, 1, byteoffset - 1)
	end
end

-- Move up or down in Terminal history
function Terminal:move(direction)
	self.history[self.current] = self.input
	if direction == "up" and self.current > 1 then
			self.current = self.current - 1
	elseif direction == "down" and self.current < #self.history then
			self.current = self.current + 1
	end
	self.input = "" .. self.history[self.current]
end

-- Print text to Terminal
function Terminal:print(text)
	self.text = self.text .. text
end

-- Split input string into command and args
function Terminal:split(input)
	local args = string.split(input or self.input)
	local command = args[1]
	self.text = self.text .. self.prefix .. self.input .. "\n"
	table.remove(args, 1)
	return command, args
end

-- Add current input to history and and clear input
function Terminal:commandToHistory()
	self.history[#self.history] = self.input
	self.history[#self.history + 1] = ""
	self.input = ""
	self.current = #self.history
end

-- Run current input
function Terminal:run()
	local command, arg = self:split()
	if command ~= "" then
		if false then
			-- find commands
		else
			self:print("Command not found\n")
		end
		self:commandToHistory()
	end
end

return Terminal
