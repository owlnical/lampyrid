local love = require "love"
require "channel"
major, minor, revision, codename = love.getVersion( )
write("Love " .. codename .. " " .. major .. "." .. minor)