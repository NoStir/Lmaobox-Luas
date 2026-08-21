--[[
AIM BOT
AIM KEY
AIM KEY MODE
AIM FOV
AIM METHOD
AIM POSITION
PRIORITY
AUTO SHOOT
SMOOTH VALUE
SMOOTH TYPE
PRESERVE TARGET
TARGET SWITCH DELAY (MS)
FIRST SHOT DELAY (MS)
PROJECTILE AIMBOT
PROJECTILE AIM FOV

PROJECTILE AIM METHOD
PREDICTION MODE
LEADING MODE

MELEE AIMBOT
MEDIGUN AIM
AIM WHEN RELOADING

NOSPREAD
NORECOIL

CRIT HACK
MELEE CRIT HACK
CRIT HACK KEY

-- #TARGET FILTER:
SENTRY
OTHER BUILDINGS
STICKIES
SENTRY BUSTER
NPC
-- #IGNORE FILTER:
STEAM FRIENDS
DEADRINGER
CLOAKED
DISGUISED
TAUNTING
BONKED
VACC UBERCHARGE

HEAL/BUFF WEAPONS
PREFER MEDICS
MINIGUN SPINUP
MINIGUN TAPFIRE
SNIPER: ZOOMED ONLY
SNIPER: AUTO ZOOM
WAIT FOR CHARGE
MINIMAL PRIORITY
SPREAD: MAX DISTANCE

BACKTRACK
BACKTRACK SIZE (TICKS)
FAKE LATENCY
FAKE LATENCY VALUE (MS)

DOUBLE TAP
DOUBLE TAP KEY
FORCE RECHARGE KEY
--]]

--[[
TRIGGER KEY

AUTO BACKSTAB
AUTO BACKSTAB FOV
DISGUISE AFTER ATTACK
IGNORE RAZORBACK
AUTO SAPPER
AUTO DETONATE STICKY
AUTO DETONATOR

AUTO AIRBLAST
IGNORE PROJECTILES

AUTO VACCINATOR
AUTO UBERCHARGE
HEALTH PERCENTAGE
'ACTIVATE UBER' TRIGGER

TRIGGER SHOOT
TRIGGER SHOOT KEY
TRIGGER MELEE
TRIGGER POSITION
TRIGGER SHOOT DELAY (MS)
SNIPER: SHOOT THRU TEAMMATES
]]

--[[
#ESP
PLAYERS
ENEMY ONLY
VISIBLE ONLY
FRIENDS
LOBBY MEMBERS
NAME
STEAM
HEALTH
WEAPON
UBERCHARGE
DISTANCE
CLASS
CONDITIONS
BOX
VIEW ANGLES
SKELETON
GLOW
GLOW STYLE
GLOW MODE
GLOW SIZE
GLOW WEAPON
LOCAL PLAYER
OFFSCREEN ARROWS
FAR ESP

ANTI-TAUNTING
ANTI-DISGUISE
HIDE CLOAKED
MINIMAL PRIORITY

BUILDINGS
BUILDINGS NAME
ENEMY ONLY
HEALTH
BOX
GLOW

AIM FOV RANGE
AIM FOV RANGE TRANSPARENCY
CRIT HACK INDICATOR SIZE
DOUBLE TAP INDICATOR SIZE
TEXT COLOR

BACKTRACK INDICATOR
BACKTRACK INDICATOR COLOR

BACKTRACK INDICATOR TRANSPARENCY

AMMO/MEDKIT
DROPPED AMMO
RESPAWN TIMERS
MVM MONEY
HALLOWEEN ITEM
HALLOWEEN SPELLS
HALLOWEEN PUMPKIN
POWER UPS
NPC
PROJECTILES
CAPTURE FLAG
#END ESP
]]

local varNameStrings = {
    --#AIMBOT
    --[["aim bot",
    "aim key",
    "aim key mode",
    "aim fov",
    "aim method",
    "aim position",
    "priority",
    "auto shoot",
    "smooth value",
    "smooth type",
    "preserve target",
    "target switch delay (ms)",
    "first shot delay (ms)",
    "projectile aimbot",
    "projectile aim fov",
    "projectile aim method",
    "prediction mode",
    "leading mode",
    "melee aimbot",
    "medigun aim",
    "aim when reloading",
    "nospread",
    "norecoil",
    "crit hack",
    "melee crit hack",
    "crit hack key",
    "sentry",
    "other buildings",
    "stickies",
    "sentry buster",
    "npc",
    "steam friends",
    "deadringer",
    "cloaked",
    "disguised",
    "taunting",
    "bonked",
    "vacc ubercharge",
    "heal/buff weapons",
    "prefer medics",
    "minigun spinup",
    "minigun tapfire",
    "sniper: zoomed only",
    "sniper: auto zoom",
    "wait for charge",
    "minimal priority",
    "spread: max distance",
    "backtrack",
    "backtrack size (ticks)",
    "fake latency",
    "fake latency value (ms)",
    "double tap",
    "double tap key",
    "force recharge key"--]]
    --[[#TRIGGER
    "trigger key",
    "auto backstab",
    "auto backstab fov",
    "disguise after attack",
    "ignore razorback",
    "auto sapper",
    "auto detonate sticky",
    "auto detonator",
    "auto airblast",
    "- ignore projectiles",
    "auto vaccinator",
    "auto ubercharge",
    "health percentage",
    "'activate uber' trigger",
    "trigger shoot",
    "trigger shoot key",
    "trigger melee",
    "trigger position",
    "trigger shoot delay (ms)",
    "sniper: shoot thru teammates"
    ]]
    -- #ESP
    "players",
    "enemy only",
    "visible only",
    "friends",
    "lobby members",
    "name",
    "steam",
    "health",
    "weapon",
    "ubercharge",
    "distance",
    "class",
    "conditions",
    "box",
    "view angles",
    "skeleton",
    "glow",
    "glow style",
    "glow mode",
    "glow size",
    "glow weapon",
    "local player",
    "offscreen arrows",
    "far esp",
    "anti-taunting",
    "anti-disguise",
    "hide cloaked",
    "minimal priority",
    "buildings",
    "buildings name",
    "enemy only",
    "health",
    "box",
    "glow",
    "aim fov range",
    "aim fov range transparency",
    "crit hack indicator size",
    "double tap indicator size",
    "text color",
    "backtrack indicator",
    "backtrack indicator color",
    "backtrack indicator transparency",
    "ammo/medkit",
    "dropped ammo",
    "respawn timers",
    "mvm money",
    "halloween item",
    "halloween spells",
    "halloween pumpkin",
    "power ups",
    "npc",
    "projectiles",
    "capture flag"

}

local function Get(var)
    return gui.GetValue(var)
end

-- Get all variable values and return them as a table of strings
-- explicitly mark where getting the value failed (e.g. for a non-existent variable) rather than returning nil or 0

local function GetAllValues()
    local values = {}
    for i, varName in ipairs(varNameStrings) do
        local success, value = pcall(Get, varName)
        if success then
            values[varName] = tostring(value)
        else
            values[varName] = "<failed to get value>"
        end
    end
    return values
end

-- Print all variable values to the console via print( msg )
local function PrintAllValues()
    local values = GetAllValues()
    for varName, value in pairs(values) do
        print(varName .. ": " .. value)
    end
end

--PrintAllValues()

local function SetAllVariables(value)
    for i, varName in ipairs(varNameStrings) do
        gui.SetValue(varName, value)
        
    end
end

SetAllVariables(0)
PrintAllValues()
