local class = require "lib/middleclass"
local string = require "std/string"
local utf8 = require "utf8"
require "channel"
local Terminal = class("Terminal")

function Terminal:initialize(text, fontsize, prefix, suffix)
	-- All previous output and executed commands in a single string
	self.history = text or ""

	-- Characters before input
	self.prefix = prefix or "$ "

	-- Characters after input
	self.suffix = suffix or "█"

  -- We need max lines to clear the terminal when it's "full"
  self.maxlines = love.graphics.getHeight() / fontsize * 0.75

	-- All commands
	self.command = {}

	self.command[1] = {
		text = ""
	}

	-- The currently viewed command
	self.current = 1
end

-- Return the text currently showed in the terminal
function Terminal:getInput()
	return self.command[self.current].text
end

-- Set the text currently showed in the terminal
function Terminal:setInput(text)
	self.command[self.current].text = text
end

-- Append text to the text currently showed in the terminal
function Terminal:appendInput(text)
	self:setInput(self:getInput() .. text)
end

-- Set the terminal history
function Terminal:setHistory(text)
	self.history = text
end

-- Get the terminal history
function Terminal:getHistory(text)
	return self.history
end

-- Add to current terminal text
-- Remove top rows when the terminal is "full"
function Terminal:appendHistory(text)
  if select(2, self.history:gsub('\n', '\n')) > self.maxlines then
    local t = string.split(self.history, "\n")
    table.remove(t, 1)
    self.history = table.concat(t, "\n")
  end

	self.history = self.history .. text
end

function Terminal:getContent()
	return self.history .. self.prefix .. terminal:getInput() .. self.suffix
end

function Terminal:clear()
  self.history = ""
end

-- Erase UTF-8 characters (https://love2d.org/wiki/love.textinput)
function Terminal:backspace()
	local byteoffset = utf8.offset(self:getInput(), -1)
	if byteoffset then
		self:setInput(string.sub(self:getInput(), 1, byteoffset - 1))
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

-- Split input string into command and args
function Terminal:splitInput(text)
	local args = string.split(text or self:getInput())
	local command = args[1]
	table.remove(args, 1)
	return command, args
end

-- Add the current command to the history
function Terminal:saveCommand()
	self.command[#self.command].original = self:getInput()
	self.command[#self.command].text = self:getInput()

	--[[
		If this was a partially text previous command
		Restore it to it's original string.
	--]]
	if self.current < #self.command then
		self.command[self.current].text = self.command[self.current].original
	end
end

-- Add a new command to the bottom of the history table
function Terminal:newCommand()
	self.command[#self.command + 1] = {text = "", original = ""}
	self.current = #self.command
end

-- Abort the current command
-- Clears all text/input from the current row
function Terminal:abort()
	self.command[#self.command] = {text = "", original = ""}
	self.current = #self.command
end

-- Run current input
function Terminal:run()
	local command, arg = self:splitInput()
  local bin = "bin/" .. command .. ".lua"
	self:appendHistory(self.prefix .. self:getInput() .. "\n")
  if command == "clear" then
    self:clear()
  elseif command == "exit" then
    love.event.quit()
	elseif love.filesystem.getInfo(bin) then
      thread = love.thread.newThread(bin)
      thread:start()
      channel.input:push(arg)
      self:appendHistory(channel.output:demand())
      channel.input:clear()
	else
    self:appendHistory("Command not found\n")
	end
  self:saveCommand()
  self:newCommand()
end

return Terminal
