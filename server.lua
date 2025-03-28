local inDuty = {} 
local tags = {}
local dutyTimes = json.decode(LoadResourceFile(GetCurrentResourceName(), "data.json")) or {}
local useOkokChat = GetResourceState('okokChat') == 'started'
local isAdminLoggingEnabled = Config.ChatLogs

function GetAdmins()
    local admins = {}
    for _, playerId in ipairs(ESX.GetPlayers()) do
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer and IsAdmin(xPlayer.getGroup()) then
            table.insert(admins, xPlayer.source)
        end
    end
    return admins
end


local function sendAdminLog(admin, title, message, target)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or not inDuty[xPlayer.source] then return end
    if not isAdminLoggingEnabled then return end
    local background = 'linear-gradient(90deg, rgba(42, 42, 42, 0.9) 0%, rgba(53, 219, 194, 0.9) 100%)'
    local color = '#35dbc2'
    local icon = 'fa-solid fa-hammer'
    local playername = " "..GetPlayerName(admin).. " ["..admin.."]" or " Ismeretlen Admin"
    local admins = GetAdmins()
    for _, adminId in ipairs(admins) do
        if useOkokChat then
            TriggerEvent('okokChat:ServerMessage', background, color, icon, title, playername, message, adminId, " ")
        else
            TriggerClientEvent('chat:addMessage', adminId, {
                color = {0, 255, 0},
                multiline = true,
                args = {"[Admin Log] " .. title, message}
            })
        end
    end
end

RegisterNetEvent('villamos_aduty:sendlog')
AddEventHandler('villamos_aduty:sendlog', function(uzi)
    if not isAdminLoggingEnabled then return end

    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local group = Config.DiscordTags and GetDiscordRole(xPlayer.source) or xPlayer.getGroup()

        if not group or not Config.Admins[group] then 
            return Config.Notify(xPlayer.source, "Nincs jogosultságod ehhez a logoláshoz!")
        end 

        sendAdminLog(source, "Admin Log", uzi, -1) 
    end
end)

lib.callback.register('villamos_aduty:getAllJobs', function(source)
    local players = ESX.GetPlayers()
    local jobs = {}

    for _, playerId in ipairs(players) do
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer then
            local jobName = xPlayer.job.label .. " - " .. xPlayer.job.grade_label
            table.insert(jobs, {id = playerId, job = jobName}) 
        end
    end

    return jobs
end)


ESX.RegisterServerCallback("villamos_aduty:openPanel", function(source, cb)
    local xAdmin = ESX.GetPlayerFromId(source)
    if not IsAdmin(xAdmin.getGroup()) then return cb(false) end
    local players = {}
    local play = ESX.GetPlayers()
    for i=1, #play do
        local xPlayer = ESX.GetPlayerFromId(play[i])
        
        if xPlayer then 
            players[#players+1] = {
                id = xPlayer.source,
                name = GetPlayerName(xPlayer.source),
                group = xPlayer.getGroup(),
                job = xPlayer.getJob().label .. " - " .. xPlayer.getJob().grade_label,
                Penz = xPlayer.getMoney(),
                bank = xPlayer.getAccount("bank").money
            }
        end 
    end

    cb(true, xAdmin.getGroup(), players)
end)

RegisterNetEvent('villamos_aduty:setTag', function(enable)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not inDuty[xPlayer.source] then return end 

    tags[xPlayer.source] = enable and inDuty[xPlayer.source].tag or nil
    TriggerClientEvent("villamos_aduty:sendData", -1, tags)
end)

RegisterNetEvent('villamos_aduty:setDutya', function(enable)
    local xPlayer = ESX.GetPlayerFromId(source)
    if inDuty[xPlayer.source] then 
        TriggerClientEvent("villamos_aduty:setDuty", xPlayer.source, false, inDuty[xPlayer.source].group)
        local group = Config.DiscordTags and GetDiscordRole(xPlayer.source) or xPlayer.getGroup()
        if tags[xPlayer.source] then 
            tags[xPlayer.source] = nil
            TriggerClientEvent("villamos_aduty:sendData", -1, tags)
        end 
        local dutyMinutes = math.floor((os.time() - inDuty[xPlayer.source].start) / 60)
        inDuty[xPlayer.source] = nil
        TriggerEvent("villamos_aduty:sendlog", Config.Admins[group].tag .." ".._U("went_offduty", GetPlayerName(xPlayer.source)))
        Config.Notify(-1, Config.Admins[group].tag .." ".._U("went_offduty", GetPlayerName(xPlayer.source)))



        dutyTimes[xPlayer.identifier] = (dutyTimes[xPlayer.identifier] or 0) + dutyMinutes
        SaveResourceFile(GetCurrentResourceName(), "data.json", json.encode(dutyTimes), -1)
        LogToDiscord(GetPlayerName(xPlayer.source), false, FormatMinutes(dutyTimes[xPlayer.identifier] or 0), FormatMinutes(dutyMinutes))
    else 
        local group = Config.DiscordTags and GetDiscordRole(xPlayer.source) or xPlayer.getGroup()

        if not group or not Config.Admins[group] then return Config.Notify(xPlayer.source, _U("cant_duty")) end 

        inDuty[xPlayer.source] = {
            ped = Config.Admins[group].ped,
            tag = { label = Config.Admins[group].tag .. "~w~ | " .. GetPlayerName(xPlayer.source), color = Config.Admins[group].color, logo = Config.Admins[group].logo },
            group = group,
            start = os.time()
        }
        TriggerClientEvent("villamos_aduty:setDuty", xPlayer.source, true, group)
        Config.Notify(-1, Config.Admins[group].tag .." ".._U("went_onduty", GetPlayerName(xPlayer.source)))
        TriggerEvent("villamos_aduty:sendlog", Config.Admins[group].tag .." ".._U("went_onduty", GetPlayerName(xPlayer.source)))


        tags[xPlayer.source] = inDuty[xPlayer.source].tag
        TriggerClientEvent("villamos_aduty:sendData", -1, tags)

        LogToDiscord(GetPlayerName(xPlayer.source), true, FormatMinutes((dutyTimes[xPlayer.identifier] or 0))) 
    end 
end)

AddEventHandler('playerDropped', function(reason)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or not inDuty[xPlayer.source] then return end
    if tags[xPlayer.source] then 
        tags[xPlayer.source] = nil
        TriggerClientEvent("villamos_aduty:sendData", -1, tags)
    end 
    local dutyMinutes = math.floor((os.time() - inDuty[xPlayer.source].start) / 60)
    inDuty[xPlayer.source] = nil
    Config.Notify(-1, _U("went_offduty", GetPlayerName(xPlayer.source)))

    dutyTimes[xPlayer.identifier] = (dutyTimes[xPlayer.identifier] or 0) + dutyMinutes
    SaveResourceFile(GetCurrentResourceName(), "data.json", json.encode(dutyTimes), -1)
    LogToDiscord(GetPlayerName(xPlayer.source), false, FormatMinutes(dutyTimes[xPlayer.identifier] or 0), FormatMinutes(dutyMinutes))
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData)
    TriggerClientEvent("villamos_aduty:sendData", source, tags)
end)

function LogToDiscord(name, duty, alltime, time)
    if not Config.Webhook then return end 
    local connect = {
        {
            ["color"] = (duty and 27946 or 10616832),
            ["title"] = "**".. name .."**",
            ["description"] = (duty and _U("went_onduty", name) or _U("went_offduty", name)),
            ["fields"] = {
                {
                    ["name"] = _U("alltime"),
                    ["value"] = alltime,
                    ["inline"] = true
                },
                {
                    ["name"] = _U("dutytime"),
                    ["value"] = time or "-",
                    ["inline"] = true
                },
            },
            ["author"] = {
                ["name"] = "Marvel Studios",
                ["url"] = "https://discord.gg/esnawXn5q5",
                ["icon_url"] = "https://cdn.discordapp.com/attachments/917181033626087454/954753156821188658/marvel1.png"
            },
            ["footer"] = {
                ["text"] = os.date("%Y-%m-%d %X").." | villamos_aduty :)",
            },
        }
    }
    PerformHttpRequest(Config.Webhook, function(err, text, headers) end, 'POST', json.encode({embeds = connect}), { ['Content-Type'] = 'application/json' })
end

function FormatMinutes(m)
    local minutes = m % 60
	local hours = math.floor((m - minutes) / 60)
	return hours.." h "..minutes.." m"
end

function IsAdmin(group)
    for i=1, #Config.Perms do 
        if Config.Perms[i] == group then 
            return true 
        end 
    end 

    return false
end 

function GetPlayerDiscord(src)
    local identifiers = GetPlayerIdentifiers(src)

    for i=1, #identifiers do
        if string.find(identifiers[i], 'discord:') then
            return string.sub(identifiers[i], 9)
        end
    end

    return nil
end
function GetDiscordRole(src)
    local api = Config.DiscordTimeOut
    local discordId = GetPlayerDiscord(src)
    local info

    if not discordId then return nil end 

    PerformHttpRequest("https://discordapp.com/api/guilds/" .. Config.GuildId .. "/members/" .. discordId, function(errorCode, resultData, resultHeaders)
        api = 0
        if not resultData then return end 
        local roles = json.decode(resultData).roles
        for v=1, #roles do 
            for role, _ in pairs(Config.Admins) do
                if roles[v] == role then
                    info = role
                    break
                end
            end
        end
    end, "GET", "", {["Content-Type"] = "application/json", ["Authorization"] = "Bot " .. Config.BotToken})

    while api > 0 do 
        Wait(100)
        api = api - 100
    end 

    return info
end 

exports('GetDutys', function()
    return inDuty
end)

exports('IsInDuty', function(src) 
    return inDuty[src] and true or false
end)

RegisterCommand('adlog', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then 
        local group = Config.DiscordTags and GetDiscordRole(xPlayer.source) or xPlayer.getGroup()

        if not group or not Config.Admins[group] then return Config.Notify(xPlayer.source, _U("cant_duty")) end 
    
        isAdminLoggingEnabled = not isAdminLoggingEnabled
    end
end, false)


-- Spectate triggerek
RegisterNetEvent('villamos_aduty:sendcoord')
AddEventHandler('villamos_aduty:sendcoord', function(targetServerId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    local group = Config.DiscordTags and GetDiscordRole(xPlayer.source) or xPlayer.getGroup()
    if not group or not Config.Admins[group] then return Config.Notify(xPlayer.source, _U("cant_duty")) end 

    local xTarget = ESX.GetPlayerFromId(targetServerId)
    if xTarget then
        local targetPed = GetPlayerPed(xTarget.source)
        local coord = GetEntityCoords(targetPed)
        TriggerClientEvent('villamos_aduty:getcoords', source, coord)
    else
    end
end)

RegisterNetEvent("villamos_aduty:kick")
AddEventHandler("villamos_aduty:kick", function(targetServerId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or not inDuty[xPlayer.source] then return Config.Notify(xPlayer.source, _U("no_perm")) end
    DropPlayer(targetServerId, "Egy Adminisztrátor ki kickelt!")
    --print("kicked" .. targetServerId)
end)

RegisterNetEvent("villamos_aduty:goto")
AddEventHandler("villamos_aduty:goto", function(targetServerId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(targetServerId)
    if not xPlayer or not xTarget or not inDuty[xPlayer.source] then return Config.Notify(xPlayer.source, _U("no_perm")) end
    local coords = xTarget.getCoords(true)
    xPlayer.setCoords(coords)
end)

RegisterNetEvent("villamos_aduty:bring")
AddEventHandler("villamos_aduty:bring", function(targetServerId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(targetServerId)
    if not xPlayer or not xTarget or not inDuty[xPlayer.source] then return Config.Notify(xPlayer.source, _U("no_perm")) end
    local coords = xPlayer.getCoords(true)
    xTarget.setCoords(coords)
end)