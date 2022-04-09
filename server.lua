local inDuty = {} 
local tags = {}
local dutyTimes = json.decode(LoadResourceFile(GetCurrentResourceName(), "data.json"))
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function GetPlayerDiscord(playId)
    local identifiers = GetPlayerIdentifiers(playId)

    local discord = nil

    for _, identifier in pairs(identifiers) do
        if (string.match(string.lower(identifier), 'discord:')) then
            discord = string.sub(identifier, 9)
        end
    end

    return discord
end
function GetDiscordRole(src)
    local api = Config.DiscordTimeOut
    local discordId = GetPlayerDiscord(src)
    local info = nil 

    if discordId then 
        PerformHttpRequest("https://discordapp.com/api/guilds/" .. Config.GuildId .. "/members/" .. discordId, function(errorCode, resultData, resultHeaders)
            api = 0
            if resultData ~= nil then
                local roles = json.decode(resultData).roles
                for v=1, #roles, 1 do 
                    for r, _ in pairs(Config.Admins) do
                        if roles[v] == r then
                            info = r
                        end
                    end
                end
            end
        end, "GET", "", {["Content-Type"] = "application/json", ["Authorization"] = "Bot " .. Config.BotToken})

        while api > 0 do 
            Wait(100)
            api = api - 100
        end 
    end

    return info
end 

ESX.RegisterServerCallback("villamos_aduty:openPanel", function(source, cb)
    if isAdmin(source) then 
        local xAdmin = ESX.GetPlayerFromId(source)

        local players = {}
        local play = ESX.GetPlayers()
        for i=1, #play, 1 do
            local xPlayer = ESX.GetPlayerFromId(play[i])
            
            table.insert(players, {
                id = xPlayer.source,
                name = GetPlayerName(xPlayer.source),
                group = xPlayer.getGroup(),
                job = xPlayer.getJob().label
            })
        end

        cb(true, xAdmin.getGroup(), players)
    else
        cb(false)
    end 
end)

RegisterNetEvent('villamos_aduty:setTag')
AddEventHandler('villamos_aduty:setTag', function(enable)
    local xPlayer = ESX.GetPlayerFromId(source)
    if inDuty[xPlayer.source] then 
        if enable then 
            tags[xPlayer.source] = inDuty[xPlayer.source].tag
            TriggerClientEvent("villamos_aduty:sendData", -1, tags)
        else 
            tags[xPlayer.source] = nil
            TriggerClientEvent("villamos_aduty:sendData", -1, tags)
        end 
    end 
end)

RegisterNetEvent('villamos_aduty:setDutya')
AddEventHandler('villamos_aduty:setDutya', function(enable)
    local xPlayer = ESX.GetPlayerFromId(source)
    if inDuty[xPlayer.source] then 
        TriggerClientEvent("villamos_aduty:setDuty", xPlayer.source, false, inDuty[xPlayer.source].ped or false)
        if tags[xPlayer.source] then 
            tags[xPlayer.source] = nil
            TriggerClientEvent("villamos_aduty:sendData", -1, tags)
        end 
        local dutyMinutes = math.floor((os.time() - inDuty[xPlayer.source].start) / 60)
        inDuty[xPlayer.source] = nil
        TriggerClientEvent("villamos_aduty:notify", -1, GetPlayerName(xPlayer.source).." kilépett a szolgálatból!")

        dutyTimes[xPlayer.identifier] = (dutyTimes[xPlayer.identifier] or 0) + dutyMinutes
        SaveResourceFile(GetCurrentResourceName(), "data.json", json.encode(dutyTimes), -1)
        LogToDiscord(GetPlayerName(xPlayer.source), false, FormatMinutes(dutyTimes[xPlayer.identifier] or 0), FormatMinutes(dutyMinutes))
    else 
        local group

        if Config.DiscordTags then 
            group = GetDiscordRole(xPlayer.source)
        else 
            group = xPlayer.getGroup()
        end 

        if group and Config.Admins[group] then 
            inDuty[xPlayer.source] = {
                ped = Config.Admins[group].ped,
                tag = { label = Config.Admins[group].tag .. " " .. GetPlayerName(xPlayer.source), color = Config.Admins[group].color, logo = Config.Admins[group].logo },
                group = group,
                start = os.time()
            }
            TriggerClientEvent("villamos_aduty:setDuty", xPlayer.source, true, inDuty[xPlayer.source].ped or false)
            TriggerClientEvent("villamos_aduty:notify", -1, GetPlayerName(xPlayer.source).." szolgálatba lépett!")

            LogToDiscord(GetPlayerName(xPlayer.source), true, FormatMinutes((dutyTimes[xPlayer.identifier] or 0)))
        else 
            TriggerClientEvent("villamos_aduty:notify", xPlayer.source, "Nincs megfelelő rangod, nem léphesz szolgálatba!")
        end 
    end 
end)

AddEventHandler('playerDropped', function(reason)
    local xPlayer = ESX.GetPlayerFromId(source)
    if inDuty[xPlayer.source] then 
        if tags[xPlayer.source] then 
            tags[xPlayer.source] = nil
            TriggerClientEvent("villamos_aduty:sendData", -1, tags)
        end 
        local dutyMinutes = math.floor((os.time() - inDuty[xPlayer.source].start) / 60)
        inDuty[xPlayer.source] = nil
        TriggerClientEvent("villamos_aduty:notify", -1, GetPlayerName(xPlayer.source).." kilépett a szolgálatból!")

        dutyTimes[xPlayer.identifier] = (dutyTimes[xPlayer.identifier] or 0) + dutyMinutes
        SaveResourceFile(GetCurrentResourceName(), "data.json", json.encode(dutyTimes), -1)
        LogToDiscord(GetPlayerName(xPlayer.source), false, FormatMinutes(dutyTimes[xPlayer.identifier] or 0), FormatMinutes(dutyMinutes))
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData)
    TriggerClientEvent("villamos_aduty:sendData", source, tags)
end)

function LogToDiscord(name, duty, alltime, time)
    if Config.Webhook then 
        

        local connect = {
                {
                    ["color"] = (duty and 27946 or 10616832),
                    ["title"] = "**".. name .."**",
                    ["description"] = (duty and "szolgálatba lépett!" or "kilépett a szolgálatból!"),
                    ["fields"] = {
                        {
                            ["name"] = "Összes Duty Idő",
                            ["value"] = alltime,
                            ["inline"] = true
                        },
                        {
                            ["name"] = "Jelenlegi Duty Idő",
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
                        ["text"] = "villamos_aduty :)",
                    },
                }
        }
        PerformHttpRequest(Config.Webhook, function(err, text, headers) end, 'POST', json.encode({embeds = connect}), { ['Content-Type'] = 'application/json' })
    end 
end

function FormatMinutes(m)
    local minutes = m % 60
	local hours = math.floor((m - minutes) / 60)
	return hours.." h "..minutes.." m"
end

function isAdmin(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    local group = xPlayer.getGroup()

    for _, g in pairs(Config.Perms) do 
        if g == group then 
            return true 
        end 
    end 

    return false
end 

exports('GetDutys', function()
    return inDuty
end)
