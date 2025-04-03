--[[
    Loadout Info Script
    -------------------
    Version: 2.0
    Author: Gemini 2.5 Pro Experimental 03-25, I mean uhhhhhhhhhh

    Description:
    This script prints detailed information about the local player's current
    ammo reserves and equipped weapons (Primary, Secondary, Melee).
    It features a modular design for easy reading, modification, and extension.

    Key Features:
    - Displays reserve ammo counts.
    - Shows detailed stats for Primary, Secondary, and Melee weapons.
    - Includes specific details for shooting, melee, and medigun weapon types.
    - Uses constants for easy configuration (colors, slots, etc.).
    - Robust error handling for missing entities or data.
    - Clear, modular structure with helper functions.
--]]

-- =============================================================================
-- Configuration & Constants
-- =============================================================================

local COLOR_RED    = { 255, 0, 0, 255 }
local COLOR_GREEN  = { 0, 255, 0, 255 }
local COLOR_YELLOW = { 255, 255, 0, 255 }
local INDENT       = "  "  -- Indentation string for key-value pairs

-- Loadout slot constants (using globals if available, with fallbacks)
local SLOT_PRIMARY   = LOADOUT_POSITION_PRIMARY or 0
local SLOT_SECONDARY = LOADOUT_POSITION_SECONDARY or 1
local SLOT_MELEE     = LOADOUT_POSITION_MELEE or 2
-- Add other slots here if needed (e.g., PDA = 3, Building = 4)

-- Default trace mask for line tracing (uses global if available)
-- MASK_SHOT_HULL is typically used for hitscan visibility checks.
local TRACE_MASK = MASK_SHOT_HULL or 0x400400B -- Fallback if MASK_SHOT_HULL isn't defined

-- =============================================================================
-- Helper Functions
-- =============================================================================

--- Prints a distinct section header with a specified color.
-- @param text The header text.
-- @param color A table {r, g, b, a}.
local function PrintSectionHeader(text, color)
    printc(color[1], color[2], color[3], color[4], "** " .. text .. " **")
end

--- Prints a key-value pair consistently, handling nil values and indentation.
-- @param key The label for the value.
-- @param value The value to print (will be converted to string).
-- @param indentStr Optional indentation string (defaults to no indent).
local function PrintKeyValue(key, value, indentStr)
    local prefix = indentStr or ""
    -- Ensure nil values are represented clearly
    local valueStr = (value ~= nil and tostring(value)) or "N/A"
    print(prefix .. key .. ": " .. valueStr)
end

-- =============================================================================
-- Information Display Modules
-- =============================================================================

--- Displays the player's reserve ammo counts from the m_iAmmo table.
-- @param localPlayer The local player entity.
local function PrintAmmoInfo(localPlayer)
    PrintSectionHeader("Ammo Reserves (m_iAmmo)", COLOR_RED)
    local ammoTable = localPlayer:GetPropDataTableInt("localdata", "m_iAmmo")

    if ammoTable then
        local hasSequentialAmmo = false
        -- ipairs only iterates over the sequential integer keys starting from 1
        for i, ammoCount in ipairs(ammoTable) do
            -- Mapping index 'i' to ammo type names requires external data/knowledge
            PrintKeyValue("Ammo Index " .. i, ammoCount, INDENT)
            hasSequentialAmmo = true
        end

        -- Check if the table might have non-sequential keys if ipairs found nothing
        if not hasSequentialAmmo then
            local hasAnyKey = false
            for _ in pairs(ammoTable) do hasAnyKey = true; break end -- Efficient check for any key

            if hasAnyKey then
                print(INDENT .. "Ammo table has non-sequential keys or starts indices > 1.")
                -- Consider adding a 'pairs' loop here if full dump is desired
            else
                print(INDENT .. "Ammo table is empty.")
            end
        end
    else
        print(INDENT .. "Could not retrieve ammo table (m_iAmmo).")
    end
    print() -- Add a blank line for visual separation
end

--- Displays information derived from the weapon's item definition schema.
-- @param itemDefinition The itemschema definition object.
-- @param weaponEntity The weapon entity (used for CanRandomCrit check).
local function PrintItemDefinitionInfo(itemDefinition, weaponEntity)
    local defName = itemDefinition:GetName() or "Unknown Definition"
    PrintSectionHeader("Item Definition: " .. defName, COLOR_YELLOW)
    PrintKeyValue("Class", itemDefinition:GetClass(), INDENT)
    PrintKeyValue("Loadout Slot Enum", itemDefinition:GetLoadoutSlot(), INDENT)
    PrintKeyValue("Type Name", itemDefinition:GetTypeName(), INDENT)
    PrintKeyValue("Description", itemDefinition:GetDescription(), INDENT)
    PrintKeyValue("Icon Name", itemDefinition:GetIconName(), INDENT)
    PrintKeyValue("Base Item Name", itemDefinition:GetBaseItemName(), INDENT)
    PrintKeyValue("Is Hidden", itemDefinition:IsHidden(), INDENT)
    PrintKeyValue("Is Tool", itemDefinition:IsTool(), INDENT)
    PrintKeyValue("Is Base Item", itemDefinition:IsBaseItem(), INDENT)
    PrintKeyValue("Is Wearable", itemDefinition:IsWearable(), INDENT)
    -- Check CanRandomCrit on the entity itself, as it can be affected by attributes
    if weaponEntity and weaponEntity:IsValid() then
        PrintKeyValue("Can Random Crit", weaponEntity:CanRandomCrit(), INDENT)
    end
end

--- Displays the weapon's current clip ammo (m_iClip1, m_iClip2).
-- @param weaponEntity The weapon entity.
-- @param weaponDefName The name of the weapon for context.
local function PrintWeaponClipInfo(weaponEntity, weaponDefName)
    local clip1 = weaponEntity:GetPropInt("LocalWeaponData", "m_iClip1")
    local clip2 = weaponEntity:GetPropInt("LocalWeaponData", "m_iClip2") -- Often unused (reserve ammo?) or specific (e.g., Beggar's Bazooka)

    PrintSectionHeader("Clip Ammo for " .. weaponDefName, COLOR_YELLOW)
    PrintKeyValue("Weapon Entity", weaponEntity, INDENT) -- Useful for debugging
    PrintKeyValue("m_iClip1 (Primary Clip)", clip1, INDENT)
    PrintKeyValue("m_iClip2 (Secondary/Reserve?)", clip2, INDENT)
end

--- Displays core weapon stats obtained from GetWeaponData().
-- @param wData The table returned by GetWeaponData().
-- @param weaponDefName The name of the weapon for context.
local function PrintWeaponStats(wData, weaponDefName)
    PrintSectionHeader("Base Weapon Stats (from GetWeaponData) for " .. weaponDefName, COLOR_YELLOW)
    PrintKeyValue("Damage", wData.damage, INDENT)
    PrintKeyValue("Bullets Per Shot", wData.bulletsPerShot, INDENT)
    PrintKeyValue("Range", wData.range, INDENT)
    PrintKeyValue("Spread", wData.spread, INDENT)
    PrintKeyValue("Punch Angle", wData.punchAngle, INDENT)
    PrintKeyValue("Fire Delay", wData.timeFireDelay, INDENT)
    PrintKeyValue("Idle Time", wData.timeIdle, INDENT)
    PrintKeyValue("Idle Time (Empty)", wData.timeIdleEmpty, INDENT)
    PrintKeyValue("Reload Start Time", wData.timeReloadStart, INDENT)
    PrintKeyValue("Reload Time", wData.timeReload, INDENT)
    PrintKeyValue("Draw Crosshair", wData.drawCrosshair, INDENT)
    PrintKeyValue("Projectile Entity Class", wData.projectile, INDENT) -- Often nil or a class name string
    PrintKeyValue("Ammo Per Shot", wData.ammoPerShot, INDENT)
    PrintKeyValue("Projectile Speed (Base)", wData.projectileSpeed, INDENT) -- May be overridden by attributes
    PrintKeyValue("Smack Delay (Melee)", wData.smackDelay, INDENT)
    PrintKeyValue("Use Rapid Fire Crits", wData.useRapidFireCrits, INDENT)
end

--- Displays specific details for weapons classified as 'Shooting Weapons'.
-- @param weaponEntity The weapon entity.
-- @param weaponDefName The name of the weapon for context.
local function PrintShootingWeaponInfo(weaponEntity, weaponDefName)
    if not weaponEntity:IsShootingWeapon() then
        print(INDENT .. weaponDefName .. " is not classified as a shooting weapon.")
        return
    end

    PrintSectionHeader("Shooting Weapon Details for " .. weaponDefName, COLOR_GREEN)
    -- Indent further for sub-section details
    local subIndent = INDENT .. INDENT
    PrintKeyValue("Projectile Type Enum", weaponEntity:GetWeaponProjectileType(), subIndent)
    PrintKeyValue("Current Spread", weaponEntity:GetWeaponSpread(), subIndent) -- Can change dynamically
    PrintKeyValue("Actual Projectile Speed", weaponEntity:GetProjectileSpeed(), subIndent) -- Can be modified by attributes
    PrintKeyValue("Projectile Gravity", weaponEntity:GetProjectileGravity(), subIndent)
    PrintKeyValue("Projectile Spread", weaponEntity:GetProjectileSpread(), subIndent) -- For multi-projectile shots
    PrintKeyValue("Loadout Slot ID", weaponEntity:GetLoadoutSlot(), subIndent) -- May differ from definition?
    PrintKeyValue("Weapon ID Enum", weaponEntity:GetWeaponID(), subIndent) -- TF_WEAPON_ enums
    PrintKeyValue("Is Viewmodel Flipped", weaponEntity:IsViewModelFlipped(), subIndent)
end

--- Displays specific details for weapons classified as 'Melee Weapons'.
-- @param weaponEntity The weapon entity.
-- @param weaponDefName The name of the weapon for context.
local function PrintMeleeWeaponInfo(weaponEntity, weaponDefName)
    if not weaponEntity:IsMeleeWeapon() then
        print(INDENT .. weaponDefName .. " is not classified as a melee weapon.")
        return
    end

    PrintSectionHeader("Melee Weapon Details for " .. weaponDefName, COLOR_GREEN)
    local subIndent = INDENT .. INDENT
    PrintKeyValue("Swing Range", weaponEntity:GetSwingRange(), subIndent)

    -- Simulate a swing trace to see what would be hit
    local traceResult = weaponEntity:DoSwingTrace() -- Assumes this function exists and returns a trace table
    PrintKeyValue("Swing Trace Hit Entity", traceResult.entity, subIndent)
    if traceResult.entity and traceResult.entity:IsValid() then
        PrintKeyValue("  -> Entity Class", traceResult.entity:GetClass(), subIndent)
        if traceResult.entity:IsPlayer() then
            PrintKeyValue("  -> Player Name", traceResult.entity:GetName(), subIndent)
        end
    else
        print(subIndent .. "  -> Swing trace would hit nothing.")
    end
    PrintKeyValue("Swing Trace Contents", traceResult.contents, subIndent) -- MASK_ flags hit
    PrintKeyValue("Swing Trace Hitbox", traceResult.hitbox, subIndent)     -- Hitbox index
    PrintKeyValue("Swing Trace Hitgroup", traceResult.hitgroup, subIndent) -- HITGROUP_ enum
end

--- Displays specific details for weapons classified as 'Mediguns'.
-- @param weaponEntity The weapon entity.
-- @param weaponDefName The name of the weapon for context.
-- @param localPlayer The local player entity (for self-heal check and tracing).
local function PrintMedigunInfo(weaponEntity, weaponDefName, localPlayer)
    if not weaponEntity:IsMedigun() then
        -- Don't print anything if not a medigun, avoids clutter
        return
    end

    PrintSectionHeader("Medigun Details for " .. weaponDefName, COLOR_GREEN)
    local subIndent = INDENT .. INDENT

    --- Local helper to check heal eligibility safely.
    local function CanHealTarget(target)
        -- Ensure target is valid before calling the potentially sensitive function
        return target and target:IsValid() and weaponEntity:IsMedigunAllowedToHealTarget(target) or false
    end

    PrintKeyValue("Heal Rate (Base)", weaponEntity:GetMedigunHealRate(), subIndent)
    PrintKeyValue("Heal Stick Range", weaponEntity:GetMedigunHealingStickRange(), subIndent)
    PrintKeyValue("Heal Detach Range", weaponEntity:GetMedigunHealingRange(), subIndent)
    PrintKeyValue("Can Heal Self", CanHealTarget(localPlayer), subIndent)

    -- Check what the player is looking at for potential heal target info
    local eyePos = localPlayer:GetAbsOrigin() + localPlayer:GetPropVector("localdata", "m_vecViewOffset[0]")
    local lookDir = engine.GetViewAngles():Forward()
    -- Use a reasonable trace distance for typical medigun range checks
    local traceEnd = eyePos + lookDir * (weaponEntity:GetMedigunHealingRange() or 1000) -- Use heal range or default
    local tr = engine.TraceLine(eyePos, traceEnd, TRACE_MASK)
    local targetEntity = tr.entity

    if targetEntity and targetEntity:IsValid() then
        PrintKeyValue("Target in Crosshair", targetEntity:GetClass(), subIndent)
        PrintKeyValue("  -> Can Heal Target", CanHealTarget(targetEntity), subIndent)
    else
        print(subIndent .. "No valid healable target in crosshair within range.")
    end
end

-- =============================================================================
-- Weapon Information Orchestrator
-- =============================================================================

--- Fetches data and calls relevant print functions for a single weapon entity.
-- @param weaponEntity The weapon entity to display info for.
-- @param weaponSlotName A descriptive name for the slot (e.g., "Primary").
-- @param localPlayer The local player entity (needed for Medigun check).
local function DisplayWeaponInfo(weaponEntity, weaponSlotName, localPlayer)
    PrintSectionHeader("Processing " .. weaponSlotName .. " Weapon Slot", COLOR_RED)

    -- Ensure the entity exists and is valid
    if not weaponEntity or not weaponEntity:IsValid() then
        print(INDENT .. "No valid weapon entity found in " .. weaponSlotName .. " slot.")
        print() -- Add separator line
        return
    end

    -- Attempt to get the Item Definition
    local itemDefinitionIndex = weaponEntity:GetPropInt("m_iItemDefinitionIndex")
    local itemDefinition = itemschema.GetItemDefinitionByID(itemDefinitionIndex)

    if not itemDefinition then
        print(INDENT .. "Could not retrieve item definition for " .. weaponSlotName .. " (Index: " .. tostring(itemDefinitionIndex) .. ")")
        -- Still print some basic info if definition fails
        PrintKeyValue("Weapon Entity", weaponEntity, INDENT)
        PrintWeaponClipInfo(weaponEntity, weaponSlotName .. " (Unknown Definition)")
        print() -- Add separator line
        return
    end

    -- Use definition name or fallback
    local weaponDefName = itemDefinition:GetName() or ("Unknown Weapon (" .. weaponSlotName .. ")")

    -- Attempt to get Weapon Data
    local weaponData = weaponEntity:GetWeaponData()
    if not weaponData then
        print(INDENT .. "Could not retrieve weapon data (GetWeaponData) for " .. weaponDefName)
        -- Still print definition info if available
        PrintItemDefinitionInfo(itemDefinition, weaponEntity)
        print() -- Add separator line
        return
    end

    -- Print all available information sections for this weapon
    PrintItemDefinitionInfo(itemDefinition, weaponEntity)
    PrintWeaponClipInfo(weaponEntity, weaponDefName)
    PrintWeaponStats(weaponData, weaponDefName)
    PrintShootingWeaponInfo(weaponEntity, weaponDefName)
    PrintMeleeWeaponInfo(weaponEntity, weaponDefName)
    PrintMedigunInfo(weaponEntity, weaponDefName, localPlayer)

    print() -- Add a blank line for visual separation after each weapon
end

-- =============================================================================
-- Main Execution
-- =============================================================================

-- Get the local player entity
local localPlayer = entities.GetLocalPlayer()

-- Early exit if the local player cannot be found
if not localPlayer or not localPlayer:IsValid() then
    printc(COLOR_RED[1], COLOR_RED[2], COLOR_RED[3], COLOR_RED[4], "Error: Local player entity not found or invalid. Cannot retrieve loadout info.")
    return
end

-- Print the main header
PrintSectionHeader("===== Loadout Information for " .. localPlayer:GetName() .. " =====", COLOR_YELLOW)
print()

-- 1. Display Ammo Information
PrintAmmoInfo(localPlayer)

-- 2. Retrieve Weapon Entities for Standard Slots
local primaryWeapon   = localPlayer:GetEntityForLoadoutSlot(SLOT_PRIMARY)
local secondaryWeapon = localPlayer:GetEntityForLoadoutSlot(SLOT_SECONDARY)
local meleeWeapon     = localPlayer:GetEntityForLoadoutSlot(SLOT_MELEE)
-- Add other slots here if desired (e.g., pda, building)
-- local pdaWeapon       = localPlayer:GetEntityForLoadoutSlot(LOADOUT_POSITION_PDA or 3)

-- 3. Display Detailed Information for Each Weapon
DisplayWeaponInfo(primaryWeapon, "Primary", localPlayer)
DisplayWeaponInfo(secondaryWeapon, "Secondary", localPlayer)
DisplayWeaponInfo(meleeWeapon, "Melee", localPlayer)
-- DisplayWeaponInfo(pdaWeapon, "PDA", localPlayer)

-- Print the main footer
PrintSectionHeader("===== Loadout Information End =====", COLOR_YELLOW)