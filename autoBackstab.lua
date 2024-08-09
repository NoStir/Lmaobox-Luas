local stabbing = false
local stabbed = false
local smoothFactor = 0.3
local lockViewAngles = false
local target = nil
local maxYawChange = 10

local function normalizeAngle(angle)
    if angle > 180 then
        angle = angle - 360
    elseif angle < -180 then
        angle = angle + 360
    end
    return angle
end

local function calculateLookAtAngles(me, target)
    local targetPos = target:GetAbsOrigin()
    local playerPos = me:GetAbsOrigin()
    local directionVector = targetPos - playerPos
    directionVector:Normalize()

    local pitch = math.deg(math.atan(directionVector.z / math.sqrt(directionVector.x^2 + directionVector.y^2)))
    local yaw = math.deg(math.atan(directionVector.y / directionVector.x))

    if directionVector.x < 0 then
        yaw = yaw + 180
    end

    return EulerAngles(normalizeAngle(pitch), normalizeAngle(yaw), 0)
end

local function clampYawChange(currentYaw, targetYaw, maxChange)
    local deltaYaw = normalizeAngle(targetYaw - currentYaw)
    if math.abs(deltaYaw) > maxChange then
        deltaYaw = maxChange * (deltaYaw > 0 and 1 or -1)
    end
    return normalizeAngle(currentYaw + deltaYaw)
end

local function smoothAngles(currentAngles, targetAngles, factor)
    local smoothPitch = normalizeAngle(currentAngles.x + (targetAngles.x - currentAngles.x) * factor)
    local smoothYaw = clampYawChange(currentAngles.y, targetAngles.y, maxYawChange)
    local smoothRoll = normalizeAngle(currentAngles.z + (targetAngles.z - currentAngles.z) * factor)

    return EulerAngles(smoothPitch, smoothYaw, smoothRoll)
end

local function isBehindTarget(me, target)
    local vecToTarget = target:GetAbsOrigin() - me:GetAbsOrigin()
    vecToTarget.z = 0
    vecToTarget:Normalize()

    local targetForward = target:GetPropVector("tfnonlocaldata", "m_angEyeAngles[0]"):Forward()
    targetForward.z = 0
    targetForward:Normalize()

    local flPosVsTargetViewDot = vecToTarget:Dot(targetForward)
    return flPosVsTargetViewDot > 0
end

local function findClosestTarget(me, players)
    local closestTarget = nil
    local closestDistance = 100

    for _, target in ipairs(players) do
        if target:IsAlive() and target:GetTeamNumber() ~= me:GetTeamNumber() and not target:InCond(TFCond_Ubercharged) then
            local dist = (target:GetAbsOrigin() - me:GetAbsOrigin()):Length()
            if dist <= closestDistance then
                closestTarget = target
                closestDistance = dist
            end
        end
    end

    return closestTarget
end

local function backstabAimbot(cmd)
    local me = entities.GetLocalPlayer()
    if not me or not me:IsAlive() then
        return
    end

    local weapon = me:GetPropEntity("m_hActiveWeapon")
    if not weapon or not weapon:GetPropBool("m_bKnifeExists") then
        return
    end

    if globals.CurTime() - weapon:GetPropFloat("m_flNextPrimaryAttack") < 0 then
        return
    end

    local readyToBackstab = weapon:GetPropBool("m_bReadyToBackstab")
    local players = entities.FindByClass("CTFPlayer")

    if target and not target:IsAlive() then
        target, stabbed, lockViewAngles, stabbing = nil, false, false, false
    end

    if not target or not target:IsAlive() or (target:GetAbsOrigin() - me:GetAbsOrigin()):Length() > 100 then
        target = findClosestTarget(me, players)
    end

    if target and target:IsAlive() and isBehindTarget(me, target) then
        local lookAtAngles = calculateLookAtAngles(me, target)
        local smoothLookAtAngles = smoothAngles(engine.GetViewAngles(), lookAtAngles, smoothFactor)
        engine.SetViewAngles(smoothLookAtAngles)
        lockViewAngles = true

        if readyToBackstab then
            stabbing = true
            cmd:SetButtons(cmd:GetButtons() | IN_ATTACK)
            stabbed = true
        end
    else
        lockViewAngles = false
    end
end

callbacks.Register("CreateMove", "backstabAimbot", backstabAimbot)