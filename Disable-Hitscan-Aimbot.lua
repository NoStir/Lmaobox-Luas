--[[
    Script: Active Weapon Type Based Aimbot Configurator
    Description: Sets the aimbot ON or OFF based on the player's active weapon type.
]]

local function getActiveWeaponType()
    local player = entities.GetLocalPlayer()
    if not (player and player:IsValid() and player:IsAlive()) then
        return "invalid_player"
    end

    local weapon = player:GetPropEntity("m_hActiveWeapon")
    if not (weapon and weapon:IsValid()) then
        return "invalid_weapon"
    end

    if weapon:IsMeleeWeapon() then
        return "melee"
    end

    if weapon:IsShootingWeapon() then
        local projectileTypeInt = weapon:GetWeaponProjectileType()
        if projectileTypeInt == 1 then
            return "hitscan"
        elseif projectileTypeInt == 0 then
            return "flamethrower"
        elseif projectileTypeInt ~= nil then
            return "projectile"
        else
            return "shooting_generic"
        end
    end
    return "other_non_shooting"
end


-- Store the last known weapon entity index to detect changes
local lastActiveWeaponIndex = -1
local lastWeaponTypeProcessed = ""

-- Desired aimbot states: 1 for ON, 0 for OFF
local desiredAimbotStateForType = {
    ["hitscan"]            = 0, -- Aimbot OFF for hitscan
    ["projectile"]         = 1, -- Aimbot ON for projectiles
    ["melee"]              = 1, -- Aimbot ON for melee
    ["flamethrower"]       = 1, -- Aimbot ON for flamethrowers
    ["shooting_generic"]   = 0, -- Aimbot OFF for other shooting
    ["other_non_shooting"] = 1, -- Aimbot ON for Mediguns etc.
    ["invalid_player"]     = 0, -- Default to OFF for invalid states
    ["invalid_weapon"]     = 0  -- Default to OFF for invalid states
}

local function configureAimbotOnWeaponType(cmd)
    local player = entities.GetLocalPlayer()
    if not (player and player:IsValid()and player:IsAlive()) then
        if lastWeaponTypeProcessed ~= "invalid_player" then
            local currentAimbotValue = gui.GetValue("aim bot")
            local desiredState = desiredAimbotStateForType["invalid_player"]
            if currentAimbotValue ~= desiredState then
                gui.SetValue("aim bot", desiredState)
            end
            lastWeaponTypeProcessed = "invalid_player"
            lastActiveWeaponIndex = -1
        end
        return
    end

    local weapon = player:GetPropEntity("m_hActiveWeapon")
    local currentWeaponIndex = -1
    if weapon and weapon:IsValid() then
        currentWeaponIndex = weapon:GetIndex()
    end

    -- Only re-evaluate if the weapon has changed or if it's the first run
    if currentWeaponIndex ~= lastActiveWeaponIndex or lastWeaponTypeProcessed == "" then
        local weaponType = getActiveWeaponType()
        lastWeaponTypeProcessed = weaponType -- Update the processed type

        local desiredState = desiredAimbotStateForType[weaponType]
        if desiredState == nil then -- Fallback for any new unmapped weaponType
            print("LUA: Unhandled weaponType for aimbot config: " .. weaponType)
            desiredState = 0 -- Default to OFF
        end

        local currentAimbotValue = gui.GetValue("aim bot")

        if currentAimbotValue ~= desiredState then
            print("LUA: Weapon type '" .. weaponType .. "' detected. Setting aimbot to: " .. tostring(desiredState))
            gui.SetValue("aim bot", desiredState)
        end
        lastActiveWeaponIndex = currentWeaponIndex
    end
end

callbacks.Register("CreateMove", "ConfigureAimbotOnWeapon", configureAimbotOnWeaponType)

local function onUnload()
    callbacks.Unregister("CreateMove", "ConfigureAimbotOnWeapon")
    print("LUA: Projectile Type Based Aimbot Configurator script unloaded.")
end
callbacks.Register("Unload", "UnloadConfigureAimbot", onUnload)

print("LUA: Projectile Type Based Aimbot Configurator script loaded.")