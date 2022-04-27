ESX = nil
local adminok = {}
local playerids = {}
local isInUi = false

local duty = false
local group = "user"
local tag = false
local ids = false
local god = false
local speed = false
local invisible = false
local noragdoll = false

RegisterCommand('admenu', function(s, a, r)
    ESX.TriggerServerCallback("villamos_aduty:openPanel", function(allow, _group, players) 
        if allow then 
            SendNUIMessage({
                type = "setplayers",
                players = players
            })
            group = _group 
            UpdateNui()
            SetNuiState(true)
        else 
            notify("Nincs hozzá jogosultságod!", "red")
        end 
    end)
end)
RegisterKeyMapping('admenu', 'Open admin menu', 'keyboard', 'o')

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

RegisterNUICallback('update', function(data, cb)
    ESX.TriggerServerCallback("villamos_aduty:openPanel", function(allow, _group, players) 
        if allow then 
            SendNUIMessage({
                type = "setplayers",
                players = players
            })
            group = _group 
            UpdateNui()
        end
    end)
    UpdateNui()
    cb('ok')
end)

RegisterNUICallback('duty', function(data, cb)
    TriggerServerEvent('villamos_aduty:setDutya', data.enable)
    UpdateNui()
    cb('ok')
end)

RegisterNUICallback('tag', function(data, cb)
    ToggleTag(data.enable, true)
    cb('ok')
end)

RegisterNUICallback('ids', function(data, cb)
    ToggleIds(data.enable, true)
    cb('ok')
end)

RegisterNUICallback('god', function(data, cb)
    ToggleGod(data.enable, true)
    cb('ok')
end)

RegisterNUICallback('speed', function(data, cb)
    ToggleSpeed(data.enable, true)
    cb('ok')
end)

RegisterNUICallback('invisible', function(data, cb)
    ToggleInvisible(data.enable, true)
    cb('ok')
end)

RegisterNUICallback('noragdoll', function(data, cb)
    ToggleNoragdoll(data.enable, true)
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

Citizen.CreateThread(function()
    while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

    local txd = CreateRuntimeTxd("duty")
	for _, v in pairs(Config.Icons) do
		CreateRuntimeTextureFromImage(txd, v, "icons/"..v..".png")
	end
end)

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
        ActionCoords()
    end)

    RegisterCommand('adheal', function(s, a, r)
        ActionHeal()
    end)

    RegisterCommand('admarker', function(s, a, r)
        ActionMarker()
    end)
end 


RegisterNetEvent('villamos_aduty:setDuty')
AddEventHandler('villamos_aduty:setDuty', function(state, ped)
    if state then 
        duty = true 
        if ped then 
            if IsModelInCdimage(ped) and IsModelValid(ped) then
                RequestModel(ped)
                while not HasModelLoaded(ped) do
                  Citizen.Wait(0)
                end
                SetPlayerModel(PlayerId(), ped)
                SetModelAsNoLongerNeeded(ped)
            else 
                notify("Érvénytelen pedre váltanál!", "red")
            end 
        end 
        ToggleTag(true, false)
        UpdateNui()
    else 
        if ped then 
            TriggerEvent('skinchanger:getSkin', function(skin)
                local model = 'mp_m_freemode_01'
                if skin.sex ~= 0 then
                    model = 'mp_f_freemode_01'
                end

                if IsModelInCdimage(model) and IsModelValid(model) then
                    RequestModel(model)
                    while not HasModelLoaded(model) do
                      Citizen.Wait(0)
                    end
                    SetPlayerModel(PlayerId(), model)
                    SetModelAsNoLongerNeeded(model)
                    TriggerEvent('skinchanger:loadSkin', skin)
                    TriggerEvent('esx:restoreLoadout')
                end
            end)
        end 
        ToggleTag(false, false)
        ToggleIds(false, false)
        ToggleSpeed(false, false)
        ToggleGod(false, false)
        ToggleInvisible(false, false)
        ToggleNoragdoll(false, false)
        duty = false
        UpdateNui()
    end 
end)

function ToggleGod(state, noti) 
    if duty then 
        god = state
        SetPlayerInvincible(PlayerId(), god)
        if noti then 
            notify("Halhatatlanság ".. (god and "bekapcsolva" or "kikapcsolva"), (god and "green" or "red"))
        end 
        Citizen.CreateThread(function()
            while god do
                Citizen.Wait(1000)
                local ped = PlayerPedId()
                if not GetPlayerInvincible(PlayerPedId()) then 
                    SetPlayerInvincible(PlayerPedId(), true)
                end
            end
        end)
    else 
        notify("Nincs hozzá jogosultságod!")
    end 
    UpdateNui()
end 

function ToggleTag(state, noti) 
    if duty then 
        tag = state
        TriggerServerEvent('villamos_aduty:setTag', tag)
        if noti then 
            notify("Admin tag " .. (tag and "bekapcsolva" or "kikapcsolva"), (tag and "green" or "red"))
        end 
    else 
        notify("Nincs hozzá jogosultságod!")
    end 
    UpdateNui()
end 

function ToggleIds(state, noti) 
    if duty then 
        ids = state
        if noti then 
            notify("ID-k ".. (ids and "bekapcsolva" or "kikapcsolva"), (ids and "green" or "red"))
        end 
        Citizen.CreateThread(function()
            while ids do
                Citizen.Wait(3)
                for id = 0, 256 do
                    if NetworkIsPlayerActive(id) and playerids[id] then
                        pped = GetPlayerPed(id)
                        local x, y, z = table.unpack(GetEntityCoords(pped))
                        DrawText3D(x, y, z, "["..GetPlayerServerId(id).."] "..GetPlayerName(id).."~n~❤️: "..GetEntityHealth(pped), 255, 255, 255, 0.3)
                    end  
                end
            end
        end)
    else 
        notify("Nincs hozzá jogosultságod!")
    end 
    UpdateNui()
end 

function ToggleSpeed(state, noti) 
    if duty then 
        speed = state
        SetRunSprintMultiplierForPlayer(PlayerId(), speed and 1.4 or 1.0)
        if noti then 
            notify("Gyorsaság ".. (speed and "bekapcsolva" or "kikapcsolva"), (speed and "green" or "red"))
        end 
        Citizen.CreateThread(function()
            while speed do
                Citizen.Wait(0)
                SetSuperJumpThisFrame(PlayerId())
            end
        end)
    else 
        notify("Nincs hozzá jogosultságod!")
    end 
    UpdateNui()
end 

function ToggleInvisible(state, noti) 
    if duty then 
        invisible = state
        SetEntityVisible(GetPlayerPed(-1), not invisible)
        if noti then 
            notify("Látahatlanság ".. (invisible and "bekapcsolva" or "kikapcsolva"), (invisible and "green" or "red"))
        end 
    else 
        notify("Nincs hozzá jogosultságod!")
    end 
    UpdateNui()
end 

function ToggleNoragdoll(state, noti) 
    if duty then 
        noragdoll = state
        SetPedCanRagdoll(GetPlayerPed(-1), not noragdoll)
        if noti then 
            notify("No Ragdoll ".. (noragdoll and "bekapcsolva" or "kikapcsolva"), (noragdoll and "green" or "red"))
        end 
    else 
        notify("Nincs hozzá jogosultságod!")
    end 
    UpdateNui()
end 

function ActionCoords() 
    if duty then 
        local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
        SendNUIMessage({
            type = "copy",
            copy = "vector3("..x..", "..y..", "..z..")"
        })
        notify("Koordináták kimásolva!", "green")
    else 
        notify("Nincs hozzá jogosultságod!")
    end 
end 

function ActionHeal() 
    if duty then 
        local ped = GetPlayerPed(-1)
        TriggerEvent('esx_status:set', 'hunger', 1000000)
        TriggerEvent('esx_status:set', 'thirst', 1000000)
        SetEntityHealth(ped, GetEntityMaxHealth(ped))
        notify("Meggyógyítva!", "green")
    else 
        notify("Nincs hozzá jogosultságod!")
    end 
end 

function ActionMarker()
    if duty then 
        local WaypointHandle = GetFirstBlipInfoId(8)
        if DoesBlipExist(WaypointHandle) then
            local waypointCoords = GetBlipInfoIdCoord(WaypointHandle)

            for height = 1, 1000 do
                SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords["x"], waypointCoords["y"], height + 0.0)

                local foundGround, zPos = GetGroundZFor_3dCoord(waypointCoords["x"], waypointCoords["y"], height + 0.0)

                if foundGround then
                    break
                end

                Citizen.Wait(5)
            end
            notify("Elteleportálva!", "green")
        else
            notify("Nincs kijelölve semmi!", "red")
        end
    else 
        notify("Nincs hozzá jogosultságod!")
    end 
end 

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(3)
        for id, data in pairs(adminok) do
            local lid = GetPlayerFromServerId(id)
            local pped = GetPlayerPed(lid)
            if playerids[lid] then
                local x, y, z = table.unpack(GetEntityCoords(pped))
                DrawText3D(x, y, z+1.0, data.label, data.color.r, data.color.g, data.color.b, 0.5)
                DrawMarker(9, x, y, z+1.45, 0.0, 0.0, 0.0, 90.0, 90.0, 0.0, 1.0, 1.0, 1.0, 255, 255, 255, 255, true, false, 2, true, "duty", data.logo, false)
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local ped = GetPlayerPed(-1)
        local coords = GetEntityCoords(ped, true)
        for id = 0, 256 do
            if NetworkIsPlayerActive(id) then
                local pped = GetPlayerPed(id)
                if GetDistanceBetweenCoords(coords, GetEntityCoords(pped), true) < 20 then 
                    playerids[id] = true
                else
                    playerids[id] = false
                end
            end  
        end
    end
end)

RegisterNetEvent('villamos_aduty:sendData')
AddEventHandler('villamos_aduty:sendData', function(recData)
    adminok = recData
end)

RegisterNetEvent('villamos_aduty:notify')
AddEventHandler('villamos_aduty:notify', function(msg)
    notify(msg)
end)

function DrawText3D(x, y, z, text, r, g, b, scl) 
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)

    local scale = (1/dist)*2
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov
    
    if onScreen then
        SetTextScale(0.0, scl*scale)
        SetTextFont(4)
        SetTextColour(r, g, b, 255)
        SetTextCentre(1)
        BeginTextCommandDisplayText("STRING")
	    AddTextComponentString(text)
	    EndTextCommandDisplayText(_x, _y)
    end
end

function notify(msg, color)
    if not color then 
        color = ""
    elseif color == "green" then 
        color = "~g~ "
    elseif color == "red" then 
        color = "~r~ "
    end 
    ESX.ShowNotification(color .. msg)
end 
