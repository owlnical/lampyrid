local class = require "lib/middleclass/middleclass"
local string = require "std/string"
local utf8 = require "utf8"
local Terminal = class("Terminal")


function Terminal:initialize(text, prefix, suffix)
	-- All previous output and executed commands in a single string
	self.history = text or ""

	-- Characters before input
	self.prefix = prefix or "$ "

	-- Characters after input
	self.suffix = suffix or "█"

	-- All commands
	self.command = {}

	self.command[1] = {
		edited = ""
	}

	-- The currently viewed command
	self.current = 1
end

-- Return the text currently showed in the terminal
function Terminal:getCommand()
	return self.command[self.current].edited
end

-- Set the text currently showed in the terminal
function Terminal:setCommand(text)
	self.command[self.current].edited = text
end

-- Append text to the text currently showed in the terminal
function Terminal:appendCommand(text)
	self:setCommand(self:getCommand() .. text)
end

-- Set the terminal history
function Terminal:setHistory(text)
	self.history = text
end

-- Get the terminal history
function Terminal:getHistory(text)
	return self.history
end

function Terminal:appendHistory(text)
	self.history = self.history .. text
end

function Terminal:getContent()
	return self.history .. self.prefix .. terminal:getCommand() .. self.suffix
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
	elseif direction == "down" and self.current < #self.command then
			self.current = self.current + 1
	end
end

-- Print text to Terminal
function Terminal:print(text)
	self.history = self.history .. text
end

-- Split input string into command and args
function Terminal:split(input)
	local args = string.split(input or self:getCommand())
	local command = args[1]
	table.remove(args, 1)
	return command, args
end

-- Add the current command to the history
function Terminal:saveCommand()
	self.command[#self.command].original = self:getCommand()
	self.command[#self.command].edited = self:getCommand()

	--[[
		If this was a partially edited previous command
		Restore it to it's original string.
	--]]
	if self.current < #self.command then
		self.command[self.current].edited = self.command[self.current].original
	end
end

-- Add a new command to the bottom of the history table
function Terminal:newCommand()
	self.command[#self.command + 1] = {edited = "", original = ""}
	self.current = #self.command
end

-- Run current input
function Terminal:run()
	local command, arg = self:split()
	self:appendHistory(self.prefix .. self:getCommand() .. "\n")
	if command ~= "" then
		if false then
			-- find commands
		else
			self:print("Command not found\n")
		end
		self:saveCommand()
		self:newCommand()
	end
end

return Terminal
