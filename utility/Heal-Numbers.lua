local CONFIG = {
    
    lifetime = 2.0,
    riseUnits= 32,
    maxItems = 10,

    
    onlyMine = false,
    showSelfRegen = true,
    useHealOnHit  = true,
    hideWhenDead  = false,
    minAmount= 1,

    
    follow   = false,
    centerText    = true,
    shadow   = true, 

    
    selfToScreen  = true,
    selfScreenX   = 0, 
    selfScreenY   = 90,
    selfRisePx    = 45,

    
    colorSelf     = {   0, 255,   0 },
    colorMine     = {   0, 255,   0 },
    colorOther    = { 130, 200, 130 },

    dedupeWindow  = 0.10,   
}

local font = draw.CreateFont("Verdana", 16, 800)





local deltas = {}   
local recent = {}   

local function remapClamped(v, a, b, c, d)
    if a == b then return (v >= b) and d or c end
    local t = (v - a) / (b - a)
    if t < 0 then t = 0 elseif t > 1 then t = 1 end
    return c + (d - c) * t
end





local function push(patient, healer, amount, source)
    if not patient or not patient:IsValid() then return end
    if amount == 0 or math.abs(amount) < CONFIG.minAmount then return end

    local lp = entities.GetLocalPlayer()
    if not lp then return end
    if CONFIG.hideWhenDead and not lp:IsAlive() then return end

    local patientIdx = patient:GetIndex()
    local isLocal    = (patientIdx == lp:GetIndex())

    
    
    if not isLocal and patient:IsDormant() then return end

    local healerIdx = (healer and healer:IsValid()) and healer:GetIndex() or nil
    local selfHeal  = (healerIdx ~= nil and healerIdx == patientIdx)
    local byMe      = (healerIdx ~= nil and healerIdx == lp:GetIndex())

    if selfHeal and not CONFIG.showSelfRegen then return end
    if CONFIG.onlyMine and not byMe then return end

    
    
    local now  = globals.CurTime()
    local seen = recent[patientIdx]
    if source == "healonhit" and seen and seen.amount == amount
       and (now - seen.t) <= CONFIG.dedupeWindow then
        return
    end
    if source == "healed" then
        recent[patientIdx] = { t = now, amount = amount }
    end

    local color = CONFIG.colorOther
    if isLocal then
        color = CONFIG.colorSelf
    elseif byMe then
        color = CONFIG.colorMine
    end

    local item = { amount = amount, die = now + CONFIG.lifetime, color = color }

    if isLocal and CONFIG.selfToScreen then
        local w, h = draw.GetScreenSize()
        item.world = false
        item.x     = w * 0.5 + CONFIG.selfScreenX
        item.y     = h * 0.5 + CONFIG.selfScreenY
        item.rise  = -CONFIG.selfRisePx     
    else
        
        
        local org     = patient:GetAbsOrigin()
        local distSqr = (org - lp:GetAbsOrigin()):LengthSqr()
        local zoff    = patient:GetMaxs().z + remapClamped(distSqr, 0, 200 * 200, 1, 16)

        item.world = true
        item.x     = org.x
        item.y     = org.y
        item.z     = org.z + zoff
        item.rise  = CONFIG.riseUnits
        item.zoff  = zoff
        item.ent   = CONFIG.follow and patient or nil
    end

    deltas[#deltas + 1] = item
end

local function onFireGameEvent(event)
    local name = event:GetName()

    if name == "player_healed" then
        push(entities.GetByUserID(event:GetInt("patient")),
             entities.GetByUserID(event:GetInt("healer")),
             event:GetInt("amount"), "healed")

    elseif name == "player_healonhit" and CONFIG.useHealOnHit then
        
        local patient = entities.GetByIndex(event:GetInt("entindex"))
        push(patient, patient, event:GetInt("amount"), "healonhit")
    end
end





local function onDraw()
    if #deltas == 0 then return end
    if engine.IsGameUIVisible() or engine.Con_IsVisible() then return end

    local now   = globals.CurTime()
    local count = #deltas

    
    local timeMod = 0
    if count > CONFIG.maxItems then
        timeMod = remapClamped(count, 10, 15, 0.5, 1.5)
    end

    draw.SetFont(font)

    for i = count, 1, -1 do
        local d = deltas[i]

        if (d.die - timeMod) <= now then
            table.remove(deltas, i)
        else
            local pct = (CONFIG.lifetime - (d.die - now)) / CONFIG.lifetime

            
            
            
            local alpha = 255
            if pct > 0.5 then
                alpha = math.floor(255 * (1 - (pct - 0.5) / 0.5))
            end

            local sx, sy
            if d.world then
                local x, y, z = d.x, d.y, d.z + pct * d.rise

                if d.ent and d.ent:IsValid() and not d.ent:IsDormant() then
                    local o = d.ent:GetAbsOrigin()
                    x, y, z = o.x, o.y, o.z + d.zoff + pct * d.rise
                end

                local s = client.WorldToScreen(Vector3(x, y, z))
                if s and s[1] and s[2] then
                    sx, sy = s[1], s[2]
                end
            else
                sx = d.x
                sy = d.y + pct * d.rise
            end

            if sx and alpha > 0 then
                local txt = (d.amount > 0) and string.format("+%d", d.amount)
                                            or string.format("%d", d.amount)

                if CONFIG.centerText then
                    local tw, th = draw.GetTextSize(txt)
                    sx = sx - tw * 0.5
                    sy = sy - th * 0.5
                end

                local c = d.color
                draw.Color(c[1], c[2], c[3], alpha)
                if CONFIG.shadow then
                    draw.TextShadow(math.floor(sx), math.floor(sy), txt)
                else
                    draw.Text(math.floor(sx), math.floor(sy), txt)
                end
            end
        end
    end
end





callbacks.Unregister("FireGameEvent", "heal_numbers_event")
callbacks.Unregister("Draw",          "heal_numbers_draw")
callbacks.Unregister("Unload",        "heal_numbers_unload")

callbacks.Register("FireGameEvent", "heal_numbers_event",  onFireGameEvent)
callbacks.Register("Draw",          "heal_numbers_draw",   onDraw)
callbacks.Register("Unload",        "heal_numbers_unload", function()
    deltas = {}
    recent = {}
end)

print("[heal_numbers] loaded")
