--[[
    FakeGoldenPan.Lua
        
    Creates and then equips to current class a fake Professional Killstreak Strange Golden Frying Pan
    with a custom name, description, sheen, and killstreaker effect.

    github @ NoStir
    discord @ purrspire
    lmaobox forums @ TimLeary

    13 July 2025

    Public Release v1.0

    All rights relinquished to the public domain
]]

local me = entities.GetLocalPlayer()
if not me or not me:IsValid() then
    printc(255, 100, 100, 255, "[Error] Could not find the local player entity.")
end

-- =================================================================
-- CONFIGURATION
-- =================================================================

local ITEM_DEF_INDEX = 1071

local QUALITY_STRANGE = 11

local KILLSTREAK_TIER_PROFESSIONAL = 3
local SHEEN_DEADLY_DAFFODIL = 2 -- The ID for the "Deadly Daffodil" sheen.
local KILLSTREAKER_SINGULARITY = 2006 -- The ID for the "Singularity" killstreaker effect.

-- Custom Texts
local CUSTOM_NAME = "A semester's worth of College"
local CUSTOM_DESC = "...And a whole backpack full of unusuals."

-- =================================================================
-- SCRIPT LOGIC
-- Do not edit below unless you know what you are doing.
-- =================================================================

local itemDefinition = itemschema.GetItemDefinitionByID(ITEM_DEF_INDEX)

if not itemDefinition then
    printc(255, 100, 100, 255, "[Error] Could not find item definition for Index (ID: " .. tostring(ITEM_DEF_INDEX) .. ").")
    return
end

-- inventory.CreateFakeItem(itemdef, pickupMethod, itemID, quality, origin, level, isNewItem)
local fakePan = inventory.CreateFakeItem(itemDefinition, 0, -1, QUALITY_STRANGE, 0, 100, true)

if not fakePan or not fakePan:IsValid() then
    printc(255, 100, 100, 255, "[Error] Failed to create the fake item in the inventory.")
    return
end

-- Apply item attributes

fakePan:SetAttribute("killstreak tier", KILLSTREAK_TIER_PROFESSIONAL)
fakePan:SetAttribute("killstreak idleeffect", SHEEN_DEADLY_DAFFODIL)
fakePan:SetAttribute("killstreak effect", KILLSTREAKER_SINGULARITY)
fakePan:SetAttribute("turn to gold", 1)

fakePan:SetAttribute("custom name attr", CUSTOM_NAME)
fakePan:SetAttribute("custom desc attr", CUSTOM_DESC)

-- Equip the item to the player, if possible.
local pClass = me:GetPropInt("m_iClass")
if pClass then
    --inventory.EquipItemInLoadout( item:Item, classid:integer, slot:integer )
    inventory.EquipItemInLoadout(fakePan, pClass, E_LoadoutSlot.LOADOUT_POSITION_MELEE)
end

-- Confirm item create successful
printc(100, 255, 100, 255, "Successfully created fake '" .. fakePan:GetName() .. "'!")
printc(200, 200, 200, 255, "Check your inventory to see the item.")