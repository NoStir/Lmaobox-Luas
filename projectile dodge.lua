-- =========================================
-- Rocket Avoid 360 (predict + splash avoidance)
-- =========================================

-- ---- tunables -------------------------------------------------------------

local MAX_TRACK_DIST   = 2000
local CHECK_HORIZ_ONLY = true
local T_MAX            = 1.25
local MOVE_SPEED       = 450
local MOVE_SAMPLES     = 24       -- 16/24/32. Higher = smoother, more CPU.
local SAFETY_PAD       = 36

local BLAST_RADIUS_ROCKET     = 110
local BLAST_RADIUS_DIRECTHIT  = 42

local MASK = MASK_SHOT_HULL

-- ---- vec helpers ----------------------------------------------------------

local function v(x, y, z) return Vector3(x, y, z) end
local function vadd(a, b) return v(a.x + b.x, a.y + b.y, a.z + b.z) end
local function vsub(a, b) return v(a.x - b.x, a.y - b.y, a.z - b.z) end
local function vscl(a, s) return v(a.x * s, a.y * s, a.z * s) end
local function vdot(a, b) return a.x * b.x + a.y * b.y + a.z * b.z end
local function vlen(a) return a:Length() end
local function flatXY(a) return v(a.x, a.y, 0) end

local function is_vec(x)
    return x ~= nil and x.x ~= nil and x.y ~= nil and x.z ~= nil
end

local function vnorm(a)
    local L = a:Length()
    if L <= 1e-6 then
        return v(0, 0, 0), 0
    end

    return v(a.x / L, a.y / L, a.z / L), L
end

local function clamp(x, lo, hi)
    if x < lo then return lo end
    if x > hi then return hi end
    return x
end

-- ---- closest approach -----------------------------------------------------

local function time_to_closest(r, vel)
    local vv = vdot(vel, vel)
    if vv <= 1e-6 then
        return 1e9
    end

    return -vdot(r, vel) / vv
end

local function miss_distance(r, vel, t)
    local closest = vadd(r, vscl(vel, t))
    return vlen(closest), closest
end

-- ---- entity / trace helpers ----------------------------------------------

local function is_rocket(ent)
    if not ent or not ent:IsValid() then
        return false
    end

    local cls = ent:GetClass()
    if not cls then
        return false
    end

    return cls == "CTFProjectile_Rocket"
        or cls == "CTFProjectile_SentryRocket"
        or cls:find("Projectile_Rocket", 1, true) ~= nil
end

local function collect_rockets()
    local out = {}
    local hi = entities.GetHighestEntityIndex() or 0

    for i = 1, hi do
        local ent = entities.GetByIndex(i)
        if is_rocket(ent) then
            out[#out + 1] = ent
        end
    end

    return out
end

local function trace_world_only_filter(ent)
    if not ent then
        return true
    end

    local cls = ent:GetClass()
    if cls == "CTFPlayer" then
        return false
    end

    if cls and cls:find("Projectile", 1, true) then
        return false
    end

    return true
end

local function trace_no_entities_filter()
    return false
end

local function can_splash_reach(from, to)
    local delta = vsub(to, from)
    local dir, len = vnorm(delta)

    if len <= 1e-3 then
        return true
    end

    -- Nudge start slightly away from the surface so traces do not startsolid.
    local src = vadd(from, vscl(dir, 2.0))
    local tr = engine.TraceLine(src, to, MASK, trace_no_entities_filter)

    return tr ~= nil and not tr.allsolid and tr.fraction >= 0.98
end

local function predict_world_impact(pos3d, vel3d)
    local dir, speed = vnorm(vel3d)

    if speed <= 1e-3 then
        return pos3d, 1e9, false
    end

    local maxTravel = speed * T_MAX
    local dst = vadd(pos3d, vscl(dir, maxTravel))
    local tr = engine.TraceLine(pos3d, dst, MASK, trace_world_only_filter)

    if tr and tr.fraction < 1.0 then
        local dist = maxTravel * tr.fraction
        local hitPos = tr.endpos or vadd(pos3d, vscl(dir, dist))
        return hitPos, dist / speed, true
    end

    return dst, T_MAX, false
end

-- ---- blast radius ---------------------------------------------------------

local function get_direct_hit_weapon_id()
    if E_WeaponBaseID and E_WeaponBaseID.TF_WEAPON_DIRECTHIT then
        return E_WeaponBaseID.TF_WEAPON_DIRECTHIT
    end

    if TF_WEAPON_DIRECTHIT then
        return TF_WEAPON_DIRECTHIT
    end

    return 65
end

local function get_launcher(ent)
    local props = {
        "m_hLauncher",
        "m_hOriginalLauncher",
        "m_hThrower"
    }

    for i = 1, #props do
        local ok, launcher = pcall(function()
            return ent:GetPropEntity(props[i])
        end)

        if ok and launcher and launcher:IsValid() then
            return launcher
        end
    end

    return nil
end

local function get_blast_radius(ent)
    local radius = BLAST_RADIUS_ROCKET
    local launcher = get_launcher(ent)

    if launcher then
        local ok, weaponID = pcall(function()
            return launcher:GetWeaponID()
        end)

        if ok and weaponID == get_direct_hit_weapon_id() then
            radius = BLAST_RADIUS_DIRECTHIT
        end
    end

    return radius + SAFETY_PAD
end

-- ---- velocity tracking ----------------------------------------------------

local track = {}

local function get_velocity(ent, id, pos3d, dt)
    local okEst, est = pcall(function()
        return ent:EstimateAbsVelocity()
    end)

    if okEst and is_vec(est) and est:Length() > 5 then
        return est
    end

    local okProp, propVel = pcall(function()
        return ent:GetPropVector("m_vInitialVelocity")
    end)

    if okProp and is_vec(propVel) and propVel:Length() > 5 then
        return propVel
    end

    local rec = track[id]
    if rec and rec.lastPos and dt and dt > 0 then
        return vscl(vsub(pos3d, rec.lastPos), 1 / dt)
    end

    return v(0, 0, 0)
end

-- ---- 360 movement solver --------------------------------------------------
-- Samples full view-relative movement circle:
-- forward, back, left, right, and diagonals.

local function build_move_basis()
    local view = engine.GetViewAngles()
    local fwd, right = view:Vectors()

    if CHECK_HORIZ_ONLY then
        fwd = flatXY(fwd)
        right = flatXY(right)
    end

    fwd = select(1, vnorm(fwd))
    right = select(1, vnorm(right))

    return fwd, right
end

local function movement_world_delta(fwd, right, forwardMove, sideMove, seconds)
    local wish = vadd(vscl(fwd, forwardMove), vscl(right, sideMove))
    local dir, speed = vnorm(wish)

    if speed <= 1e-3 then
        return v(0, 0, 0)
    end

    return vscl(dir, MOVE_SPEED * seconds)
end

local function score_move(myRef, fwd, right, forwardMove, sideMove, threats)
    local total = 0
    local worstMargin = 1e9

    for i = 1, #threats do
        local th = threats[i]

        local t = clamp(th.when or T_MAX, 0.05, T_MAX)
        local predicted = vadd(myRef, movement_world_delta(fwd, right, forwardMove, sideMove, t))

        local distAfter = vlen(vsub(predicted, th.ref))
        local margin = distAfter - th.radius

        if margin < worstMargin then
            worstMargin = margin
        end

        -- Sooner threats matter more.
        local urgency = 1.0 + ((T_MAX - clamp(th.when, 0, T_MAX)) / T_MAX) * 2.0

        -- Heavy penalty if still inside blast radius.
        if margin < 0 then
            total = total + margin * 8.0 * urgency
        else
            total = total + margin * 1.5 * urgency
        end
    end

    -- Prefer not backing up unless it is actually safer.
    total = total + forwardMove * 0.015

    -- Keep the worst threat dominant.
    total = total + worstMargin * 10.0

    return total
end

local function choose_360_move(myRef, threats)
    local fwd, right = build_move_basis()

    local bestForward = 0
    local bestSide = 0
    local bestScore = -1e9

    -- Include standing still as a candidate.
    local stillScore = score_move(myRef, fwd, right, 0, 0, threats)
    bestScore = stillScore

    for i = 0, MOVE_SAMPLES - 1 do
        local ang = (i / MOVE_SAMPLES) * math.pi * 2

        local forwardMove = math.cos(ang) * MOVE_SPEED
        local sideMove = math.sin(ang) * MOVE_SPEED

        local score = score_move(myRef, fwd, right, forwardMove, sideMove, threats)

        if score > bestScore then
            bestScore = score
            bestForward = forwardMove
            bestSide = sideMove
        end
    end

    return bestForward, bestSide
end

-- ---- main -----------------------------------------------------------------

callbacks.Unregister("CreateMove", "rocket_avoid_splash")
callbacks.Register("CreateMove", "rocket_avoid_splash", function(cmd)
    local me = entities.GetLocalPlayer()

    if not me or not me:IsAlive() then
        return
    end

    local myFeet = me:GetAbsOrigin()
    if not is_vec(myFeet) then
        return
    end

    local myAimPos = vadd(myFeet, v(0, 0, 40))
    local myRef = CHECK_HORIZ_ONLY and flatXY(myFeet) or myFeet

    local dt = globals.FrameTime()
    if not dt or dt <= 0 then
        dt = 0.015
    end

    local rockets = collect_rockets()
    local seen = {}
    local current = {}

    -- Update tracks and velocities.
    for i = 1, #rockets do
        local ent = rockets[i]
        local id = ent:GetIndex()
        local pos3d = ent:GetAbsOrigin()

        if id and is_vec(pos3d) then
            seen[id] = true

            local vel3d = get_velocity(ent, id, pos3d, dt)

            current[#current + 1] = {
                ent = ent,
                id = id,
                pos = pos3d,
                vel = vel3d
            }

            track[id] = {
                lastPos = pos3d
            }
        end
    end

    -- Prune stale tracks.
    for id in pairs(track) do
        if not seen[id] then
            track[id] = nil
        end
    end

    local threats = {}

    for i = 1, #current do
        local data = current[i]
        local ent = data.ent

        if ent and ent:IsValid() then
            local rocketPos3D = data.pos
            local rocketVel3D = data.vel

            local rocketPosRef = CHECK_HORIZ_ONLY and flatXY(rocketPos3D) or rocketPos3D
            local rocketVelRef = CHECK_HORIZ_ONLY and flatXY(rocketVel3D) or rocketVel3D

            local rel = vsub(rocketPosRef, myRef)
            local speed = vlen(rocketVelRef)

            if speed > 5 and vlen(rel) <= MAX_TRACK_DIST then
                local radius = get_blast_radius(ent)

                -- Direct pass / hit threat.
                local tstar = time_to_closest(rel, rocketVelRef)
                local miss, offset = miss_distance(rel, rocketVelRef, tstar)

                local considerDirect = tstar >= 0
                    and tstar <= T_MAX
                    and miss <= radius

                local directPos3D = vadd(rocketPos3D, vscl(rocketVel3D, tstar))
                local directRef = CHECK_HORIZ_ONLY and flatXY(directPos3D) or directPos3D

                if considerDirect and not can_splash_reach(directPos3D, myAimPos) then
                    considerDirect = false
                end

                if considerDirect then
                    threats[#threats + 1] = {
                        ref = directRef,
                        pos = directPos3D,
                        when = tstar,
                        dist = miss,
                        radius = radius
                    }
                end

                -- World impact / splash threat.
                local impact3D, tImpact, hitWorld = predict_world_impact(rocketPos3D, rocketVel3D)
                local impactRef = CHECK_HORIZ_ONLY and flatXY(impact3D) or impact3D
                local impactDist = vlen(vsub(impactRef, myRef))

                local considerWorld = hitWorld
                    and tImpact >= 0
                    and tImpact <= T_MAX
                    and impactDist <= radius
                    and can_splash_reach(impact3D, myAimPos)

                if considerWorld then
                    threats[#threats + 1] = {
                        ref = impactRef,
                        pos = impact3D,
                        when = tImpact,
                        dist = impactDist,
                        radius = radius
                    }
                end
            end
        end
    end

    if #threats > 0 then
        local forwardMove, sideMove = choose_360_move(myRef, threats)

        cmd:SetForwardMove(forwardMove)
        cmd:SetSideMove(sideMove)
    end
end)