local class = require "lib/middleclass"
local string = require "std/string"
local utf8 = require "utf8"
local Image = require("class/image")
local Terminal = class("Terminal", Image)
local program = love.thread.newThread('-- dummy thread\n')
require "channel"

function Terminal:initialize(text, fontsize, prefix, suffix)
	Image.initialize(self, 0, 0)

	-- All previous output and executed commands in a single string
	self.history = text or ""

	-- Characters before input
	self.prefix = prefix or "$ "

	-- Characters after input
	self.suffix = suffix or "█"

	-- We need max lines to clear the terminal when it's "full"
	self.maxlines = love.graphics.getHeight() / fontsize * 0.78

	-- All commands
	self.command = {{text = ""}}

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

function Terminal:update()
	if output:getCount() > 0 then
		local data = output:pop()
		if data.position == "after input" then
			self:appendHistory(self:getInput() .. data.text)
			input:clear()
		elseif data.position == "before input" then
			self:appendHistory("> " .. data.text)
		end
	end
end

-- Add to current terminal text
function Terminal:appendHistory(text)
	self.history = self.history .. text

	-- Remove top rows when the terminal is "full"
	while select(2, self.history:gsub('\n', '\n')) > self.maxlines do
		local t = string.split(self.history, "\n")
		table.remove(t, 1)
		self.history = table.concat(t, "\n")
	end
end

function Terminal:getContent()
	if program:isRunning() then
		return self.history .. terminal:getInput() .. self.suffix
	else
		return self.history .. self.prefix .. terminal:getInput() .. self.suffix
	end
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

-- Interrupts the current program by releasing the thread
-- Creates a new empty line for a new command
-- text formating differs depending on if a program is running or not
function Terminal:interrupt()
	if program:isRunning() then
		program:release()
		program = love.thread.newThread('-- dummy thread\n')
		self:appendHistory(self:getInput() ..	"^C\n")
	else
		self:appendHistory(self.prefix .. self:getInput() ..	"^C\n")
	end

	self.command[#self.command] = {text = "", original = ""}
	self.current = #self.command
end

-- Exit if the current text/input is empty
function Terminal:exit()
	if self.command[self.current].text == "" then
		love.event.quit()
	end
end

-- Delete the last word in the current text/input
function Terminal:deleteWord()
	local args = string.split(self:getInput())
	table.remove(args, #args)
	self:setInput(table.concat(args, " "))
end

-- Check if terminal

-- Run current input
function Terminal:run()
	if program:isRunning() then
		return
	end
	local command, arg = self:splitInput()
	local path = "programs/" .. command .. ".lua"
	self:appendHistory(self.prefix .. self:getInput() .. "\n")
	if command == "clear" then
		self:clear()
	elseif command == "exit" then
		love.event.quit()
	elseif love.filesystem.getInfo(path) then
			program= love.thread.newThread(path)
			program:start()
			input:push(arg)
	else
		self:appendHistory("Command not found\n")
	end
	self:saveCommand()
	self:newCommand()
end

function Terminal:draw()
	Terminal:drawOverlay(1)
	love.graphics.setColor(1, 1, 1)
	love.graphics.printf(self:getContent(), 20, 20, self.w-50)
end

return Terminal
