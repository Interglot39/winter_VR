DPX = nil
local blips = {}
local bombDefused = false
local inGame = false
local inShop = false
local activeBomb = false
Citizen.CreateThread(function() 
    while DPX == nil do
        TriggerEvent('dpx:getSharedObject', function(obj) DPX = obj end)
        Citizen.Wait(0)
    end
end)

AddEventHandler('dpx:onPlayerDeath', function()
    local semiMuerto, muertoTotal = exports['dps_safd']:isMuerto()
    if semiMuerto then
        TriggerServerEvent("dps_VR:setPlayerStatus", "semiMuerto")
    elseif muertoTotal then
        TriggerServerEvent("dps_VR:setPlayerStatus", "muertoTotal")
    end
end)

--ARMY
RegisterCommand("teams", function()
    TriggerEvent("dps_VR:openMainMenu")
end, false)

RegisterCommand("start", function()
    TriggerServerEvent("dps_VR:startGameS")
end, false)

RegisterCommand("initial", function()
    TriggerServerEvent("dps_VR:giveInitialGear")
end, false)

RegisterCommand("reset", function()
    TriggerServerEvent("dps_VR:resetInventory")
end, false)

RegisterCommand("leader", function()
    openLeaderBoard()
end, false)


RegisterNetEvent('dps_zonas:dentroZona')
AddEventHandler('dps_zonas:dentroZona', function(zona)
    if zona and zona.name == 'VRShop' then
        inShop = true
        local shownCartel = false
        while inShop do
            Citizen.Wait(0)
            local pId = PlayerPedId()
            local pIdCoords = GetEntityCoords(pId)
            local distance = #(zona.data.coords - pIdCoords)
            if distance < 1.5 then 
                if distance < 1 and IsControlJustReleased(0,38) then
                    DPX.TriggerServerCallback('dps_lspd:getArmeriaItems', function(items)
                        TriggerEvent('dps_inventario:openShop', "vr", items)
                    end, DPS.Shop)
                end
                if not shownCartel then
                    TriggerEvent('cd_drawtextui:ShowUI', 'show', 'Presiona <b>E</b> abrir tienda')
                    shownCartel = true
                end
            else
                if shownCartel then
                    TriggerEvent('cd_drawtextui:HideUI')
                    shownCartel = false
                end
            end
        end
    end
end)

RegisterNetEvent('dps_zonas:salgoZona')
AddEventHandler('dps_zonas:salgoZona', function(zona)
    if zona and zona.name == 'VRShop' then
        inShop = false
        TriggerEvent('cd_drawtextui:HideUI')
    end
end)

RegisterNetEvent('dps_VR2:changeInGame')
AddEventHandler('dps_VR2:changeInGame', function(state)
    inGame = state
end)

RegisterNetEvent('dps_VR:showInfo')
AddEventHandler('dps_VR:showInfo', function(entity)
    local text = "Vive la ultima experiencia del ultimo motor Grafico VR en una experiencia donde tendras que enfrentarte a oleadas de enemigos, para sobrevivir con tus compañeros. ¿Que podria pasar? El ganador recibira el total de todas las entradas. El precio para crear o unirte a una partida es de 500$."
    local img = "https://m.media-amazon.com/images/I/61vilOmXMCL._AC_SL1200_.jpg"
    TriggerEvent('dps_info:showInfo', 'Realidad Virtual', text, entity, img)
end)

RegisterNetEvent("dps_VR:startGameTimeout")
AddEventHandler("dps_VR:startGameTimeout", function(time, initial, spawnCoords)
    local contador = 0
    local pId = PlayerPedId()
    TriggerEvent("dps_VR2:changeInGame", true)
    if initial then
        globalRound = 1
        DoScreenFadeOut(2000)
        Citizen.Wait(2000)
        exports['dps_sound']:playSound('vrOpening', 0.2)
        DPX.Game.Teleport(pId, vector3(spawnCoords.x, spawnCoords.y, spawnCoords.z), function()
            SetEntityHeading(pId, spawnCoords.w)
        end)
        Citizen.Wait(1000)
        Citizen.CreateThread(function()
            local peds = DPX.Game.GetPedsInArea(GetEntityCoords(PlayerPedId()), 300)
            if #peds > 0 then
                for k, v in pairs(peds) do
                    DPX.Game.DeletePed(v)
                    Citizen.Wait(50)
                end
            end
        end)
        pId = PlayerPedId()
        FreezeEntityPosition(pId, true)
        Citizen.Wait(2500)
        setVR()
        AnimpostfxPlay("DeathFailOut", 20000, true)
        DoScreenFadeIn(2000)
        DisplayRadar(true)
        SetPlayerMaxArmour(pId, 100)
    end
    Citizen.CreateThread(function()
        while contador <= time/1000 do 
            Citizen.Wait(0)
            Draw2DText(0.5, 0.4, ("~p~%d"):format(math.ceil((time/1000) - contador)), 3.0)
            --printamos un PUTO NUMERO
        end
    end)
    for i = 0, time/1000, 1 do
        Citizen.Wait(1000)
        contador = contador + 1
    end
    if initial then
        hud()
    end
    FreezeEntityPosition(PlayerPedId(), false)
    AnimpostfxStop('DeathFailOut')
end)

AnimpostfxStop('DeathFailOut')

RegisterNetEvent("dps_VR:setAgrressive")
AddEventHandler("dps_VR:setAgrressive", function(tableE, round)
    local _, enemyGroup = AddRelationshipGroup("vrEnemies")
    local table2 = {}
    globalRound = round
    for _, npcs in ipairs(tableE) do
        local npcNW = NetworkGetEntityFromNetworkId(npcs)
        SetPedRelationshipGroupHash(npcNW, enemyGroup)
        table.insert(table2, npcNW)
    end
    SetRelationshipBetweenGroups(5, enemyGroup, GetPedRelationshipGroupHash(PlayerPedId()))

    for _, npcs in ipairs(table2) do
        if GetEntityModel(npcs) == DPS.JuggerNaut[1] then
            SetEntityMaxHealth(npcs, 1000)
            SetEntityHealth(npcs, 1000)
        end
        TaskCombatHatedTargetsAroundPed(npcs, 200.0, 0)
        SetPedCombatAbility(npcs, DPS.EnemiesAbility[round])
        SetPedCombatMovement(npcs, 2)    
    end
    local whiles = true
    Citizen.CreateThread(function()
        while whiles do
            for k,v in pairs(table2) do
                if GetEntityModel(v) == DPS.JuggerNaut[1] then
                    SetPedSuffersCriticalHits(v, false)
                end
            end
            Citizen.Wait(0)
        end
    end)

    local dead = 0
    local alternate = false
    while whiles and inGame do
        Citizen.Wait(4000)
        local pId = PlayerPedId() 
        for __, npcss in ipairs(table) do
            local npcVV = NetworkGetEntityFromNetworkId(npcss)
            if HasEntityBeenDamagedByAnyPed(npcVV) and not alternate then
                alternate = true
                ClearEntityLastDamageEntity(npcVV)
                TaskSeekCoverFromPed(npcVV, pId, 2000, true)
            elseif alternate then
                alternate = false
                TaskCombatHatedTargetsAroundPed(npcVV, 200.0, 0)
                SetPedCombatAbility(npcVV, DPS.EnemiesAbility[round])
                SetPedCombatMovement(npcVV, 2)    
            end
            if GetEntityHealth(npcVV) == 0 then
                dead = dead + 1
            end
            if not inGame then break end
        end
        if dead == #table then
            whiles = false
        end
        dead = 0
    end
end)

RegisterNetEvent("dps_VR:startMission")
AddEventHandler("dps_VR:startMission", function(bombNid)
    local bomb = NetworkGetEntityFromNetworkId(bombNid)
    local shown = false
    local blip = CreateBlip2(bomb, "Bomba", 486)
    activeBomb = true
    local defusing = false
    print("EMPEZAMOS BOMBA")
    exports['dps_notificaciones']:createNotify('inform', 'Han plantado una bomba dentro del Bunker, localizala y desactivala antes de que explote.')
    while not bombDefused and inGame do
        --print(bombDefused)
        local pId = PlayerPedId()
        local pIdCoords = GetEntityCoords(pId)
        local distance = #(GetEntityCoords(bomb) - pIdCoords)
        --print(distance)
        if distance < 3 then
            if distance <= 2 and IsControlJustReleased(0, 38) and not defusing then
                local dict, anim = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer"
                DPX.Streaming.RequestAnimDict(dict, function()
                    exports['pogressBar']:drawBar(DPS.DefuseTime, 'Desarmando bomba...')
                    TaskPlayAnim(pId, dict, anim, 2.0, 2.0, -1, 1, 0.0, false, false, false)
                    Citizen.Wait(DPS.DefuseTime)    
                    if IsEntityPlayingAnim(pId, dict, anim, 3) then
                        TriggerServerEvent("dps_VR:bombDefusedS")
                        ClearPedTasks(pId)            
                    end
                end)
            end
            if not shown then 
                TriggerEvent('cd_drawtextui:ShowUI', 'show', 'Manten <b>E</b> para desarmar la bomba')
                shown = true
            end
        else
            shown = false
            TriggerEvent('cd_drawtextui:HideUI')
        end
        Citizen.Wait(0)
    end
    activeBomb = false
    RemoveBlip(blip)
    TriggerEvent('cd_drawtextui:HideUI')
end)

RegisterNetEvent("dps_VR:bombDefused")
AddEventHandler("dps_VR:bombDefused", function()
    print("defusing")
    bombDefused = true
end)

RegisterNetEvent("dps_VR:explodeBomb")
AddEventHandler("dps_VR:explodeBomb", function(bombNid)
    local bomb = NetworkGetEntityFromNetworkId(bombNid)
    local bombCoords = GetEntityCoords(bomb)
    local x, y, z = table.unpack(bombCoords)
    print("BOOM")
    AddExplosion(x, y, z, 2, 10, true, false, true)
end)

RegisterNetEvent("dps_VR:lootSoldier")
AddEventHandler("dps_VR:lootSoldier", function(entity)
    if DoesEntityExist(entity) then
        DPX.Game.DeletePed(entity)
        TriggerServerEvent("dps_VR:giveSoldierEquipment")
    end
end)

RegisterNetEvent("dps_VR:terminateGame")
AddEventHandler("dps_VR:terminateGame", function(minimal)
    if not minimal then
        DoScreenFadeOut(1000)
        local semiMuerto, muertoTotal = exports['dps_safd']:isMuerto()
        if semiMuerto or muertoTotal then
            TriggerEvent("dps_safd:curar")
        else
            TriggerEvent('dps_safd:curaVida', 200)
            TriggerEvent('dps_safd:curarDamagePartes', {
                "piernaI",
                "piernaD",
                "brazoD",
                "brazoI",
                "torso",
                "cabeza"
            })
            TriggerEvent("dps_status:heal")
        end
        Citizen.Wait(1000)
        ExecuteCommand("rskin") -- LMAO
        DPX.Game.Teleport(PlayerPedId(), DPS.StartCoords, function()
            TriggerEvent("dps_VR2:changeInGame", false)
            DisplayRadar(false)
        end)
        DoScreenFadeIn(2000)
    else
        TriggerEvent("dps_VR2:changeInGame", false)
        DisplayRadar(false)
    end
end)

RegisterNetEvent('dps_VR:cprKitUse')
AddEventHandler('dps_VR:cprKitUse', function()
    if inGame then
        local personaCercana, distanciaPersona = DPX.Game.GetClosestPlayer()
        if personaCercana ~= -1 and distanciaPersona < 2.0 then 
            local targetPlayerId = GetPlayerServerId(personaCercana)
            DPX.TriggerServerCallback('dps_safd:isPlayerMuerto', function(estaMuerto)
                if estaMuerto then 
                    local pId = PlayerPedId()
                    exports['dps_notificaciones']:createNotify('inform', 'Has empezado a reanimar a la persona')
                    DPX.Streaming.RequestAnimDict('mini@cpr@char_a@cpr_str', function()
                        exports['pogressBar']:drawBar(7*900, 'Reanimando compañero...')
                        for i=1, 7 do
                            Citizen.Wait(900)
                            TaskPlayAnim(pId, 'mini@cpr@char_a@cpr_str', 'cpr_pumpchest', 8.0, -8.0, -1, 0, 0.0, false, false, false)
                        end
                        TriggerServerEvent('dps_safd:personaRevivida', targetPlayerId)
                    end)
                else 
                    exports['dps_notificaciones']:createNotify('error', 'La persona parece que está consciente')
                end
            end, targetPlayerId)
        else 
            exports['dps_notificaciones']:createNotify('error', 'No hay nadie cerca de ti')
        end
    else
        exports['dps_notificaciones']:createNotify('error', 'La realidad aumentada no esta activada')
    end
end)

RegisterNetEvent('dps_VR:ifakUse')
AddEventHandler('dps_VR:ifakUse', function()
    if inGame then
        DPX.Streaming.RequestAnimDict('missfam4', function()
            exports['pogressBar']:drawBar(10*350, 'Aplicando IFAK')
            local pId = PlayerPedId()
            TaskPlayAnim(pId, 'missfam4', 'base', 8.0, -8.0, -1, 49, 0.0, false, false, false)
            for i = 1, 10 do
                Citizen.Wait(350)
                if not IsEntityPlayingAnim(pId, 'missfam4', 'base', 3) then
                    TaskPlayAnim(pId, 'missfam4', 'base', 8.0, -8.0, -1, 49, 0.0, false, false, false)
                end
                SetEntityHealth(pId, GetEntityMaxHealth(pId)/20)
            end
            ClearPedTasks(pId)
        end)
    else
        exports['dps_notificaciones']:createNotify('error', 'La realidad aumentada no esta activada')
    end
end)

RegisterNetEvent("dps_VR:openMainMenu")
AddEventHandler("dps_VR:openMainMenu", function()
    if not inGame then
        local elements = {
            {label = "Crear Partida", value = 'create'},
            {label = 'Unirse Partida', value = 'join'},
            {label = 'Salir de la partida', value = 'leave_match'},
        }
        local menu = {title = "Menu", menutype = "list", items =  elements}
        TriggerEvent("dps_menu:createMenu", menu, function(opt)
            if opt then
                if opt == "create" then
                    createGame()
                elseif opt == "join" then
                    gameLobbys()
                elseif opt == "leave_match" then
                    TriggerServerEvent("dps_VR:leaveGame")
                end
            end
        end)
    end
end)

RegisterNetEvent("dps_VR:giveSoldierEquipment")
AddEventHandler("dps_VR:giveSoldierEquipment", function()
    TriggerServerEvent("dps_VR:giveSoldierEquipment")
end)

RegisterNetEvent("dps_VR:checkLeaderBoard")
AddEventHandler("dps_VR:checkLeaderBoard", function()
    openLeaderBoard()
end)

function hud()
    if inGame then
        Citizen.CreateThread(function()
            local startTime = GetGameTimer()
            local formatedTimeString = nil
            local bombTimer = nil
            local formatedTimeBombString = nil
            while inGame do
                Citizen.Wait(0)
                local timeSeconds = (GetGameTimer() - startTime)/1000.0
                local timeMinutes = math.floor(timeSeconds/60.0)
                timeSeconds = timeSeconds - 60.0*timeMinutes
                formatedTimeString = ("%02d:%06.3f"):format(timeMinutes, timeSeconds)
                local text = "Ronda "..globalRound .. "  |  ".. formatedTimeString
                if activeBomb then
                    if bombTimer == nil then
                        bombTimer = GetGameTimer()
                    end
                    timeSeconds =  (DPS.TotalBombTime/1000) - timeSeconds
                    timeMinutes = math.floor(timeSeconds/60.0)
                    timeSeconds = timeSeconds - 60.0*timeMinutes
                    formatedTimeBombString = ("%02d:%06.3f"):format(timeMinutes, timeSeconds)
                    Draw2DText(0.79, 0.94, "  |  " .. "~r~"..formatedTimeBombString, 0.7)
                end
                Draw2DText(0.7, 0.94, text, 0.7)
            end
            local timeMS = 0
            while timeMS < 1200 do
                timeMS = timeMS + 1
                Draw2DText(0.7, 0.94, formatedTimeString, 0.7)
                if timeMS%300 == 0 then
                    Citizen.Wait(450)
                end
                Citizen.Wait(0)
            end
            print("finished")
        end)
    end
end

function gameLobbys()
    DPX.TriggerServerCallback("dps_VR:getLobbyData", function(output)
        local elements = {}
        for k,v in pairs(output) do
            if v.status == "lobby" then
                table.insert(elements, {label = v.teamName .. " - ["..v.owner.name.."]" , value = v.owner.license})
            end
        end
        if #elements > 0 then
            local menu = {title = "Menu", menutype = "list", items =  elements}
            TriggerEvent("dps_menu:createMenu", menu, function(opt)
                if opt then
                    TriggerServerEvent("dps_VR:joinGame", opt)
                end
            end)
        else
            exports['dps_notificaciones']:createNotify('error', 'No se creo ninguna partida todavia.') 
        end
    end)
end

function openLeaderBoard()
    DPX.TriggerServerCallback("dps_VR:getLeaderBoardData", function(output)
        Citizen.Wait(300)
        local elements = {}
        table.sort(output, function(a,b) return tonumber(a.time) < tonumber(b.time) end)
        for k,v in pairs(output) do
            table.insert(elements, {label = k..".-"..v.teamName .. " - ["..disp_time(v.time).."]" , value = k})
        end
        if #output > 0 then
            local menu = {title = "Menu", menutype = "list", items =  elements}
            TriggerEvent("dps_menu:createMenu", menu, function(opt)
                if opt then
                    local elements2 = {}
                    local menu2 = {title = "Menu", menutype = "list", items =  elements2}
                    for _, player in pairs(json.decode(output[opt].team)) do
                        table.insert(elements2, {label = player.name, value = player.name})
                    end
                    TriggerEvent("dps_menu:createMenu", menu2, function(opt2)
                    end)
                end
            end)
        else
            exports['dps_notificaciones']:createNotify('error', 'No se ha clasificado nadie todavia.') 
        end
    end)
end

function createGame()
    local keyboard = exports["dps_input"]:KeyboardInput(
        {
            header = "Equipo", 
            rows = {
                {
                    id = 0, 
                    txt = 'Nombre del Equipo'
                },
            }
        })

        if keyboard ~= nil then
            if keyboard[1].input == nil then 
                exports['dps_notificaciones']:createNotify('error', 'Necesitas rellenar todos los datos')                     
            else 
                TriggerServerEvent("dps_VR:registerGame", keyboard[1].input)
            end
        end
end

function activeGamesMenu(type, games)
    local elements = {}
    for k,v in pairs(games) do
        table.insert(elements, {label = k, value = k})
    end
    local menu = {title = "Modos", menutype = "list", items =  elements}
    TriggerEvent("dps_menu:createMenu", menu, function(opt)
        if opt then
            local menu2 = {title = "Equipo", menutype = "list", items =  Config.Teams}
            TriggerEvent("dps_menu:createMenu", menu2, function(opt2)
                if opt2 then
                    TriggerServerEvent("dps_VR:joinGame", type, opt, opt2)
                end
            end)
        end
    end)
end

function Draw2DText(x, y, text, scale)
    -- Draw text on screen
    SetTextFont(4)
    SetTextProportional(7)
    SetTextScale(scale, scale)
    SetTextColour(255, 255, 255, 255)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextDropShadow()
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

function checkInGame()
    return inGame
end

function setVR()
    SetPedPropIndex(PlayerPedId(), 1, 37, 0, true)
end

function CreateBlip2(entity, name, sprite)
    local blip = AddBlipForEntity(entity)

    SetBlipSprite(blip, sprite)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 5)
    SetBlipDisplay(blip, 4)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(name)
    EndTextCommandSetBlipName(blip)

    return blip
end

RegisterCommand("vr", function()
    setVR()
end, false)
