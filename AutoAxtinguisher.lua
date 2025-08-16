--[[
    Axtinguisher Assist

    Description:
    When the configured key is pressed, this script checks if you are a Pyro
    with the Axtinguisher equipped. If so, it scans for nearby enemies who
    are on fire. If a valid target is found, it automatically switches to
    your melee weapon.

    How to Use:
    1. Save this file and load it in-game with `lua_load axtinguisher_assist.lua`.
    2. Change the `KEYBIND` variable below to your desired key.
    3. Press the key in-game when near a burning enemy.
]]

-- ========= CONFIGURATION =========

-- The key to press to activate the script.
-- A full list of key names can be found in the documentation under E_ButtonCode.
-- Examples: KEY_F, KEY_MOUSE4, KEY_CAPSLOCK
local KEYBIND = MOUSE_4

-- The maximum distance (in game units) to check for a burning enemy.
-- A player is about 72 units tall for reference.
local ACTIVATION_RANGE = 300.0

-- Item Definition Indexes for Axtinguisher-type weapons.
-- The script will work if any of these are equipped in the melee slot.
local AXTINGUISHER_DEF_INDEXES = {
    [38] = true,  -- The Axtinguisher
    [457] = true, -- The Postal Pummeler
}

-- ========= SCRIPT LOGIC (No need to edit below) =========

local function on_create_move(cmd)
    if not input.IsButtonDown(KEYBIND) then
        return
    end

    local me = entities.GetLocalPlayer()

    -- Exit if we're not in-game or are dead
    if not me or not me:IsValid() or not me:IsAlive() then
        return
    end

    -- 1. Check if the local player is a Pyro
    if me:GetPropInt("m_iClass") ~= TF2_Pyro then
        return
    end

    -- 2. Check if an Axtinguisher-type weapon is equipped in the melee slot
    local meleeWeapon = me:GetEntityForLoadoutSlot(LOADOUT_POSITION_MELEE)
    if not meleeWeapon or not meleeWeapon:IsValid() then
        return -- No valid melee weapon entity
    end

    local meleeDefIndex = meleeWeapon:GetPropInt("m_iItemDefinitionIndex")
    if not AXTINGUISHER_DEF_INDEXES[meleeDefIndex] then
        return -- The equipped melee weapon is not an Axtinguisher
    end
    
    -- All local player conditions met. Now, find a target.
    local myPos = me:GetAbsOrigin()
    local allPlayers = entities.FindByClass("CTFPlayer")

    for i, p in ipairs(allPlayers) do
        -- 3. Check if the entity is a valid, alive, non-dormant enemy
        if p:IsValid() and p:IsAlive() and not p:IsDormant() and p:GetTeamNumber() ~= me:GetTeamNumber() then
            
            -- 4. Check if the enemy is on fire
            if p:InCond(TFCond_OnFire) then
                
                -- 5. Check if the enemy is in close range
                local enemyPos = p:GetAbsOrigin()
                local distance = (myPos - enemyPos):Length()

                if distance <= ACTIVATION_RANGE then
                    -- Target found! Switch to melee.
                    printc(0, 255, 127, 255, "Axtinguisher Assist: Found burning enemy '", p:GetName(), "'. Switching to melee.")
                    
                    cmd.weaponselect = meleeWeapon:GetIndex()
                    
                    -- We found a target, no need to check other players
                    break
                end
            end
        end
    end
end

-- Register the callback
callbacks.Register("CreateMove", "AxtinguisherAssist", on_create_move)

local function meleeAim()
    local me = entities.GetLocalPlayer()
    if not me or not me:IsValid() or not me:IsAlive() then
        return
    end

    -- Get active weapon
    local activeWeapon = me:GetPropEntity("m_hActiveWeapon")
    if not activeWeapon or not activeWeapon:IsValid() then
        return
    end

    -- Check if the active weapon is a melee weapon
    if activeWeapon:IsMeleeWeapon() then
        gui.SetValue("aim key", 0) -- Disable aim key if melee weapon is active
        gui.SetValue("auto shoot", 1)
        return
    end

    -- If the active weapon is not a melee weapon, restore the aim key
    if not activeWeapon:IsMeleeWeapon() then
        gui.SetValue("aim key", KEY_LSHIFT)
        gui.SetValue("auto shoot", 0)
    end
    
end
callbacks.Register("Draw", "MeleeAim", meleeAim)

local function onStringCmd(stringCmd)
    local cmdStr = stringCmd:Get()
    if cmdStr == "dev" then
        stringCmd:Set("")
        client.Command("sv_cheats 1; mp_disable_respawn_times 1; mp_waitingforplayers_cancel 1; nb_blind 1; tf_bot_add; mp_teams_unbalance_limit 32", true)
    end
end

callbacks.Register("SendStringCmd", "DevCommandHandler", onStringCmd)

printc(0, 255, 0, 255, "Axtinguisher Assist script loaded. Press '", KEYBIND, "' to activate.")