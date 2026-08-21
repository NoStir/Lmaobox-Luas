-----------------------
-- Machina Penetration
-----------------------

-----------------------
-- CONFIG / DRAW UTILS
-----------------------
local HUD_X      = 40    -- Horizontal offset from left
local HUD_Y      = 300   -- Vertical offset from top
local HUD_COLOR  = {255, 255, 255, 255}
local BG_COLOR   = {0, 0, 0, 160}
local FONT = nil

local function DrawSimpleText(x, y, text, bgColor, txtColor)
    draw.Color(table.unpack(bgColor))
    local w, h = draw.GetTextSize(text)
    draw.FilledRect(x - 2, y - 2, x + w + 2, y + h + 2)
    draw.Color(table.unpack(txtColor))
    draw.Text(x, y, text)
end

-----------------------
-- SCRIPT VARIABLES
-----------------------
local me          = nil
local shotReady   = false
local playerReady = false
local lastStatus  = "Idle"

-----------------------
-- HELPER FUNCTIONS
-----------------------
local function IsLocalPlayerReady()
    me = entities.GetLocalPlayer()
    if not me or not me:IsValid() or not me:IsAlive() then
        lastStatus = "Not alive or invalid local player."
        return false
    end

    -- Check current weapon
    local weapon = me:GetPropEntity("m_hActiveWeapon")
    if not weapon or not weapon:IsValid() then
        lastStatus = "No valid active weapon."
        return false
    end

    -- Must be The Machina
    local wDefIndex = weapon:GetPropInt("m_iItemDefinitionIndex")
    if not wDefIndex or type(wDefIndex) ~= "number" then
        lastStatus = "No weapon definition index."
        return false
    end
    local wDef = nil
    if itemschema and itemschema.GetItemDefinitionByID then
        wDef = itemschema.GetItemDefinitionByID(wDefIndex)
    end
    if not wDef or wDef:GetBaseItemName() ~= "The Machina" then
        lastStatus = "Not using The Machina."
        return false
    end

    -- Must be zoomed (sniper scope)
    if not me:InCond(TFCond_Zoomed) then
        lastStatus = "Not zoomed."
        return false
    end

    -- Must have at least 150 charged damage
    local charge = 0
    if weapon and weapon:IsValid() then
        charge = weapon:GetPropFloat("m_flChargedDamage") or 0
    end
    if charge < 150 then
        lastStatus = string.format("Insufficient charge: %.1f", charge)
        return false
    end
    if firstEnemyClass and lastStatus ~= "One enemy found: " .. firstEnemyClass then
        lastStatus = "Ready to fire (Machina)."
    end
    return true
end

-- In some cheat frameworks, returning TRUE = “collide with this entity”
-- and returning FALSE = “skip/ignore this entity.” 
-- We must figure out which logic your environment uses.
local function EnemyFilter(ent)
    if not me then
        return false
    end
    
    if ent and ent:IsValid() and ent:GetClass() == "CTFPlayer" then
        -- skip local player
        if ent:GetIndex() == me:GetIndex() then
            return false
        end
        -- otherwise, collide => a player that is not the local player
        return true
    end
    -- not a valid enemy => skip
    return false
end

local function SecondEnemyFilter(ent, firstEnemyIndex)
    if not me or not me:IsValid() then
        return false
    end
    if ent and ent:IsValid() and ent:GetClass() == "CTFPlayer" then
        -- skip local player
        if ent:GetIndex() == me:GetIndex() then
            return false
        end
        -- skip teammates
        if ent:GetTeamNumber() == me:GetTeamNumber() then
            return false
        end
        -- skip the same entity we already hit
        if ent:GetIndex() == firstEnemyIndex then
            return false
        end
        return true  -- collide => a different enemy
    end
    return false
end

local function PerformMachinaTraces()

    if not me or not me:IsValid() then
        lastStatus = "Invalid local player."
        return
    end
    -- Get necessary info for the trace
    local angles  = engine.GetViewAngles()
    local src     = me:GetAbsOrigin() + me:GetPropVector("localdata", "m_vecViewOffset[0]")
    local forward = angles:Forward()
    local dst     = src + forward * 9999

    -- First trace
    local trace1  = engine.TraceLine(src, dst, MASK_SHOT, EnemyFilter)
    -- If we got no hit or invalid entity, bail
    if not trace1 or not trace1.entity or not trace1.entity:IsValid() or trace1.entity:GetClass() ~= "CTFPlayer" or trace1.entity:GetTeamNumber() == me:GetTeamNumber() then
        lastStatus = "No enemies found (first trace)."
        return false
    end
    -- We found one enemy
    local firstEnemy = trace1.entity
    local firstEnemyClass = firstEnemy:GetClass()
    lastStatus = "One enemy found: " .. firstEnemyClass

    -- Now trace from just beyond that collision
    local afterImpact = trace1.endpos + forward * 2

    local trace2 = engine.TraceLine(afterImpact, dst, MASK_SHOT, 
        function(e) return SecondEnemyFilter(e, firstEnemy:GetIndex()) end)

    if trace2 and trace2.entity and trace2.entity:IsValid() and trace2.entity:GetClass() == "CTFPlayer" and trace2.entity:GetTeamNumber() ~= me:GetTeamNumber() then
        -- We found a second enemy
        lastStatus = "Two enemies aligned! Firing..."
        return true
    else
        return false, firstEnemyClass
    end
end
    
callbacks.Register("CreateMove", function(cmd)
    if shotReady then
        cmd:SetButtons(cmd.buttons | IN_ATTACK)
        shotReady = false
    end
end)

-- Simple HUD / status and main logic
callbacks.Register("Draw", function()
    if not FONT then
        FONT = draw.CreateFont("Tahoma", 16, 400)
    end
    draw.SetFont(FONT)
    DrawSimpleText(HUD_X, HUD_Y, "Machina Status: " .. (lastStatus or ""), BG_COLOR, HUD_COLOR)
    if not IsLocalPlayerReady() then
        return
    end

    if PerformMachinaTraces() then
        -- We found two enemies aligned, fire!
        shotReady = true
    end
end)