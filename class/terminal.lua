local class = require "lib/middleclass/middleclass"
local string = require "std/string"
local utf8 = require "utf8"
local Terminal = class("Terminal")


function Terminal:initialize(text, prefix, suffix)
	self.command = ""					-- The current (not yet executed) command
	self.history = {					-- History of commands
		view = 1, 						-- The currently viewed command
		""								-- The history for the first command is yet to be filled
	}	
	self.text = text or ""				-- All previous input/output as a single string
	self.prefix = prefix or "$ "		-- Characters beforce the command
	self.suffix = suffix or "█"			-- Characters after the command
end

-- Erase UTF-8 characters (https://love2d.org/wiki/love.textinput)
function Terminal:backspace()
	local byteoffset = utf8.offset(self.command, -1)
	if byteoffset then
		self.command = string.sub(self.command, 1, byteoffset - 1)
	end
end

-- Move up or down in Terminal history
function Terminal:move(direction)
	self.history[self.history.view] = self.command
	if direction == "up" and self.history.view > 1 then
			self.history.view = self.history.view - 1
	elseif direction == "down" and self.history.view < #self.history then
			self.history.view = self.history.view + 1
	end
	self.command = "" .. self.history[self.history.view]
end

-- Print text to Terminal
function Terminal:print(text)
	self.text = self.text .. text
end

-- Split input string into command and args
function Terminal:split(input)
	local args = string.split(input or self.command)
	local command = args[1]
	self.text = self.text .. self.prefix .. self.command .. "\n"
	table.remove(args, 1)
	return command, args
end

-- Add current input to history and and clear input
function Terminal:commandToHistory()
	self.history[#self.history] = self.command
	self.history[#self.history + 1] = ""
	self.command = ""
	self.history.view = #self.history
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
