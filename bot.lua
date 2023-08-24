local discordia = require('discordia')
local client = discordia.Client()

local json = require('json')

local secretFile = io.open("secret")
local jsonFile = io.open("data.json")

local controlID = 260155161232670724

if secretFile == nil or jsonFile == nil then
    error("Missing files.")
end

----------------------------------------------------------------

local database = json.decode(jsonFile:read("*a"))

client:on('ready', function()
	print('Logged in as '.. client.user.username)
end)

----------------------------------------------------------------

client:run("Bot "..secretFile:read("*a"))
secretFile:close()