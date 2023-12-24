DPX = nil
local games = {}
local prePlayers = {}
local leaderBoard = {}
local lastInstance = 3

TriggerEvent('dpx:getSharedObject', function(obj) DPX = obj end)

RegisterNetEvent('dps_safd:personaRevivida')
AddEventHandler('dps_safd:personaRevivida', function(pIdTarget)
    local xPlayer = DPX.GetPlayerBasicFromId(pIdTarget)
    if xPlayer and prePlayers[xPlayer.identifier] then
        local xGame = games[prePlayers[xPlayer.identifier]]
        if xGame then
            xGame.changePlayerStatus(xPlayer.identifier, "Alive")
        end
    end
end)

MySQL.ready(function()
    sqlInventoryUpdateUsuariosOffline()
    sqlFetchResult()
end)


RegisterNetEvent("dps_VR:registerGame")
AddEventHandler("dps_VR:registerGame", function(teamName)
    local pSource = source
    local xPlayer = DPX.GetPlayerBasicFromId(pSource)
    local license = xPlayer.identifier
    local xGame = games[license]
    if not xGame then
        local owner =  {license = license, pSource = pSource, name = xPlayer.name} -- Create Basic player table
        games[license] = CreateGame(owner, lastInstance + 1, teamName)
        lastInstance = lastInstance + 1
        xGame = games[license]
        xGame.addTeamMember(license)
        TriggerClientEvent('dps_notificaciones:createNotify', pSource, {type = 'success', text = "Has creado una lobby"})
    else
        TriggerClientEvent('dps_notificaciones:createNotify', pSource, {type = 'error', text = "Has creado ya una lobby."})
        -- Game ya creado
    end
end)

RegisterNetEvent("dps_VR:joinGame")
AddEventHandler("dps_VR:joinGame", function(license)
    local pSource = source
    local xGame = games[license]
    local xTarget = DPX.GetPlayerFromIdentifier(license)
    local xPlayer = DPX.GetPlayerFromId(pSource)
    if xGame then
        local joinStatus = xGame.addTeamMember(xPlayer.identifier)
        if joinStatus then
            TriggerClientEvent('dps_notificaciones:createNotify', pSource, {type = 'success', text = "Te has unido al Game de "..xTarget.name})
        else
            TriggerClientEvent('dps_notificaciones:createNotify', pSource, {type = 'error', text = "Error, al unirte al Game de "..xTarget.name})
            -- error al unirse, equipo lleno 
        end
    else
        TriggerClientEvent('dps_notificaciones:createNotify', pSource, {type = 'error', text = "Error, el game al que intentas unirte no existe"})
        -- Game no existe
    end
end)

RegisterNetEvent("dps_VR:leaveGame")
AddEventHandler("dps_VR:leaveGame", function()
    local pSource = source
    local xPlayer = DPX.GetPlayerFromId(pSource)
    local xGame = games[xPlayer.identifier]
    if xGame then
        local xTarget = DPX.GetPlayerFromIdentifier(xGame.owner.license)
        local leaveStatus = nil
        if xGame.status == "lobby" then
            leaveStatus = xGame.removeTeamMember(xPlayer.identifier)
        else
            leaveStatus = xGame.eliminatePlayer(xPlayer.identifier)
        end
        
        if leaveStatus then
            prePlayers[xPlayer.identifier] = nil
            TriggerClientEvent("dps_VR:terminateGame", pSource, true)
            TriggerClientEvent('dps_notificaciones:createNotify', pSource, {type = 'success', text = "Te has salido de la partida "..xTarget.name})
            if #xGame.team == 0 then
                games[xPlayer.identifier] = nil
            end
        else
            TriggerClientEvent('dps_notificaciones:createNotify', pSource, {type = 'error', text = "Error, al salirte de la partida de "..xTarget.name})
            -- error al unirse, equipo lleno 
        end
    else
        TriggerClientEvent('dps_notificaciones:createNotify', pSource, {type = 'error', text = "Error, el game delm que intentas salir no existe"})
        -- Game no existe
    end
end)

RegisterNetEvent("dps_VR:startGameS")
AddEventHandler("dps_VR:startGameS", function()
    local pSource = source
    local xPlayer = DPX.GetPlayerFromId(pSource)
    local xGame = games[xPlayer.identifier]
    if xGame then
        local startStatus = xGame.startGame()
        if startStatus then
            TriggerClientEvent('dps_notificaciones:createNotify', pSource, {type = 'success', text = "Has iniciado el game "})
        else
            TriggerClientEvent('dps_notificaciones:createNotify', pSource, {type = 'error', text = "Error, al empezar el game"})
            -- error al unirse, equipo lleno 
        end
    else
        TriggerClientEvent('dps_notificaciones:createNotify', pSource, {type = 'error', text = "Error, no tienes ningun game empezado."})
        -- Game no existe
    end
end)

RegisterNetEvent("dps_VR:deleteGame")
AddEventHandler("dps_VR:deleteGame", function(license)
    local pSource = source
    local xPlayer = DPX.GetPlayerBasicFromId(pSource)
    local xGame = games[license]
    xGame.terminateGame()
    games[license] = nil
end)

RegisterNetEvent("dps_VR:resetInventory")
AddEventHandler("dps_VR:resetInventory", function(pSource)
    if pSource == nil then
        pSource = source
    end
    local xPlayer = DPX.GetPlayerFromId(pSource)
    TriggerEvent("dps_armas:desmontarTodo", pSource)
    Citizen.Wait(1000)
    local inventory = xPlayer.getInventoryWithoutId()
    local inventoryID = xPlayer.getInventoryWithId(true)

    for k,v in pairs(inventory) do
        xPlayer.removeInventoryItem(k, v)
    end
    print("Inventario sin ID Reseted de : ".. xPlayer.name)
    for k,v in pairs(inventoryID) do
        xPlayer.removeInventoryItemById(v.name, v.id, true)
    end
    print("Inventario con ID Reseted de : ".. xPlayer.name)
    sqlInventoryDelete(xPlayer.identifier)
    prePlayers[xPlayer.identifier] = nil
    print("Inventario Reseteado de : ".. xPlayer.name)
end)

RegisterNetEvent("dps_VR:giveSoldierEquipment")
AddEventHandler("dps_VR:giveSoldierEquipment", function()
    local anterior = 0
    local itemsADar = 3
    local pSource = source
    local probability = math.random(0,100)
    local xPlayer = DPX.GetPlayerFromId(pSource)
    for i = 1, 3, 1 do
        for k,v in pairs(DPS.SoldierDrop) do
            if probability < v.prob and probability >= anterior  then
                local itemTable = DPX.Items[v.name]
                if itemTable.is_stackable == 1 then
                    local qt = math.random(1,4)
                    TriggerClientEvent('dps_notificaciones:createNotify', pSource, {type = 'success', text = "Has encontrado ".. xPlayer.getInventoryItem(v.name).label.. " x"..qt})
                    xPlayer.addInventoryItem(v.name, qt)
                else
                    local item2 = DPX.CreateItemId(itemTable.name, xPlayer.source)
                    xPlayer.addInventoryItemById(item2)
                    TriggerClientEvent('dps_notificaciones:createNotify', pSource, {type = 'success', text = "Has encontrado un "..itemTable.name})
                end
                break
            end
        end
        anterior = 0
    end
end)

RegisterNetEvent("dps_VR:setPlayerStatus")
AddEventHandler("dps_VR:setPlayerStatus", function(status)
    local pSource = source
    local xPlayer = DPX.GetPlayerBasicFromId(pSource)
    local xGame = games[prePlayers[xPlayer.identifier]]
    if xGame then
        xGame.changePlayerStatus(xPlayer.identifier, status)
    end
end)

RegisterNetEvent("dps_VR:giveInitialGear")
AddEventHandler("dps_VR:giveInitialGear", function(pSource, gameIdentifier)
    if pSource == nil then
        pSource = source
    end
    local xPlayer = DPX.GetPlayerFromId(pSource)
    prePlayers[xPlayer.identifier] = gameIdentifier
    sqlInventoryInsert(xPlayer.identifier)
    for k,v in pairs(DPS.InitialLoadout) do
        if v.idItem == false then
            xPlayer.addInventoryItem(v.item, v.qt)
        else
            local item2 = DPX.CreateItemId(v.item, xPlayer.source)
            xPlayer.addInventoryItemById(item2)
        end
    end
end)

RegisterNetEvent("dps_VR:setUpShop")
AddEventHandler("dps_VR:setUpShop", function(item, count)
    local pSource = source
    local xPlayer = DPX.GetPlayerFromId(pSource)
    if xPlayer.getInventoryItem("vrCoins").count >= item.price*count then
        if string.find(item.name, "WEAPON") == nil then
            xPlayer.removeInventoryItem("vrCoins", item.price*count)
            xPlayer.addInventoryItem(item.name, count)
        else
            xPlayer.removeInventoryItem("vrCoins", item.price)
            local item2 = DPX.CreateItemId(item.name, xPlayer.source)
            xPlayer.addInventoryItemById(item2)
        end
        TriggerClientEvent('dps_notificaciones:createNotify', pSource, {type = 'success', text = "Has comprado un ".. xPlayer.getInventoryItem(item.name).label})
    else
        TriggerClientEvent('dps_notificaciones:createNotify', pSource, {type = 'error', text = "No tienes suficientes monedas."})
    end
end)

RegisterNetEvent("dps_VR:destroyGame")
AddEventHandler("dps_VR:destroyGame", function(license)
    games[license] = nil
end)

RegisterNetEvent("dps_VR:eliminatePlayer")
AddEventHandler("dps_VR:eliminatePlayer", function()
    local pSource = source
    local xPlayer = DPX.GetPlayerBasicFromId(pSource)
    local license = xPlayer.identifier
    local gameID = prePlayers[license]
    local xGame = games[gameID]
    xGame.eliminatePlayer(license) 
end)

RegisterNetEvent("dps_VR:bombDefusedS")
AddEventHandler("dps_VR:bombDefusedS", function()
    local pSource = source
    local xPlayer = DPX.GetPlayerBasicFromId(pSource)
    local license = xPlayer.identifier
    local gameID = prePlayers[license]
    local xGame = games[gameID]
    xGame.bombDefused() 
end)

RegisterNetEvent("dps_VR:destroyGame")
AddEventHandler("dps_VR:destroyGame", function(license)
    games[license] = nil
end)

DPX.RegisterServerCallback("dps_VR:getLobbyData", function(source, cb)
    local returnTable = {}
    for k,v in pairs(games) do
        local insertTable = v.returnBasicGame()
        table.insert(returnTable, insertTable)
    end
    cb(returnTable)
end)

DPX.RegisterServerCallback("dps_VR:getLeaderBoardData", function(source, cb)
    cb(leaderBoard)
end)

TriggerEvent('cron:runAt', 10, 30, function()
	local day = tonumber(os.date("%d", os.time()))
	if os.date("%a") == "Mon" then
        sqlElectWinners()
    end
end)


function CreateGame(owner, instancia, teamName)
    self = {}

    self.owner = owner
    self.status = "lobby"
    self.teamName = teamName
    self.instancia = instancia
    self.win = false
    self.bombStatus = "stopped"
    self.round = 0
    self.team = {}
    self.enemies = {}
    self.bombs = {}
    self.times = {
        t1 = nil, 
        t2 = nil,
        tT = nil,
    }
    
    self.addTeamMember = function(license)
        if #self.team <= DPS.MaxGroups and self.status == "lobby" then
            local xPlayer = DPX.GetPlayerFromIdentifier(license)  --Maybe BASIC LOL
            if xPlayer and xPlayer.getAccount('bank').money >= DPS.TicketPrice then
                xPlayer.removeAccountMoney('bank', DPS.TicketPrice)
                for k,v in pairs(self.team) do -- Check if the license is already in the team.
                    if v.license == license then
                        return false -- Already in the team
                    end
                end
                local player =  {license = license, pSource = xPlayer.source, name = xPlayer.name, state = "Alive"} -- Create Basic player table
                prePlayers[license] = self.owner.license
                table.insert(self.team, player) -- Beacuse license does not match, we add it
                return true
            else
                return false
            end
        else
            return false
        end
    end
    
    self.changePlayerStatus = function(license, state)
        for k,v in pairs(self.team) do
            if v.license == license then
                v.state = state
                break
            end
        end
        self.checkTeamStatus()
    end
    
    self.checkTeamStatus = function(license)
        local dead = 0
        for k,v in pairs(self.team) do
            if v.state ~= "Alive" then
                dead = dead + 1
            end
        end
        if dead == #self.team then
            self.terminateGame()
        end
    end

    self.removeTeamMember = function(license)
        for k,v in pairs(self.team) do
            if v.license == license then
                self.team[k] = nil
                if self.status == "lobby" then
                    local xPlayer = DPX.GetPlayerFromIdentifier(license)
                    xPlayer.addAccountMoney('bank', DPS.TicketPrice)
                end
                return true
            end
        end
        return false
    end

    self.eliminatePlayer = function(license)
        local xPlayer = DPX.GetPlayerBasicFromId()
        for k,v in pairs(self.team) do
            if v.license == license then
                TriggerEvent("dps_VR:resetInventory", v.pSource)
                self.removeTeamMember(license)
                return true
            end
        end 
    end
    
    self.getTeamMembers = function()
        return self.team
    end
    
    self.startGame = function()
        if self.status == "lobby" then
            self.status = "inGame"
            updateTotalFile(#self.team*DPS.TicketPrice)
            for _, player in pairs(self.team) do
                local xPlayer = DPX.GetPlayerFromId(player.pSource)
                xPlayer.setBucket(self.instancia)
                TriggerEvent("dps_VR:resetInventory", player.pSource)
                Citizen.SetTimeout(1000, function()
                    TriggerEvent("dps_VR:giveInitialGear", player.pSource, self.owner.license)
                end)
                TriggerClientEvent("dps_VR:startGameTimeout", player.pSource, DPS.StartTimeout, true, DPS.Respawn[_])
            end
            self.times.t1 = os.time()
            local qt = readTotalFile()
            Citizen.SetTimeout(DPS.StartTimeout + DPS.StartTimeout/2, function()
                self.spawnEnemies(DPS.maxRounds)
            end)
            return true
        else
            return false
        end
    end

    self.terminateGame = function()
        self.times.t2 = os.time()
        self.times.tT = self.times.t2 - self.times.t1 
        self.status = "ended"
        local formatedTime = disp_time(self.times.tT)
        if self.win then
            local insertTable = {}
            for k,v in pairs(self.team) do
                table.insert(insertTable, {license = v.license, name = v.name})
            end
            sqResultInsert(insertTable, self.times.tT,  self.teamName)
            table.insert(leaderBoard, {team = insertTable, teamName = self.teamName, time, self.times.tT})
            if #leaderBoard > 2 then
                table.sort(leaderBoard, function(a,b) return a.time < b.time end)
            end
        end
        for _,player in pairs(self.team) do
            local xPlayer = DPX.GetPlayerFromId(player.pSource)
            xPlayer.setBucket(0)
            TriggerEvent("dps_VR:resetInventory", player.pSource)
            TriggerClientEvent("dps_VR:terminateGame", player.pSource)
            if self.win then
                TriggerClientEvent('dps_notificaciones:createNotify', player.pSource, {type = 'success', text = "Duracion de la partida: ["..formatedTime.."]"})
            else
                TriggerClientEvent('dps_notificaciones:createNotify', player.pSource, {type = 'error', text = "GAME LOSE"})
            end
        end
        self.deleteTotalEnemies()
        TriggerEvent("dps_VR:destroyGame", self.owner.license)
    end

    self.returnBasicGame = function()
        local retTable = {
            status = self.status,
            team = self.team,
            owner = self.owner,
            teamName = self.teamName
        }
        return retTable
    end
    
    self.giveRoundCoins = function(pSource)
        local xPlayer = DPX.GetPlayerFromId(pSource)
        if xPlayer then
            xPlayer.addInventoryItem("vrCoins", DPS.VRRecompensa)
        end
    end

    self.startBomb = function()
        local coords = DPS.EnemyBomb[math.random(1, #DPS.EnemyBomb)]
        local x, y, z, w = table.unpack(coords)
        local bomb = CreateObject(`hei_prop_carrier_ord_01`, x, y, z, true, true, false)
        Citizen.Wait(500)
        SetEntityHeading(bomb, w)
        SetEntityRoutingBucket(bomb, self.instancia)
        self.bombStatus = "timing"
        for _, player in pairs(self.team) do
            TriggerClientEvent("dps_VR:startMission", player.pSource, NetworkGetNetworkIdFromEntity(bomb))
        end
        Citizen.SetTimeout(DPS.TotalBombTime, function()
            if self.bombStatus == "defused" then
                for _, player in pairs(self.team) do
                    self.giveRoundCoins(player.pSource)
                end
            else
                for _, player in pairs(self.team) do
                    TriggerClientEvent("dps_VR:explodeBomb", player.pSource, NetworkGetNetworkIdFromEntity(bomb))
                end
                Citizen.Wait(3000)
                self.terminateGame()
            end
        end)
        table.insert(self.bombs, bomb)
    end

    self.bombDefused = function() 
        self.bombStatus = "defused"
        for _, player in pairs(self.team) do
            TriggerClientEvent("dps_VR:bombDefused", player.pSource)
        end
    end

    self.spawnEnemies = function(maxRounds)
        for round = 1, maxRounds, 1 do
            self.round = round
            if self.bombStatus == "stopped" and maxRounds/2 <= round and (math.random(1,100) <= 20 or self.round == maxRounds) then
                self.startBomb()
            end

            self.enemies[round] = {}
            local enemieCount = 0
            local deleteRoundEnemies = 0
            while enemieCount <= DPS.SpawnPerPlayer*DPS.MaxGroups or self.bombStatus == "timing" do
                local aliveEnemies = self.checkAliveEnemiesRound(self.round) 
                if aliveEnemies <= 40 then
                    local ped = self.spawnEnemy(round, maxRounds)
                    table.insert(self.enemies[round], NetworkGetNetworkIdFromEntity(ped)) 
                    enemieCount = enemieCount + 1
                    if #self.enemies[round]%10 == 0 then
                        self.sendAgressive(self.enemies[round])
                        Citizen.Wait(3000)
                    elseif #self.enemies[round]%30 ~= 0 and #self.enemies[round] > 0 then
                        deleteRoundEnemies = self.deleteRoundDeadEnemies(self.round)
                    end
                elseif aliveEnemies > 70 then             
                    Citizen.Wait(5000)
                end
                Citizen.Wait(100)
                if self.status == "ended" then
                    break
                end
            end

            while self.checkAliveEnemiesRound(self.round) ~= 0 do
                Citizen.Wait(1000)
            end

            local deleteRound = self. round - DPS.DeletePedsAfterRounds
            if deleteRound >= 1 then -- If the diference between the round and the initial round  is +1 then it means index exists
                self.deleteRoundEnemies(deleteRound)  -- Delete enemies in that index
            end

            if self.round ~= maxRounds then
                for _, player in pairs(self.team) do
                    self.giveRoundCoins(player.pSource)
                    TriggerClientEvent("dps_VR:startGameTimeout", player.pSource, 5000)
                end
                Citizen.Wait(DPS.StartTimeout + 4000)
            end

            if self.status == "ended" then
                break
            end
        end

        if self.status ~= "defused" and self.bombStatus then
            self.win = true
            self.terminateGame()
        end
    end

    self.spawnEnemy = function(round, maxRounds)
        local ped = nil
        local spawnPos = DPS.EnemyRespawn[math.random(1, #DPS.EnemyRespawn)]
        local x, y, z, w = table.unpack(spawnPos)
        if round >= maxRounds/2 and math.random(0,100) > 60 then
            ped = CreatePed(4, DPS.JuggerNaut[math.random(1, #DPS.JuggerNaut)], x, y, z, w, true, true)
            Citizen.Wait(50)
            local roundEquipment = `WEAPON_MINIGUN`
            GiveWeaponToPed(ped,  roundEquipment, 500, false, true)
            SetCurrentPedWeapon(ped, roundEquipment, true)
        else
            ped = CreatePed(4, DPS.Enemies[math.random(1, #DPS.Enemies)], x, y, z, w, true, true)
            Citizen.Wait(50)
            local roundEquipment = DPS.RoundEquipment[round][math.random(1, #DPS.RoundEquipment[round])] 
            GiveWeaponToPed(ped,  roundEquipment, 500, false, true)
            SetCurrentPedWeapon(ped, roundEquipment, true)
        end
        SetEntityRoutingBucket(ped, self.instancia)
        return ped
    end

    self.sendAgressive = function(tempTable)
        for __, player in pairs(self.team) do  -- Hacemos que los NPCs se vuelvan locos
            TriggerClientEvent("dps_VR:setAgrressive", player.pSource, tempTable, self.round) 
        end
    end

    self.checkAliveEnemiesRound = function(round)
        local count = 0
        if self.enemies[round] then
            if #self.enemies[round] > 0 then
                for _, npc in pairs(self.enemies[round]) do 
                    if GetEntityHealth(NetworkGetEntityFromNetworkId(npc)) > 0 then
                        count = count + 1
                    end
                end
            end
        end
        --print("Enemigos Vivos: ", count)
        return count

    end

    self.deleteRoundDeadEnemies = function(round)
        local count = 0
        if #self.enemies[round] > 0 then
            for _, npc in pairs(self.enemies[round]) do
                local npcE = NetworkGetEntityFromNetworkId(npc)
                Citizen.Wait(10)
                if GetEntityHealth(npcE) == 0 then
                    local try = 0
                    while DoesEntityExist(npcE) and try < 10 do
                        try = try + 1
                        DeleteEntity(npcE)
                        Citizen.Wait(10)
                    end
                    if not DoesEntityExist(npcE) then
                        count = count + 1
                        npc = nil
                    end
                end
            end
            print("BORRADOS: "..count)
        end
        return count

    end

    self.deleteRoundEnemies = function(round)
        if #self.enemies[round] > 0 then
            for _, npc in pairs(self.enemies[round]) do
                local try = 0
                local npcE = NetworkGetEntityFromNetworkId(npc)
                while DoesEntityExist(npcE) and try < 10 do
                    try = try + 1
                    npc = nil
                    DeleteEntity(npcE)
                    Citizen.Wait(10)
                end
            end
        end

    end

    self.deleteTotalEnemies = function()
        for round, _ in pairs(self.enemies) do
            if #self.enemies[round] >= 1 then
                for __, npc in pairs(self.enemies[round]) do
                    local try = 0
                    local npcE = NetworkGetEntityFromNetworkId(npc)
                    while DoesEntityExist(npcE) and try < 10 do
                        try = try + 1
                        DeleteEntity(npcE)
                        Citizen.Wait(10)
                    end
                end
            end
            self.enemies[round] = nil
        end
    end

    return self
end

function sqlElectWinners()
    local emptyTable = {}
    local totalPrize = readTotalFile()
    MySQL.query("SELECT MIN(time) FROM vrscore", {}, function(result)
        if result then
            for _, player in pairs(result) do
                local xPlayer = DPX.GetPlayerFromIdentifier(player.license)
                if xPlayer then
                    xPlayer.addAccountMoney('bank', 1)
                else
                    MySQL.query("SELECT accounts FROM usuarios WHERE identifier = @identifier", {
                        ["@identifier"] = player.license,
                    }, function(result2)
                        if result2 then
                            local accounts = result2
                            accounts.bank = accounts.bank + totalPrize/#result
                            MySQL.query("UPDATE usuarios SET accounts = @accounts WHERE identifier = @identifier",
                            {
                                ["@accounts"] = json.decode(accounts),
                            },
                            function(rowsChanged)
                            end)
                        end
                    end)
                end
                Citizen.Wait(100)
            end
            MySQL.query('DELETE FROM vrscore', {}, function(rowsChanged)
                if rowsChanged.affectedRows > 0 then 
                    print("Borrado!")
                end
            end)
            resetTotalFile()
        end
    end)
end

function sqlInventoryInsert(identifier)
    print(type(identifier))
    MySQL.insert('INSERT INTO vrinventories (identifier) VALUES (@identifier)', {
        ['@identifier'] = identifier
    },
    function(succes)
        if succes then
            print("Success!")
        end
    end)
end

function sqResultInsert(data, time, teamName)
    print(type(data), type(teamName), type(json.encode(data)))
    MySQL.insert('INSERT INTO vrscore (team, time, teamName) VALUES (@team, @time, @teamName)', {
        ['@team'] = json.encode(data),
        ['@time'] = tonumber(time),
        ['@teamName'] = teamName,
    },
    function(succes)
        if succes then
            print("Success!")
        end
    end)
end

function sqlFetchResult()
    MySQL.query("SELECT * FROM vrscore", {}, function(result)
        if result then
            leaderBoard = result
            if #leaderBoard >= 2 then
                table.sort(leaderBoard, function(a,b) return a.time < b.time end)
            end
            --print(json.encode(leaderBoard, {indent = true}))
        end
    end)
end

function sqlInventoryUpdateUsuariosOffline()
    local emptyTable = {}
    MySQL.query("SELECT * FROM vrinventories", {}, function(result)
        if result then
            for _, insert in pairs(result) do
                MySQL.query("UPDATE usuarios SET loadout = @loadout, inventory = @inventory WHERE identifier = @identifier",
                {
                    ["@inventory"] = json.encode(emptyTable),
                    ["@loadout"] = json.encode(emptyTable),
                    ["@identifier"] = insert.identifier,
                },
                function(rowsChanged)
                    sqlInventoryDelete(insert.identifier)
                end)
                Citizen.Wait(200)
            end
        end
    end)
end

function sqlInventoryDelete(identifier)
    MySQL.query('DELETE FROM vrinventories WHERE identifier = @identifier',
    {
        ['@identifier'] = identifier, 
    },
    function(rowsChanged)
        if rowsChanged.affectedRows > 0 then 
            print("Borrado!")
        end
    end)
end

function readTotalFile()
	local f, err = io.open('VRResults.txt',"r")
	if not f then return print(err) end
    local data = f:read()
	f:close()
    return data
end

function updateTotalFile(number)
    resetTotalFile()
    Citizen.Wait(100)
	local f, err = io.open("VRResults.txt","a")
	if not f then return print(err) end
    local formattedlog = number
	f:write(formattedlog)
	f:close()
end

function resetTotalFile()
    io.open('VRResults.txt',"w"):close()
    return data
end

AddEventHandler('dpx:onUsecprKit', function(pId)
    local pSource = pId    
    local xPlayer = DPX.GetPlayerFromId(pSource)
    if xPlayer then
        xPlayer.removeInventoryItem("cprKit", 1)
        TriggerClientEvent("dps_VR:cprKitUse", pSource)
    end
end)

AddEventHandler('dpx:onUseifak', function(pId)
    local pSource = pId    
    local xPlayer = DPX.GetPlayerFromId(pSource)
    if xPlayer then
        xPlayer.removeInventoryItem("ifak", 1)
        TriggerClientEvent("dps_VR:ifakUse", pSource)
    end
end)

AddEventHandler('dpx:onUsecajaCartuchos', function(pId)
    local pSource = pId    
    local xPlayer = DPX.GetPlayerFromId(pSource)
    if xPlayer then
        xPlayer.removeInventoryItem("cajaCartuchos", 1)
        xPlayer.addInventoryItem("cartucho", 20)
        TriggerClientEvent("dps_VR:ifakUse", pSource)
    end
end)

--[[ Citizen.CreateThread(function()
    while true do
        print("PLAYER ROUTIUNE:", GetPlayerRoutingBucket(1))
        Citizen.Wait(1000)
    end
end) ]]