local discordia = require('discordia')
local tools = require("discordia-slash").util.tools()
local client = discordia.Client():useApplicationCommands()

local json = require('json')

local secretFile = io.open("secret")
local jsonFile = io.open("data.json")

local controlID = "260155161232670724"

if secretFile == nil or jsonFile == nil then
    error("Missing files.")
end

----------------------------------------------------------------

local database = {
  Accounts = {
    Users = {};
    Hosts = {};
  };
  Events = {};
}

client:on('ready', function()
	print('Logged in as '.. client.user.username)

	local commands = client:getGlobalApplicationCommands()
  for commandId in pairs(commands) do
    client:deleteGlobalApplicationCommand(commandId)
  end

  local logEvent = tools.slashCommand("logevent", "Log current event.")

  local description = tools.string("description", "eg. 'Raid'")
  description = description:setRequired(true)

  local host = tools.string("host", "t")
  host = host:setRequired(true)

  local attendees = tools.string("attendees", "t")
  attendees = attendees:setRequired(true)

  local xp = tools.string("xp", "t")
  xp = xp:setRequired(true)

  local result = tools.string("result", "eg, 'Win'")
  result = result:setRequired(true)

  logEvent = logEvent:addOption(description):addOption(host):addOption(attendees):addOption(xp):addOption(result)

  local attendance = tools.slashCommand("attendance", "Get attendance of user.")
  local user = tools.string("user", "t")
  user:setRequired(true)
  attendance = attendance:addOption(user)

  local hosthistory = tools.slashCommand("hosthistory", "Get host history of user.")
  local user = tools.string("user", "t")
  user:setRequired(true)
  hosthistory = hosthistory:addOption(user)

  local eventhistory = tools.slashCommand("eventhistory", "Get host history.")

  client:createGlobalApplicationCommand(logEvent)
  client:createGlobalApplicationCommand(attendance)
  client:createGlobalApplicationCommand(hosthistory)
  client:createGlobalApplicationCommand(eventhistory)
end)

local function addXP(id, xp, name, date, attendeeCount)
  if database.Accounts.Users[id] == nil then
    database.Accounts.Users[id] = {
      XP = 0;
      Logs = {};
    }
  end
  database.Accounts.Users[id].XP = database.Accounts.Users[id].XP + tonumber(xp)
  table.insert(database.Accounts.Users[id].Logs, "+"..xp.." XP, "..attendeeCount.." attendants, ".." "..name.." @ "..date)
end

local function addHost(id, xp, name, date, attendeeCount, result)
  if database.Accounts.Hosts[id] == nil then
    database.Accounts.Hosts[id] = {}
  end
  local log = "Hosted "..name.." @ "..date.." with "..attendeeCount.." attendants. Rewarded "..xp.." XP to all."
  table.insert(database.Accounts.Hosts[id], log)

  table.insert(database.Events, "<@"..id.."> ".."Hosted "..name.." @ "..date.." with "..attendeeCount.." attendants. Rewarded "..xp.."XP to all.".." Result: "..result)
end

client:on("slashCommand", function(interaction, command, args)
  if command.name == "logevent" then
    local date = os.date("%x")

    local attendees = {}

    for id in args.attendees:gmatch("%d+") do
      table.insert(attendees, id)
    end

    local pingList = ""
    local attendeeCount = #attendees

    for i, v in ipairs(attendees) do
      pingList = pingList.."<@"..v.."> given "..args.xp.." XP\n"
      addXP(v, args.xp, args.description, date, attendeeCount)
    end

    addHost(args.host:match("%d+"), args.xp, args.description, date, attendeeCount, args.result)

    interaction:reply({
			embed = {
				title = "Logged Event '"..args.description.."'",
				description = date,
				fields = {
					{
						name = "Host: ",
						value = args.host,
						inline = true
					},
					{
						name = "Attendees:",
						value = pingList,
						inline = false
					},
          {
						name = "Result: ",
						value = args.result,
						inline = true
					}
				},
				footer = {
					text = "Event Manager"
				},
				color = 0x610000 -- hex color code
			}
		})
  elseif command.name == "attendance" then
    local info = database.Accounts.Users[args.user:match("%d+")]

    local reply = ""

    for i, v in ipairs(info.Logs) do
      reply = reply..tostring(i)..". "..v.." \n"
    end

    interaction:reply({
			embed = {
				title = "Attendance History",
				description = args.user,
        fields = {
          {
            name = "Logs: ",
            value = reply,
            inline = false
          },
          {
            name = "XP: ",
            value = tostring(info.XP),
            inline = true
          }
        },
        footer = {
          text = "Event Manager"
        },
				color = 0x610000 -- hex color code
			}
		})
  elseif command.name == "hosthistory" then
    local info = database.Accounts.Hosts[args.user:match("%d+")]

    local reply = ""

    for i, v in ipairs(info) do
      reply = reply..tostring(i)..". "..v.." \n"
    end

    interaction:reply({
			embed = {
				title = "Host History",
				description = args.user.."\n.."..reply,
				color = 0x610000 -- hex color code
			},
      footer = {
        text = "Event Manager"
      }
		})
  elseif command.name == "eventhistory" then
    local reply = ""

    for i, v in ipairs(database.Events) do
      reply = reply..tostring(i)..". "..v.." \n"
    end

    interaction:reply({
			embed = {
				title = "Logs",
				description = "",
        fields = {
          {
            name = "Logs: ",
            value = reply,
            inline = false
          }
        },
        footer = {
          text = "Event Manager"
        },
				color = 0x610000 -- hex color code
			}
		})
  end
end)


--[[
  /logevent Name Host Players Xp Result
  /attendance plr
  /hosthistory plr
  /eventhistory
  /addhost plr
]]
----------------------------------------------------------------

client:run("Bot "..secretFile:read("*a"))
secretFile:close()