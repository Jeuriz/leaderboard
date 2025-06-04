
local QBCore = exports['qb-core']:GetCoreObject()
local isLeaderboardOpen = false

-- Función para abrir el leaderboard
local function OpenLeaderboard()
    if isLeaderboardOpen then return end
    
    QBCore.Functions.TriggerCallback('zombie-leaderboard:server:getLeaderboard', function(leaderboard)
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'openLeaderboard',
            leaderboard = leaderboard
        })
        isLeaderboardOpen = true
    end)
end

-- Función para cerrar el leaderboard
local function CloseLeaderboard()
    if not isLeaderboardOpen then return end
    
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'closeLeaderboard'
    })
    isLeaderboardOpen = false
end

-- Event para abrir el leaderboard
RegisterNetEvent('zombie-leaderboard:client:openLeaderboard', function()
    OpenLeaderboard()
end)

-- Event para refrescar el leaderboard
RegisterNetEvent('zombie-leaderboard:client:refreshLeaderboard', function()
    if isLeaderboardOpen then
        QBCore.Functions.TriggerCallback('zombie-leaderboard:server:getLeaderboard', function(leaderboard)
            SendNUIMessage({
                action = 'updateLeaderboard',
                leaderboard = leaderboard
            })
        end)
    end
end)

-- EXPORTACIONES DEL CLIENTE
-- Exportación para agregar kills desde el cliente
exports('AddZombieKill', function(amount)
    TriggerServerEvent('zombie-leaderboard:server:addKill', amount or 1)
end)

-- Exportación para establecer icono desde el cliente
exports('SetPlayerIcon', function(icon)
    TriggerServerEvent('zombie-leaderboard:server:setIcon', icon)
end)

-- Callback del NUI para cerrar
RegisterNUICallback('closeLeaderboard', function(data, cb)
    CloseLeaderboard()
    cb('ok')
end)

-- Tecla para abrir/cerrar leaderboard (opcional)
RegisterCommand('+zombieleaderboard', function()
    if isLeaderboardOpen then
        CloseLeaderboard()
    else
        OpenLeaderboard()
    end
end)

RegisterCommand('-zombieleaderboard', function() end)

-- Ejemplo de uso de la exportación
RegisterCommand('testzombiekill', function()
    exports['leaderboard']:AddZombieKill(GetPlayerServerId(PlayerId()), 1)
end)
