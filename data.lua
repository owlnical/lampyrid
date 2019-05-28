-- Store data here, which can be requested from anywhere
local channel = love.thread.getChannel("data")
local data = {
  position = "0 0 0"
}
while true do
  command = channel:demand()
  if command == "getPosition" then
    channel:supply("000")
  else
    channel:supply(false)
  end
end
