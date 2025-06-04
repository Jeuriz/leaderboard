local QBCore = exports['qb-core']:GetCoreObject()
local isLeaderboardOpen = false
local spawnedProps = {}
local createdBlips = {}

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

-- Función para spawnar props
local function SpawnProp(location)
    if not location.prop then return nil end
    
    local prop = CreateObject(GetHashKey(location.prop), location.coords.x, location.coords.y, location.coords.z, false, false, false)
    SetEntityHeading(prop, location.propHeading or 0.0)
    PlaceObjectOnGroundProperly(prop)
    FreezeEntityPosition(prop, true)
    SetEntityInvincible(prop, true)
    
    return prop
end

-- Función para crear blips
local function CreateBlip(location)
    if not Config.CreateBlips then return nil end
    
    local blip = AddBlipForCoord(location.coords.x, location.coords.y, location.coords.z)
    SetBlipSprite(blip, Config.BlipSettings.sprite)
    SetBlipColour(blip, Config.BlipSettings.color)
    SetBlipScale(blip, Config.BlipSettings.scale)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.BlipSettings.name)
    EndTextCommandSetBlipName(blip)
    
    return blip
end

-- Función para configurar ox_target
local function SetupOxTarget()
    if not Config.UseOxTarget then return end
    
    for i, location in ipairs(Config.TargetLocations) do
        local targetOptions = {
            {
                name = 'zombie_leaderboard_' .. i,
                icon = location.icon,
                label = location.label,
                onSelect = function()
                    OpenLeaderboard()
                end,
                distance = location.distance
            }
        }
        
        -- Crear el target zone
        exports.ox_target:addSphereZone({
            coords = location.coords,
            radius = location.distance,
            options = targetOptions
        })
        
        -- Spawnar prop si está configurado
        if Config.SpawnProps and location.prop then
            local prop = SpawnProp(location)
            if prop then
                table.insert(spawnedProps, prop)
            end
        end
        
        -- Crear blip si está configurado
        local blip = CreateBlip(location)
        if blip then
            table.insert(createdBlips, blip)
        end
    end
end

-- Función para limpiar props y blips
local function CleanupResources()
    -- Eliminar props spawneados
    for _, prop in ipairs(spawnedProps) do
        if DoesEntityExist(prop) then
            DeleteEntity(prop)
        end
    end
    spawnedProps = {}
    
    -- Eliminar blips creados
    for _, blip in ipairs(createdBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    createdBlips = {}
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

-- Inicializar ox_target cuando el recurso se cargue
CreateThread(function()
    Wait(1000) -- Esperar a que otros recursos se carguen
    SetupOxTarget()
end)

-- Limpiar recursos cuando el recurso se detenga
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        CleanupResources()
        if isLeaderboardOpen then
            CloseLeaderboard()
        end
    end
end)
