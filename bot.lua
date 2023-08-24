local discordia = require('discordia')
local client = discordia.Client()

local secretFile = io.open("secret")

if secretFile == nil then
    error("No secret file.")
end

client:on('ready', function()
	print('Logged in as '.. client.user.username)
end)

client:on('messageCreate', function(message)
	if message.content == '!ping' then
		message.channel:send('pong!')
	end
end)

client:run("Bot "..secretFile:read("*a"))