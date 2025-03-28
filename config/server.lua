Config.DiscordTags = false
Config.GuildId = ""
Config.BotToken = "" --NE RAKD ELÉ A Bot szót!!!!! csak a token amit kimásolsz!!
Config.DiscordTimeOut = 1500

Config.Webhook = false

Config.Notify = function(src, msg)
    if Config.Notifye == "esx" then
        TriggerClientEvent("esx:showNotification", src, msg)
    elseif Config.Notifye == "ox" then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Admin Rendszer',
            description = msg,
            type = 'info'
        })
    elseif Config.Notifye == "codem" then
        TriggerClientEvent('codem-notification:Create', src, msg, 'info', 'Admin Rendszer', 5000)
    elseif Config.Notifye == "okok" then
        TriggerClientEvent('okokNotify:Alert', src, 'Admin Rendszer', msg, 5000, 'info', false)
    end
end 