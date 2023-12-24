DPS = {}

DPS.MaxGroups = 5

DPS.SpawnPerPlayer = 2

DPS.maxRounds = 20

DPS.VRRecompensa = 2

DPS.StartTimeout = 1000*20

DPS.DefuseTime = 1000*10

DPS.TicketPrice = 500

DPS.TotalBombTime = 1000*60*2 -- 2 mins

DPS.DeletePedsAfterRounds = 2

DPS.StartCoords = vector3(-1048.589,-238.046,43.021)

DPS.Respawn = {
    vector4(900.729,-3216.827,-99.232,168.395),
    vector4(896.403,-3217.916,-99.227,248.21),
    vector4(895.102,-3219.76,-99.227,237.352),
    vector4(899.314,-3215.812,-99.227,173.593),
    vector4(902.492,-3217.561,-99.237,132.697)
}

DPS.EnemyRespawn = {
    vector4(943.123,-3229.483,-99.294,94.844),
    vector4(940.17,-3199.053,-99.264,153.827),
    vector4(919.764,-3198.114,-99.262,200.046),
    vector4(893.728,-3246.267,-99.263,54.782),
    vector4(834.462,-3229.734,-99.574,233.884),
    vector4(874.461,-3197.275,-97.695,177.36)
}

DPS.EnemyBomb = {
    vector4(837.757,-3239.254,-99.699,330.094),
    vector4(934.107,-3238.706,-99.297,90.952)
}

DPS.InitialLoadout = {
    {item = "WEAPON_HEAVYPISTOL", qt = 1, idItem = true},
    {item = "cargadorP", qt = 4, idItem = false},
    {item = "ifak", qt = 2, idItem = false}
}

DPS.RoundEquipment = {
    {`weapon_pistol`},
    {`weapon_pistol`, `weapon_combatpistol`},
    {`weapon_pistol`, `weapon_combatpistol`},
    {`weapon_combatpistol`, `weapon_pistol50`},
    {`weapon_combatpistol`, `weapon_pistol50`},
    {`weapon_microsmg`, `weapon_pistol50`},
    {`weapon_microsmg`, `weapon_pistol50`},
    {`weapon_microsmg`, `weapon_smg`},
    {`weapon_microsmg`, `weapon_smg`},
    {`weapon_compactrifle`, `weapon_smg`},
    {`weapon_compactrifle`, `weapon_smg`},
    {`weapon_compactrifle`, `weapon_carbinerifle`},
    {`weapon_compactrifle`, `weapon_carbinerifle`},
    {`weapon_combatshotgun`, `weapon_assaultsmg`, `weapon_assaultrifle`},
    {`weapon_combatshotgun`, `weapon_assaultsmg`, `weapon_assaultrifle`},
    {`weapon_bullpupshotgun`, `weapon_assaultsmg`, `weapon_bullpuprifle`},
    {`weapon_bullpupshotgun`, `weapon_assaultsmg`, `weapon_bullpuprifle`},
    {`weapon_mg`, `weapon_assaultrifle_mk2`, `weapon_rpg`, `weapon_assaultshotgun`},
    {`weapon_mg`, `weapon_assaultrifle_mk2`, `weapon_rpg`, `weapon_assaultshotgun`},
    {`weapon_mg`, `weapon_assaultrifle_mk2`, `weapon_rpg`, `weapon_assaultshotgun`},
}

DPS.Shop = {
    {name = 'ifak',                     price = 1},
    {name = 'cprKit',                   price = 1},
    {name = 'chalecopesado',            price = 2},
    {name = 'cargadorP',                price = 1},
    {name = 'cargadorS',                price = 2},
    {name = 'cargadorR',                price = 2},
    {name = 'cargadorE',                price = 3},
    {name = 'cargadorPA',               price = 2},
    {name = 'cargadorSA',               price = 3},
    {name = 'cargadorRA',               price = 3},
    {name = 'cargadorEA',               price = 4},
    {name = 'ammo_box100',              price = 5},
    {name = "cajaCartuchos",            price = 7},
    {name = 'WEAPON_SMG',               price = 13},
    {name = 'WEAPON_ASSAULTRIFLE',      price = 17},
    {name = 'WEAPON_BULLPUPSHOTGUN',    price = 20},
    
}

-- 0 = Malo
-- 1 = Bueno
-- 2 = s1mple
DPS.EnemiesAbility = {
    [1] =  0,
    [2] =  0,
    [3] =  1,
    [4] =  1,
    [5] =  1,
    [6] =  1,
    [7] =  2,
    [8] =  2,
    [9] =  2,
    [10] = 2,
}

DPS.Enemies = {`mp_m_bogdangoon`, `s_m_y_blackops_01`, `s_m_y_blackops_02`, `s_m_y_blackops_03`}

DPS.JuggerNaut = {`u_m_y_juggernaut_01`}

DPS.SoldierDrop = {
    {name = "ammo_box",                 prob = 20},
    {name = "vrCoins",                  prob = 60},
    {name = "ifak",                     prob = 80},
    {name = "WEAPON_GRENADE",           prob = 85},
    {name = "WEAPON_SAWNOFFSHOTGUN",    prob = 90},
    {name = "WEAPON_MICROSMG",          prob = 95},
    {name = "WEAPON_CARBINERIFLE_MK2",  prob = 100},
}

--- SHARED FUNCTIONS

function disp_time(time)
    local hours = math.floor(time/3600)
    local remaining = time % 3600
    local minutes = math.floor(remaining/60)
    remaining = remaining % 60
    local seconds = remaining
    if (hours < 10) then
        hours = "0" .. tostring(hours)
    end
    if (minutes < 10) then
        minutes = "0" .. tostring(minutes)
    end
    if (seconds < 10) then
        seconds = "0" .. tostring(seconds)
    end
    answer = hours..':'..minutes..':'..seconds
    return answer
end
