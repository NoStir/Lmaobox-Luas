local shouldLockViewAngles = false
local originalViewAngles = nil
local target = nil

local function normalizeAngle(angle)
    angle = angle % 360
    return angle > 180 and angle - 360 or angle < -180 and angle + 360 or angle
end

local function calculateLookAtAngles(me, target)
    local targetPos = target:GetAbsOrigin()
    local playerPos = me:GetAbsOrigin()
    local directionVector = targetPos - playerPos

    local yaw = math.deg(math.atan(directionVector.y, directionVector.x))
    local distance2D = math.sqrt(directionVector.x^2 + directionVector.y^2)
    local pitch = math.deg(math.atan(directionVector.z, distance2D))

    return EulerAngles(normalizeAngle(directionVector.z < 0 and -pitch or pitch), normalizeAngle(yaw), 0)
end

local function isBehindTarget(me, target)
    local vecToTarget = target:GetAbsOrigin() - me:GetAbsOrigin()
    vecToTarget.z = 0
    vecToTarget:Normalize()

    local targetForward = target:GetPropVector("tfnonlocaldata", "m_angEyeAngles[0]"):Forward()
    targetForward.z = 0
    targetForward:Normalize()

    return vecToTarget:Dot(targetForward) > 0
end

local function findClosestTarget(me, players)
    local closestTarget, closestDistance = nil, 85

    for _, potentialTarget in ipairs(players) do
        if potentialTarget:IsAlive() and potentialTarget:GetTeamNumber() ~= me:GetTeamNumber() and not potentialTarget:InCond(TFCond_Ubercharged) then
            local dist = (potentialTarget:GetAbsOrigin() - me:GetAbsOrigin()):Length()
            if dist <= closestDistance then
                closestTarget, closestDistance = potentialTarget, dist
                if closestDistance < 20 then
                    break
                end
            end
        end
    end

    return closestTarget
end

local function resetViewAngles()
    if originalViewAngles then
        engine.SetViewAngles(originalViewAngles)
        originalViewAngles = nil
    end
end

local function backstabAimbot(cmd)
    local me = entities.GetLocalPlayer()
    if not me or not me:IsAlive() then return end

    if not me:GetPropInt("m_iClass") == TF_CLASS_SPY or me:InCond(TFCond_Cloaked) then
        target, shouldLockViewAngles, originalViewAngles = nil, false, nil
        return
    end

    local weapon = me:GetPropEntity("m_hActiveWeapon")
    if not weapon or not weapon:IsMeleeWeapon() or not weapon:GetPropBool("m_bKnifeExists") then return end
    if globals.CurTime() < weapon:GetPropFloat("m_flNextPrimaryAttack") then return end

    local readyToBackstab = weapon:GetPropBool("m_bReadyToBackstab")
    local players = entities.FindByClass("CTFPlayer")

    if target and not target:IsAlive() then
        target, shouldLockViewAngles, originalViewAngles = nil, false, nil
    end

    if not target or not target:IsAlive() or (target:GetAbsOrigin() - me:GetAbsOrigin()):Length() > 100 then
        target = findClosestTarget(me, players)
    end

    if target and target:IsAlive() and isBehindTarget(me, target) then
        if not originalViewAngles then
            originalViewAngles = engine.GetViewAngles()
        end

        local aimAngles = calculateLookAtAngles(me, target)
        engine.SetViewAngles(aimAngles)

        -- Suppress the packet to prevent sending the modified view angles
        if readyToBackstab then
            cmd:SetSendPacket(false)
            cmd:SetButtons(cmd:GetButtons() | IN_ATTACK)
            readyToBackstab = false
        else
            cmd:SetSendPacket(true)
        end

        -- Restore original view angles after the attack
        resetViewAngles()
    else
        shouldLockViewAngles = false
        resetViewAngles()
    end
end

callbacks.Register("CreateMove", "backstabAimbot", backstabAimbot)
