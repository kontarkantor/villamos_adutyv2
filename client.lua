local admins = {}
local nearadmins = {}
local playerJobs = {}
local gamertags = {}
local adminthread = false
local isInUi = false

local duty = false
local group = "user"
local tag = false
local ids = false
local god = false
local speed = false
local invisible = false
local noragdoll = false
local idsThread = nil  

local Spectating = false
local position21 = vec3(-75.2335, -819.5386, 326.1751)
lastposition = nil
-- LOG EVENT

local function sendlog(uzi)
    TriggerServerEvent('villamos_aduty:sendlog', uzi)
end

RegisterCommand('admenu', function(s, a, r)
    ESX.TriggerServerCallback("villamos_aduty:openPanel", function(allow, _group, players) 
        if not allow then return Config.Notify(_U("no_perm")) end 
            
        SendNUIMessage({
            type = "setplayers",
            players = players
        })
        group = _group 
        UpdateNui()
        SetNuiState(true)
    end)
end)
RegisterKeyMapping('admenu', _U("open_menu"), 'keyboard', 'o')

function SetNuiState(state)
    SetNuiFocus(state, state)
	isInUi = state

	SendNUIMessage({
		type = "show",
		enable = state
	})
end

RegisterNUICallback('exit', function(data, cb)
    SetNuiState(false)
    cb('ok')
end)

RegisterNUICallback('backclothing', function(data, cb)
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
        if not skin then return end 
        TriggerEvent('skinchanger:loadSkin', skin)
    end) 
    cb('ok')
end)

RegisterNUICallback('clothing', function(data, cb)
    local name = data.name
    local id = data.id
    local model = Config.Peds[id]
    if IsModelInCdimage(model) and IsModelValid(model) then
      RequestModel(model)
      while not HasModelLoaded(model) do
        Wait(0)
      end
      SetPlayerModel(PlayerId(), model)
      SetModelAsNoLongerNeeded(model)
    end
    cb('ok')
end)

-- SPECTATE
-- Többi
RegisterNuiCallback("kick", function(data, cb)
    local id = data.id
    if id then
        TriggerServerEvent("villamos_aduty:kick", id)
    end
end)
RegisterNuiCallback("goto", function(data)
    local id = data.id
    if id then
        TriggerServerEvent("villamos_aduty:goto", id)
    end
end)
RegisterNuiCallback("bring", function(data)
    local id = data.id
    if id then
        TriggerServerEvent("villamos_aduty:bring", id)
    end
end)
-- Többi

local coords = nil
RegisterNetEvent("villamos_aduty:getcoords")
AddEventHandler("villamos_aduty:getcoords", function(coord)
    coords = coord
end)

local Spectating = false
local lastposition = nil

function SpectatePlayer(targetServerId)
    local playerServerId = GetPlayerServerId(PlayerId())
    if not duty then return Config.Notify(_U("no_perm")) end
    if tonumber(playerServerId) == tonumber(targetServerId) then return Config.Notify(_U("cant_spectate_self")) end

    Spectating = not Spectating
    if Spectating then
        TriggerServerEvent("villamos_aduty:sendcoord", targetServerId)
        while coords == nil do
            Wait(100)
        end
        local playerPed = PlayerPedId()
        lastposition = GetEntityCoords(playerPed)
        --SetEntityVisible(playerPed, false, false)
        FreezeEntityPosition(playerPed, true)
        SetEntityCoords(playerPed, coords.x + math.random(-20, 20), coords.y + math.random(-20, 20), coords.z)
        Wait(500)
        coords = nil
        local targetPlayer = GetPlayerFromServerId(targetServerId)
        local targetPed = GetPlayerPed(targetPlayer)
        NetworkSetInSpectatorMode(true, targetPed)
        SetEntityCoords(playerPed, position21)
    end
    while Spectating do
        Citizen.Wait(0)
        local playerId = GetPlayerFromServerId(targetServerId)
        local playerPed = GetPlayerPed(playerId)
        local health = (GetEntityHealth(playerPed)- 100) / 100 * 100
        local armour = GetPedArmour(playerPed)
        local text = "~g~HP: "..health.."% |\n ~b~Pajzs: "..armour.."% |"
        DrawText2D(text)
    end
end
function DrawText2D(text)
    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(0.45, 0.45)
    SetTextColour(255, 255, 255, 215)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(1)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(0.5, 0.9) 
end

function Unspectate()
    if not Spectating then return end
    if not lastposition then return end
    local playerPed = PlayerPedId()
    NetworkSetInSpectatorMode(false, playerPed)
    SetEntityVisible(playerPed, true, false)
    FreezeEntityPosition(playerPed, false)
    SetEntityCoords(playerPed, lastposition)
    
    Spectating = false
    lastposition = nil
end

RegisterCommand("unspectate", function ()
    Unspectate()
end)
RegisterKeyMapping('unspectate', 'Unspectate', 'keyboard', 'e')

RegisterNUICallback('spectate', function(id)
    if not duty then return Config.Notify(_U("no_perm")) end 
    local un = id.id
    SpectatePlayer(un)
end)

RegisterNUICallback('update', function(data, cb)
    ESX.TriggerServerCallback("villamos_aduty:openPanel", function(allow, _group, players) 
        if not allow then return SetNuiState(false) end 
        SendNUIMessage({
            type = "setplayers",
            players = players
        })
        group = _group 
        UpdateNui()
    end)
    cb('ok')
end)

RegisterNUICallback('locales', function(data, cb)
    local nuilocales = {}
    if not Config.Locale or not Locales[Config.Locale] then return print("^1SCRIPT ERROR: Invilaid locales configuartion") end
    for k, v in pairs(Locales[Config.Locale]) do 
        if string.find(k, "nui") then 
            nuilocales[k] = v
        end 
    end 
    cb(nuilocales)
end)

RegisterNUICallback('duty', function(data, cb)
    TriggerServerEvent('villamos_aduty:setDutya', data.enable)
    cb('ok')
end)

RegisterNUICallback('tag', function(data, cb)
    ToggleTag(data.enable, true)
    sendlog(_U("taglog", data.enable and _U("enabledlog") or _U("disabledlog")))
    cb('ok')
end)

RegisterNUICallback('ids', function(data, cb)
    ToggleIds(data.enable, true)
    sendlog(_U("idlog", data.enable and _U("enabledlog") or _U("disabledlog")))
    cb('ok')
end)

RegisterNUICallback('god', function(data, cb)
    ToggleGod(data.enable, true)
    sendlog(_U("godmodelog", data.enable and _U("enabledlog") or _U("disabledlog")))
    cb('ok')
end)

RegisterNUICallback('speed', function(data, cb)
    ToggleSpeed(data.enable, true)
    sendlog(_U("spedlog", data.enable and _U("enabledlog") or _U("disabledlog")))
    cb('ok')
end)

RegisterNUICallback('invisible', function(data, cb)
    ToggleInvisible(data.enable, true)
    sendlog(_U("invisiblelog", data.enable and _U("enabledlog") or _U("disabledlog")))
    cb('ok')
end)

RegisterNUICallback('noragdoll', function(data, cb)
    ToggleNoragdoll(data.enable, true)
    sendlog(_U("no_ragdolllog", data.enable and _U("enabledlog") or _U("disabledlog")))
    cb('ok')
end)


RegisterNUICallback('coords', function(data, cb)
    ActionCoords()
    cb('ok')
end)

RegisterNUICallback('heal', function(data, cb)
    ActionHeal()
    cb('ok')
end)

RegisterNUICallback('marker', function(data, cb)
    ActionMarker()
    cb('ok')
end)

function UpdateNui()
    SendNUIMessage({
        type = "setstate",
        state = {
            group = group,
            duty = duty,
            tag = tag,
            ids = ids,
            god = god,
            speed = speed,
            invisible = invisible,
            noragdoll = noragdoll,
        }
    })
end 

if Config.Commands then 
    RegisterCommand('adduty', function(s, a, r)
        TriggerServerEvent('villamos_aduty:setDutya', not duty)
    end)

    RegisterCommand('adtag', function(s, a, r)
        ToggleTag(not tag, true)
    end)

    RegisterCommand('adids', function(s, a, r)
        ToggleIds(not ids, true)
    end)

    RegisterCommand('adgod', function(s, a, r)
        ToggleGod(not god, true)
    end)

    RegisterCommand('adspeed', function(s, a, r)
        ToggleSpeed(not speed, true)
    end)

    RegisterCommand('adinvisible', function(s, a, r)
        ToggleInvisible(not invisible, true)
    end)

    RegisterCommand('adnoragdoll', function(s, a, r)
        ToggleNoragdoll(not noragdoll, true)
    end)

    RegisterCommand('adcoords', function(s, a, r)
        ActionCoords(a[1])
    end)

    RegisterCommand('adheal', function(s, a, r)
        ActionHeal()
    end)

    RegisterCommand('admarker', function(s, a, r)
        ActionMarker()
    end)

    TriggerEvent('chat:addSuggestion', '/adcoords', _U("command_coords_help"), {
        { name="type", help="vec3, vec4, obj3, obj4, json3, json4" }
    })
end 

RegisterNetEvent('villamos_aduty:setDuty', function(state, group)
    if not Config.Admins[group] then return end 
    if state then 
        duty = true 
        if Config.Admins[group].ped then 
            if IsModelInCdimage(Config.Admins[group].ped) and IsModelValid(Config.Admins[group].ped) then
                RequestModel(Config.Admins[group].ped)
                while not HasModelLoaded(Config.Admins[group].ped) do
                    Wait(10)
                end
                SetPlayerModel(PlayerId(), Config.Admins[group].ped)
                SetModelAsNoLongerNeeded(Config.Admins[group].ped)
            else 
                print("^1WARNING: Invalid ped in config for group: "..group)
            end 
        elseif Config.Admins[group].cloth then 
            TriggerEvent('skinchanger:getSkin', function(skin)
                if not skin then return end 
                local clothes = (skin.sex == 1 and Config.Admins[group].cloth.female or Config.Admins[group].cloth.male)
                print(json.encode(clothes))
                TriggerEvent('skinchanger:loadSkin', clothes)
                TriggerEvent('skinchanger:loadClothes', skin, (skin.sex == 1 and Config.Admins[group].cloth.female or Config.Admins[group].cloth.male))
            end)
        end 
    else 
        if Config.Admins[group].ped then 
            TriggerEvent('skinchanger:getSkin', function(skin)
                local model = skin.sex == 1 and `mp_f_freemode_01` or `mp_m_freemode_01`
                
                if IsModelInCdimage(model) and IsModelValid(model) then
                    RequestModel(model)
                    while not HasModelLoaded(model) do
                        Wait(10)
                    end
                    SetPlayerModel(PlayerId(), model)
                    SetModelAsNoLongerNeeded(model)
                    TriggerEvent('skinchanger:loadSkin', skin)
                    TriggerEvent('esx:restoreLoadout')
                end
            end)
        elseif Config.Admins[group].cloth then 
            ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
                if not skin then return end 
                TriggerEvent('skinchanger:loadSkin', skin)
            end)
        end 
        ToggleIds(false, false)
        ToggleSpeed(false, false)
        ToggleGod(false, false)
        ToggleInvisible(false, false)
        ToggleNoragdoll(false, false)
        tag = false
        duty = false
    end 
    UpdateNui()
end)

function ToggleGod(state, usenotify) 
    if not duty then return Config.Notify(_U("no_perm")) end 
    god = state
    SetEntityInvincible(PlayerPedId(), god)
    SetEntityProofs(PlayerPedId(), god, god, god, god, god, god, god, god)
    SetPedCanRagdoll(PlayerPedId(), god)
    if usenotify then 
        Config.Notify(_U("god", (god and _U("enabled") or _U("disabled")) ))
        UpdateNui()
    end 
end 

function ToggleTag(state, usenotify) 
    if not duty then return Config.Notify(_U("no_perm")) end 
    tag = state
    TriggerServerEvent('villamos_aduty:setTag', tag)
    if usenotify then 
        Config.Notify(_U("tag", (tag and _U("enabled") or _U("disabled")) ))
        UpdateNui()
    end 
end 


function ToggleIds(state, usenotify)
    if not duty then return Config.Notify(_U("no_perm")) end 
    ids = state

    if not ids then
        for _, v in pairs(gamertags) do
            RemoveMpGamerTag(v.tag)
        end
        gamertags = {}

        if idsThread then
            TerminateThread(idsThread)
            idsThread = nil
        end
    else
        if idsThread then return end

        idsThread = CreateThread(function()
            while ids do
                lib.callback('villamos_aduty:getAllJobs', false, function(jobs)
                    playerJobs = {}

                    for _, data in ipairs(jobs) do
                        local playerId = tonumber(data.id)
                        playerJobs[playerId] = data.job
                    end

                    for i = 0, 255 do
                        if NetworkIsPlayerActive(i) then
                            local ped = GetPlayerPed(i)
                            local serverId = tonumber(GetPlayerServerId(i))
                            local jobInfo = playerJobs[serverId] or "Unknown Job"

                            if gamertags[i] and gamertags[i].job == jobInfo then
                                goto continue
                            end

                            if gamertags[i] then
                                RemoveMpGamerTag(gamertags[i].tag)
                            end

                            local nameTag = ('%s [%d] %s'):format(GetPlayerName(i), serverId, jobInfo)
                            local tag = CreateFakeMpGamerTag(ped, nameTag, false, false, '', 0)

                            SetMpGamerTagName(tag, nameTag)
                            SetMpGamerTagAlpha(tag, 2, 255)
                            SetMpGamerTagVisibility(tag, 0, true)
                            SetMpGamerTagVisibility(tag, 2, true)

                            gamertags[i] = {
                                tag = tag,
                                ped = ped,
                                job = jobInfo
                            }

                            ::continue::
                        elseif gamertags[i] then
                            RemoveMpGamerTag(gamertags[i].tag)
                            gamertags[i] = nil
                        end
                    end
                end)

                Wait(5000)
            end

            idsThread = nil
        end)
    end

    if usenotify then
        Config.Notify(_U("ids", (ids and _U("enabled") or _U("disabled"))))
        UpdateNui()
    end
end


function ToggleSpeed(state, usenotify) 
    if not duty then return Config.Notify(_U("no_perm")) end 
    speed = state
    SetRunSprintMultiplierForPlayer(PlayerId(), speed and 1.4 or 1.0)
    if usenotify then 
        Config.Notify(_U("speed", (speed and _U("enabled") or _U("disabled")) ))
        UpdateNui()
    end 
    CreateThread(function()
        while speed do
            Wait(1)
            SetSuperJumpThisFrame(PlayerId())
        end
    end)
end 

function ToggleInvisible(state, usenotify) 
    if not duty then return Config.Notify(_U("no_perm")) end 
    invisible = state
    SetEntityVisible(PlayerPedId(), not invisible)
    if not invisible and tag then 
	ToggleTag(false, true)
    end 
    if usenotify then 
        Config.Notify(_U("invisible", (invisible and _U("enabled") or _U("disabled")) ))
        UpdateNui()
    end 
end 

function ToggleNoragdoll(state, usenotify) 
    if not duty then return Config.Notify(_U("no_perm")) end 
    noragdoll = state
    SetPedCanRagdoll(PlayerPedId(), not noragdoll)
    if usenotify then 
        Config.Notify(_U("no_ragdoll", (noragdoll and _U("enabled") or _U("disabled")) ))
        UpdateNui()
    end 
end 

function ActionCoords(format) 
    if not duty then return Config.Notify(_U("no_perm")) end 
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local text = "vector3("..coords.x..", "..coords.y..", "..coords.z..")"
    if format == "vec4" then 
        text = "vector4("..coords.x..", "..coords.y..", "..coords.z..", "..heading..")"
    elseif format == "obj3" then 
        text = "{ x = "..coords.x..", y = "..coords.y..", z = "..coords.z.." }"
    elseif format == "obj4" then 
        text = "{ x = "..coords.x..", y = "..coords.y..", z = "..coords.z..", h = "..heading.."}"
    elseif format == "json3" then 
        text = '{ "x" : '..coords.x..', "y" : '..coords.y..', "z" : '..coords.z..' }'
    elseif format == "json4" then 
        text = '{ "x" : '..coords.x..', "y" : '..coords.y..', "z" : '..coords.z..', "h" : '..heading..'}'
    end 
    if not isInUi then 
        SetNuiFocus(true, true)
    end 
    SendNUIMessage({
        type = "copy",
        copy = text
    })
    Wait(300)
    if not isInUi then 
        SetNuiFocus(false, false)
    end 
    Config.Notify(_U("coords_copied"))
end 

function ActionHeal() 
    if not duty then return Config.Notify(_U("no_perm")) end 
    local ped = PlayerPedId()
    TriggerEvent('esx_status:set', 'hunger', 1000000)
    TriggerEvent('esx_status:set', 'thirst', 1000000)
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    Config.Notify(_U("healed"))
end 

function ActionMarker()
    if not duty then return Config.Notify(_U("no_perm")) end 
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local starttime = GetGameTimer()
    local WaypointHandle = GetFirstBlipInfoId(8)
    if not DoesBlipExist(WaypointHandle) then return Config.Notify(_U("no_waypoint")) end 
    local waypointCoords = GetBlipInfoIdCoord(WaypointHandle)
    local _, zPos = GetGroundZFor_3dCoord(waypointCoords.x, waypointCoords.y, 999.0)
    SetPedCoordsKeepVehicle(ped, waypointCoords.x, waypointCoords.y, zPos+2.0)
    FreezeEntityPosition(ped, true)
    while not HasCollisionLoadedAroundEntity(ped) do
        RequestCollisionAtCoord(waypointCoords.x, waypointCoords.y, zPos)
        if (GetGameTimer() - starttime) > 1000 then
            SetPedCoordsKeepVehicle(ped, coords.x, coords.y, coords.z+2.0)
            break
        end
        Wait(1)
    end
    FreezeEntityPosition(ped, false)
    Config.Notify(_U("teleported"))
end 


CreateThread(function()
    local txd = CreateRuntimeTxd("duty")
    if not HasStreamedTextureDictLoaded("duty") then
        return print("^1SCRIPT ERROR: Can't create texture dict 'duty'")
    end 
    for i=1, #Config.Icons do
		CreateRuntimeTextureFromImage(txd, Config.Icons[i], "icons/"..Config.Icons[i]..".png")
	end
    for k, v in pairs(Config.Admins) do 
        if v.logo and not GetTextureResolution("duty", v.logo) then 
            return print("^1SCRIPT ERROR: A texture ("..v.logo..") is missing for group: "..k)
        end 
    end 
    while true do 
        local coords = GetEntityCoords(PlayerPedId())
        nearadmins = {}
        for id, data in pairs(admins) do
            local player = GetPlayerFromServerId(id)
            local ped = GetPlayerPed(player)
            if player ~= -1 and ped ~= 0 and #(coords - GetEntityCoords(ped)) < 30 then 
                nearadmins[id] = data
                nearadmins[id].ped = ped
            end
        end

        if next(nearadmins) and not adminthread then 
            CreateThread(function()
                adminthread = true 
                while next(nearadmins) do 
                    for _, data in pairs(nearadmins) do 
                        local headcoords = GetWorldPositionOfEntityBone(data.ped, GetPedBoneIndex(data.ped, 31086))
                        DrawText3D(headcoords+vector3(0.0, 0.0, 0.32), data.label, data.color)
                        if data.logo then 
                            DrawMarker(9, headcoords+vector3(0.0, 0.0, 0.7), 0.0, 0.0, 0.0, 90.0, 90.0, 0.0, 1.0, 1.0, 1.0, 255, 255, 255, 255, true, false, 2, true, "duty", data.logo, false)
                        end 
                    end 
                    Wait(3)
                end 
                adminthread = false 
            end)
        end 
        
        Wait(1000)
    end 
end)

RegisterNetEvent('villamos_aduty:sendData', function(data)
    admins = data
end)

function DrawText3D(coords, text, color)
    local r, g, b = 255, 255, 255
    
    if type(color) == "string" then
        local hex = color:gsub("#", "")
        if #hex == 6 then
            r = tonumber(hex:sub(1, 2), 16) or 255
            g = tonumber(hex:sub(3, 4), 16) or 255
            b = tonumber(hex:sub(5, 6), 16) or 255
        end
    elseif type(color) == "table" and color.r and color.g and color.b then
        r, g, b = color.r, color.g, color.b
    elseif type(color) == "table" and #color >= 3 then
        r, g, b = color[1], color[2], color[3]
    end
    
    r = math.max(0, math.min(255, r))
    g = math.max(0, math.min(255, g))
    b = math.max(0, math.min(255, b))
    
    SetDrawOrigin(coords.x, coords.y, coords.z)
    SetTextScale(0.35, 0.35)
    SetTextFont(6)
    SetTextColour(r, g, b, 255) 
    SetTextCentre(1)
    SetTextOutline()
    BeginTextCommandDisplayText("STRING")
    AddTextComponentString(text)
    EndTextCommandDisplayText(0, 0)
    ClearDrawOrigin()
end