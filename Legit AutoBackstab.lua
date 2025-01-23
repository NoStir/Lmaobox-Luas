local target = nil

local function findClosestTarget(me, players)
    local closestTarget, closestDistanceSqr = nil, 85 * 85  -- Squared distance for efficiency

    for _, potentialTarget in ipairs(players) do
        if potentialTarget:IsAlive() and potentialTarget:GetTeamNumber() ~= me:GetTeamNumber() and not potentialTarget:InCond(TFCond_Ubercharged) then
            local distSqr = (potentialTarget:GetAbsOrigin() - me:GetAbsOrigin()):LengthSqr()

            if distSqr <= closestDistanceSqr then
                closestTarget, closestDistanceSqr = potentialTarget, distSqr
                if closestDistanceSqr < (20 * 20) then
                    break  -- Early exit if a very close target is found
                end
            end
        end
    end

    return closestTarget
end

local function backstabAimbot(cmd)
    local me = entities.GetLocalPlayer()
    if not me:IsValid() or not me:IsAlive() or me:GetPropInt("m_iClass") ~= 8 or me:InCond(TFCond_Cloaked) then
        target = nil
        return
    end

    local weapon = me:GetPropEntity("m_hActiveWeapon")
    if not weapon or not weapon:IsValid() or not weapon:IsMeleeWeapon() or not weapon:GetPropBool("m_bKnifeExists") or globals.CurTime() < weapon:GetPropFloat("m_flNextPrimaryAttack") then
        return
    end

    local readyToBackstab = weapon:GetPropBool("m_bReadyToBackstab")
    local players = entities.FindByClass("CTFPlayer")

    -- Re-evaluate the target if the current one is invalid or out of range
    if not target or not target:IsValid() or not target:IsAlive() or (target:GetAbsOrigin() - me:GetAbsOrigin()):LengthSqr() > (100 * 100) then
        target = findClosestTarget(me, players)
    end

    -- Trigger attack if valid target and ready to backstab
    if target and readyToBackstab then
        cmd.buttons = cmd.buttons | IN_ATTACK
    end
end

callbacks.Register("CreateMove", "backstabAimbot", backstabAimbot)
