local class = require "lib/middleclass/middleclass"
local string = require "std/string"
local utf8 = require "utf8"
local Terminal = class("Terminal")


function Terminal:initialize(text, prefix, suffix)
	self.command = ""					-- The current (not yet executed) command
	self.current = 1 					-- The currently viewed command
	self.history = {{edited = "", original = ""}}					-- History of command
	self.text = text or ""				-- All previous input/output as a single string
	self.prefix = prefix or "$ "		-- Characters beforce the command
	self.suffix = suffix or "█"			-- Characters after the command
end

function Terminal:getCommand()
	return self.history[self.current].edited
end

function Terminal:setCommand(text)
	self.history[self.current].edited = text
end

function Terminal:appendCommand(text)
	self:setCommand(self:getCommand() .. text)
end

function Terminal:input(text)
	self:setCommand(self:getCommand() .. text)
end

-- Erase UTF-8 characters (https://love2d.org/wiki/love.textinput)
function Terminal:backspace()
	local byteoffset = utf8.offset(self:getCommand(), -1)
	if byteoffset then
		self:setCommand(string.sub(self:getCommand(), 1, byteoffset - 1))
	end
end

-- Move up or down in Terminal history
function Terminal:move(direction)
	if direction == "up" and self.current > 1 then
			self.current = self.current - 1
	elseif direction == "down" and self.current < #self.history then
			self.current = self.current + 1
	end
end

-- Print text to Terminal
function Terminal:print(text)
	self.text = self.text .. text
end

-- Split input string into command and args
function Terminal:split(input)
	local args = string.split(input or self:getCommand())
	local command = args[1]
	self.text = self.text .. self.prefix .. self:getCommand() .. "\n"
	table.remove(args, 1)
	return command, args
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
		self.history[#self.history].original = self:getCommand() 	-- Store the current command as original
		self.history[#self.history].edited = self:getCommand()		-- Store the current command as the edit
		self.history[self.current].edited = self.history[self.current].original -- If we edited an old command. Restore it to original

		-- Start next command
		self.history[#self.history + 1] = {edited = "", original = ""}
		self.current = #self.history
	end
end

return Terminal
