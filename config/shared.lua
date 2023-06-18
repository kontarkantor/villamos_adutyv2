Config = {}

Config.Locale = "hu" -- en, hu

Config.Commands = true

Config.Icons = {
    "marvel"
}

local clothes = {
    male = {
        ['helmet_1'] = 91, ['helmet_2'] = 0, 
        ['tshirt_1'] = 15, ['tshirt_2'] = 0, 
        ['torso_1'] = 178, ['torso_2'] = 0,
        ['decals_1'] = 0, ['decals_2'] = 0,
        ['arms'] = 1,
        ['pants_1'] = 77, ['pants_2'] = 0,
        ['shoes_1'] = 55, ['shoes_2'] = 0,
    }, 
    female = {
        ['helmet_1'] = 114, ['helmet_2'] = 24, 
        ['tshirt_1'] = 14, ['tshirt_2'] = 0, 
        ['torso_1'] = 180, ['torso_2'] = 5,
        ['decals_1'] = 0, ['decals_2'] = 0,
        ['arms'] = 14,
        ['pants_1'] = 79, ['pants_2'] = 5,
        ['shoes_1'] = 58, ['shoes_2'] = 5,
    }
}

Config.Perms = {
    "admin",
    "owner"
}

Config.Admins = { --a pedet vagy a logót vagy a ruhát ha nem szeretnéd használni állítsd falsera
    ["admin"] = { tag = "[ADMIN]", logo = "marvel", ped = false, cloth = clothes, color = { r = 162, g = 0, b = 0 }},
    ["owner"] = { tag = "[ADMIN]", logo = "marvel", ped = `s_m_m_chemsec_01`, cloth = false, color = { r = 162, g = 0, b = 0 }},
}


if not IsDuplicityVersion() then 
    Config.Notify = function(msg)
        TriggerEvent("esx:showNotification", msg)
    end 
end 