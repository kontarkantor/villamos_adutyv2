Config = {}

Config.Locale = "hu" -- en, hu

Config.Commands = true

Config.ChatLogs = true -- true/false Chatre való logolás (Minden ami a panelhez kapcsolódó aztat logolni fogja!) (A PLAYEREK MINDIG TUDJÁK HASZNÁLNI A /adlog PARANCSOT!)
                        -- EZ CSAK AZT TUDJA HOGY ALAPBÓL KI/BE KAPCSOLJA A CHATRE LOGOLÁST
Config.Notifye = "ox" -- esx, ox, okok, codem

Config.Icons = {
    "marvel"
}



Config.Perms = {
    "admin",
    "owner"
}

Config.Admins = { --a pedet vagy a logót vagy a ruhát ha nem szeretnéd használni állítsd falsera
["admin"] = { tag = "Adminisztrátor", logo = false, color = "#dd42f5"},
["admin2"] = { tag = "[ADMIN 2]", logo = false, color = { r = 162, g = 0, b = 0 }},
["owner"] = { tag = "[ADMIN]", logo = "marvel", color = { r = 162, g = 0, b = 0 }},
}

Config.Peds = {
    ["admin"] = "u_m_m_jesus_01",
    ["admin1"] = "ig_lamardevis",
    ["admin2"] = "player_one",
    ["admin3"] = "player_two",
    ["admin4"] = "player_zero",
}


if not IsDuplicityVersion() then 
    Config.Notify = function(msg)
        if Config.Notifye == "esx" then
            TriggerEvent("esx:showNotification", msg)
        elseif Config.Notifye == "ox" then
            lib.notify({
                title = 'Admin Rendszer',
                description = msg,
                type = 'info'
            })
        elseif Config.Notifye == "codem" then
            TriggerEvent('codem-notification:Create', msg, 'info', 'Admin Rendszer', 5000)
        elseif Config.Notifye == "okok" then
            exports['okokNotify']:Alert('Admin Rendszer', msg, 5000, 'info', false)
        end
    end 
end 
