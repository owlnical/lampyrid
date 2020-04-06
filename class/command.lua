local utf8 = require "utf8"
local class = require "lib.middleclass"
local Command = class("Command")

function Command:initialize(text, saved)
	self.text = text or ""
	self.saved = saved or ""
end

function Command:append(text)
	self.text = self.text .. text
end

function Command:clear()
	self.text = ""
end

function Command:get()
	return self.text
end

function Command:deleteWord()
	self.text = self.text:gsub("^%w+%s-$",""):gsub("%s+%w+%s-$","",1)
end

function Command:isEmpty()
	if self.text == "" then
		return true
	else
		return false
	end
end

function Command:set(text)
	self.text = text
end

function Command:save(text)
	if self.saved == "" then
		text = text or self.text
		self.saved = self.text
		return true
	else
		return false
	end
end

function Command:restore()
	self.text = self.saved
	return true
end

function Command:getSaved()
	return self.saved
end

-- Backspace a character from current command
-- (https://love2d.org/wiki/love.textinput)
function Command:backspace()
	local byteoffset = utf8.offset(self.text, -1)
	if byteoffset then
		self.text = self.text:sub(1, byteoffset - 1)
	end
end

return Command
