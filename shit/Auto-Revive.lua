----------------------------------------------------------------
-- small math/angle helpers
----------------------------------------------------------------
local function delta_to_angles(delta) -- world delta -> EulerAngles numbers
    local hyp = math.sqrt(delta.x*delta.x + delta.y*delta.y)
    local yaw   = math.deg(math.atan(delta.y, delta.x))    -- 2-arg atan
    local pitch = -math.deg(math.atan(delta.z, hyp))
    return pitch, yaw, 0
end

local function angle_delta_deg(p1, y1, p2, y2)
    local dp = math.abs(p1 - p2)
    local dy = math.abs(y1 - y2)
    if dy > 180 then dy = 360 - dy end
    return math.max(dp, dy)
end

----------------------------------------------------------------
-- entity collection + sorting by distance
----------------------------------------------------------------
local function FindAllEntitiesByClass(className)
    local out = {}
    local highest = entities.GetHighestEntityIndex()
    for i = 1, highest do -- 1 is world entity
        local ent = entities.GetByIndex(i)
        if ent and ent:IsValid() then
            local cls = ent:GetClass()
            if cls == className then
                out[#out+1] = ent
            end
        end
    end
    return out
end

local function GetEyePos(p)
    return p:GetAbsOrigin() + p:GetPropVector("localdata", "m_vecViewOffset[0]")
end

local function BBoxCenter(ent)
    local o  = ent:GetAbsOrigin()
    local mn = ent:GetMins()
    local mx = ent:GetMaxs()
    return Vector3(
        o.x + (mn.x + mx.x) * 0.5,
        o.y + (mn.y + mx.y) * 0.5,
        o.z + (mn.z + mx.z) * 0.5
    )
end

local function GetReviveMarkersSorted(fromPos)
    local markers = FindAllEntitiesByClass("CTFReviveMarker")
    local list = {}
    for i = 1, #markers do
        local e = markers[i]
        if e and e:IsValid() and not e:IsDormant() then
            local d = (e:GetAbsOrigin() - fromPos):Length()
            list[#list+1] = { ent = e, dist = d }
        end
    end
    table.sort(list, function(a,b) return a.dist < b.dist end)
    return list
end

----------------------------------------------------------------
-- main CreateMove logic
----------------------------------------------------------------
local AIM_EPS_DEG = 1.2
local tappedForIdx = -1  -- remember which marker we already tapped for

callbacks.Register("CreateMove", "medic_auto_revive", function(cmd)
    local me = entities.GetLocalPlayer()
    if not me or not me:IsAlive() then return end

    -- Soft gate: only run when holding a Medigun (by class name substring)
    local wep = me:GetPropEntity("m_hActiveWeapon") or nil
    if not wep or not wep:IsValid() or not wep:IsWeapon() then return end
    local wcls = wep:GetClass() or ""
    if not string.find(wcls, "Medigun", 1, true) then return end

    local eye = GetEyePos(me)
    local sorted = GetReviveMarkersSorted(eye)
    if #sorted == 0 then
        tappedForIdx = -1
        return
    end

    -- pick nearest with simple LOS
    local target, targetCenter
    for i = 1, #sorted do
        local e = sorted[i].ent
        local center = BBoxCenter(e)
        local tr = engine.TraceLine(eye, center, MASK_SHOT_HULL)
        if tr and (tr.entity == e or tr.fraction > 0.98) then
            target, targetCenter = e, center
            break
        end
    end
    if not target then
        tappedForIdx = -1
        return
    end

    -- desired aim
    local wantP, wantY = delta_to_angles(targetCenter - eye)
    cmd:SetViewAngles(wantP, wantY, 0)

    -- if close enough, tap once per target index
    local curP, curY = cmd:GetViewAngles()
    if angle_delta_deg(curP, curY, wantP, wantY) <= AIM_EPS_DEG then
        local idx = target:GetIndex()
        if tappedForIdx ~= idx then
            cmd:SetButtons(cmd.buttons | IN_ATTACK)  -- single-tick tap
            tappedForIdx = idx
        end
    else
        -- not aligned; allow re-tap once aligned again
        tappedForIdx = -1
    end
end)
