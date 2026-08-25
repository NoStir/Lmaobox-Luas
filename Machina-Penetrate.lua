--[[ Auto Machina Penetrate

    Automatically fires when the local player has a FULLY charged Machina
    (or Shooting Star) shot and the crosshair line would strike >= 2 enemies.
                                                                         --]]

---------------------------------------------------------------- CONFIG --
local ENABLED      = true
local MIN_ENEMIES  = 2      -- fire only when at least this many enemies align
local COUNT_INVULN = false  -- count ubered/bonked enemies toward the total?
local DRAW_HUD     = false
local HUD_X, HUD_Y = 40, 300

local PENETRATING_RIFLES = {
    [526]   = true, -- The Machina
    [30665] = true, -- Shooting Star
}

--------------------------------------------------------------- INTERNAL --
local FULL_CHARGE = 150
local MAX_RANGE   = 8192
local MAX_PIERCE  = 6     -- this ensures we don't kill performance; penetrations aren't actually capped

local MASK_BULLET = (MASK_SOLID or 0x200400B) | (CONTENTS_HITBOX or 0x40000000)

local COND_ZOOMED = TFCond_Zoomed or 1
local INVULN_CONDS = {
    TFCond_Ubercharged or 5,
    TFCond_Bonked or 14,
    TFCond_UberchargedHidden or 51,
    TFCond_UberchargedCanteen or 52,
}

local status    = ""
local hudActive = false
local font      = nil

local function IsInvulnerable(player)
    for i = 1, #INVULN_CONDS do
        if player:InCond(INVULN_CONDS[i]) then return true end
    end
    return false
end

local function CountAlignedEnemies(me)
    local src = me:GetAbsOrigin() + me:GetPropVector("localdata", "m_vecViewOffset[0]")
    local fwd = engine.GetViewAngles():Forward()
    local dst = src + fwd * MAX_RANGE

    local myIdx  = me:GetIndex()
    local myTeam = me:GetTeamNumber()
    local pierced = {}
    local count   = 0

    local function filter(ent)
        if not ent then return true end
        local idx = ent:GetIndex()
        if idx == myIdx or pierced[idx] then return false end
        if ent:GetClass() == "CTFPlayer" and ent:GetTeamNumber() == myTeam then
            return false
        end
        return true
    end

    local start = src
    for _ = 1, MAX_PIERCE do
        local tr = engine.TraceLine(start, dst, MASK_BULLET, filter)
        local ent = tr.entity
        if tr.fraction >= 1 or not ent or not ent:IsValid() then break end

        if ent:GetClass() == "CTFPlayer" then
            if ent:IsAlive() and not ent:IsDormant()
                and (COUNT_INVULN or not IsInvulnerable(ent)) then
                count = count + 1
            end
            pierced[ent:GetIndex()] = true
            start = tr.endpos + fwd * 1
        else
            break
        end
    end

    return count
end

local function GetReadyRifle(me)
    local wpn = me:GetPropEntity("m_hActiveWeapon")
    if not wpn or not wpn:IsValid() then return nil, "no weapon" end

    local def = wpn:GetPropInt("m_iItemDefinitionIndex")
    if not def or not PENETRATING_RIFLES[def] then return nil, nil end

    if not me:InCond(COND_ZOOMED) then return nil, "not zoomed" end

    local charge = wpn:GetPropFloat("SniperRifleLocalData", "m_flChargedDamage") or 0
    if charge < FULL_CHARGE - 0.5 then
        return nil, string.format("charging: %.0f%%", charge / FULL_CHARGE * 100)
    end

    local nextAttack = wpn:GetPropFloat("LocalActiveWeaponData", "m_flNextPrimaryAttack") or 0
    if nextAttack > globals.CurTime() then return nil, "on cooldown" end

    return wpn
end

--------------------------------------------------------------- CALLBACKS --
callbacks.Register("CreateMove", "machina_auto_penetrate", function(cmd)
    hudActive = false
    if not ENABLED then return end

    local me = entities.GetLocalPlayer()
    if not me or not me:IsValid() or not me:IsAlive() then return end

    local rifle, why = GetReadyRifle(me)
    if not rifle then
        if why then
            hudActive, status = true, why
        end
        return
    end

    hudActive = true
    local n = CountAlignedEnemies(me)
    if n >= MIN_ENEMIES then
        cmd.buttons = cmd.buttons | IN_ATTACK
        status = string.format("FIRING - %d enemies aligned", n)
    else
        status = string.format("full charge - %d enemy aligned", n)
    end
end)

callbacks.Register("Draw", "machina_auto_penetrate_hud", function()
    if not DRAW_HUD or not hudActive or engine.Con_IsVisible() or engine.IsGameUIVisible() then
        return
    end
    if not font then
        font = draw.CreateFont("Tahoma", 16, 400)
    end
    draw.SetFont(font)
    local text = "Machina: " .. status
    local w, h = draw.GetTextSize(text)
    draw.Color(0, 0, 0, 160)
    draw.FilledRect(HUD_X - 3, HUD_Y - 3, HUD_X + w + 3, HUD_Y + h + 3)
    draw.Color(255, 255, 255, 255)
    draw.Text(HUD_X, HUD_Y, text)
end)

callbacks.Register("Unload", "machina_auto_penetrate_unload", function()
    callbacks.Unregister("CreateMove", "machina_auto_penetrate")
    callbacks.Unregister("Draw", "machina_auto_penetrate_hud")
end)
