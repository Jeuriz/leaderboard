Config = {}

Config.Commands = {
    openLeaderboard = 'zombieleaderboard', -- Comando para abrir el leaderboard
    resetStats = 'resetzombiestats' -- Comando para resetear estadísticas
}

Config.Permissions = {
    reset = 'admin' -- Permiso necesario para resetear stats
}

Config.DefaultIcon = '🧟' -- Icono por defecto
Config.MaxDisplayPlayers = 10 -- Máximo de jugadores a mostrar

-- Configuración de ox_target
Config.UseOxTarget = true -- Habilitar/deshabilitar ox_target
Config.SpawnProps = true -- Spawnar props en las ubicaciones

Config.TargetLocations = {
    {
        coords = vector3(-1037.8, -2738.0, 20.2), -- Legion Square
        heading = 0.0,
        prop = 'prop_laptop_01a', -- Prop a spawnar (opcional)
        propHeading = 180.0,
        label = '🧟 Ver Leaderboard de Zombies',
        icon = 'fas fa-trophy',
        distance = 2.0
    },
    {
        coords = vector3(213.8, -810.4, 31.0), -- Ayuntamiento
        heading = 0.0,
        prop = 'prop_laptop_01a',
        propHeading = 270.0,
        label = '🧟 Ranking de Eliminaciones',
        icon = 'fas fa-skull',
        distance = 2.0
    },
    {
        coords = vector3(1854.9, 3686.5, 34.3), -- Sandy Shores
        heading = 0.0,
        prop = 'prop_laptop_01a',
        propHeading = 90.0,
        label = '🧟 Top Zombie Slayers',
        icon = 'fas fa-chart-line',
        distance = 2.0
    }
}

-- Configuración del blip (opcional)
Config.CreateBlips = true
Config.BlipSettings = {
    sprite = 280,
    color = 1,
    scale = 0.8,
    name = "Zombie Leaderboard"
}

--[[
    NUEVO SISTEMA DE CATEGORÍAS:
    
    El leaderboard ahora maneja tres categorías diferentes:
    
    1. INFECTADOS (🧟) - Zombies básicos/normales
    2. MUTANTES (👹) - Zombies mutados/especiales  
    3. BOSS (💀) - Jefes zombies
    
    EXPORTACIONES DISPONIBLES DESDE EL CLIENTE:
    
    exports['leaderboard']:AddInfectado(cantidad)    -- Agregar infectados eliminados
    exports['leaderboard']:AddMutante(cantidad)      -- Agregar mutantes eliminados
    exports['leaderboard']:AddBoss(cantidad)         -- Agregar boss eliminados
    exports['leaderboard']:SetPlayerIcon(icon)       -- Cambiar icono del jugador
    
    EXPORTACIONES DISPONIBLES DESDE EL SERVIDOR:
    
    exports['leaderboard']:AddInfectado(source, cantidad)
    exports['leaderboard']:AddMutante(source, cantidad)
    exports['leaderboard']:AddBoss(source, cantidad)
    exports['leaderboard']:SetPlayerIcon(source, icon)
    exports['leaderboard']:GetPlayerStats(source)
    
    COMANDOS DE PRUEBA:
    
    /testinfectado - Agrega 1 infectado eliminado
    /testmutante   - Agrega 1 mutante eliminado
    /testboss      - Agrega 1 boss eliminado
    
    EJEMPLO DE USO:
    
    -- En tu script de zombies, cuando un jugador mate un zombie:
    
    if zombieType == "infectado" then
        exports['leaderboard']:AddInfectado(1)
    elseif zombieType == "mutante" then
        exports['leaderboard']:AddMutante(1)
    elseif zombieType == "boss" then
        exports['leaderboard']:AddBoss(1)
    end
]]
