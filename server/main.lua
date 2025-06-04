local QBCore = exports['qb-core']:GetCoreObject()
local dataFile = 'zombie_stats.json'

-- Función para cargar datos del JSON
local function LoadData()
    local file = LoadResourceFile(GetCurrentResourceName(), dataFile)
    if file then
        local data = json.decode(file)
        return data or {}
    end
    return {}
end

-- Función para guardar datos al JSON
local function SaveData(data)
    SaveResourceFile(GetCurrentResourceName(), dataFile, json.encode(data, {indent = true}), -1)
end

-- Función para obtener el leaderboard ordenado
local function GetSortedLeaderboard()
    local data = LoadData()
    local leaderboard = {}
    
    for citizenid, playerData in pairs(data) do
        table.insert(leaderboard, {
            citizenid = citizenid,
            name = playerData.name,
            kills = playerData.kills,
            icon = playerData.icon or Config.DefaultIcon
        })
    end
    
    -- Ordenar por kills de mayor a menor
    table.sort(leaderboard, function(a, b)
        return a.kills > b.kills
    end)
    
    -- Limitar a los primeros Config.MaxDisplayPlayers
    local result = {}
    for i = 1, math.min(#leaderboard, Config.MaxDisplayPlayers) do
        result[i] = leaderboard[i]
    end
    
    return result
end

-- Callback para obtener el leaderboard
QBCore.Functions.CreateCallback('zombie-leaderboard:server:getLeaderboard', function(source, cb)
    local leaderboard = GetSortedLeaderboard()
    cb(leaderboard)
end)

-- Comando para abrir el leaderboard
QBCore.Commands.Add(Config.Commands.openLeaderboard, 'Abrir el leaderboard de zombie kills', {}, false, function(source, args)
    TriggerClientEvent('zombie-leaderboard:client:openLeaderboard', source)
end)

-- Comando para resetear estadísticas (solo admins)
QBCore.Commands.Add(Config.Commands.resetStats, 'Resetear todas las estadísticas de zombie kills', {}, false, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    
    if QBCore.Functions.HasPermission(source, Config.Permissions.reset) then
        SaveData({})
        TriggerClientEvent('QBCore:Notify', source, 'Todas las estadísticas de zombie kills han sido reseteadas', 'success')
        TriggerClientEvent('zombie-leaderboard:client:refreshLeaderboard', -1)
    else
        TriggerClientEvent('QBCore:Notify', source, 'No tienes permisos para usar este comando', 'error')
    end
end, Config.Permissions.reset)

-- EVENTOS DEL SERVIDOR (para llamadas desde el cliente)
-- Event para agregar kills desde el cliente
RegisterNetEvent('zombie-leaderboard:server:addKill', function(amount)
    local source = source
    exports['leaderboard']:AddZombieKill(source, amount or 1)
end)

-- Event para establecer icono desde el cliente
RegisterNetEvent('zombie-leaderboard:server:setIcon', function(icon)
    local source = source
    exports['leaderboard']:SetPlayerIcon(source, icon)
end)

-- Exportación para agregar kills
exports('AddZombieKill', function(source, amount)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    local citizenid = Player.PlayerData.citizenid
    local playerName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
    
    local data = LoadData()
    
    if not data[citizenid] then
        data[citizenid] = {
            name = playerName,
            kills = 0,
            icon = Config.DefaultIcon
        }
    end
    
    data[citizenid].kills = data[citizenid].kills + (amount or 1)
    data[citizenid].name = playerName -- Actualizar nombre en caso de cambio
    
    SaveData(data)
    
    -- Notificar al jugador
    TriggerClientEvent('QBCore:Notify', source, 'Zombie eliminado! Total: ' .. data[citizenid].kills, 'success')
    
    -- Refrescar leaderboard para todos los jugadores que lo tengan abierto
    TriggerClientEvent('zombie-leaderboard:client:refreshLeaderboard', -1)
    
    return true
end)

-- Exportación para establecer el icono de un jugador
exports('SetPlayerIcon', function(source, icon)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    local citizenid = Player.PlayerData.citizenid
    local data = LoadData()
    
    if data[citizenid] then
        data[citizenid].icon = icon or Config.DefaultIcon
        SaveData(data)
        TriggerClientEvent('zombie-leaderboard:client:refreshLeaderboard', -1)
        return true
    end
    
    return false
end)

-- Exportación para obtener las stats de un jugador
exports('GetPlayerStats', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return nil end
    
    local citizenid = Player.PlayerData.citizenid
    local data = LoadData()
    
    return data[citizenid] or {
        name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        kills = 0,
        icon = Config.DefaultIcon
    }
end)
