local stabbing = false

-- Helper function to calculate the angle to the target's back
local function calculateBackstabAngles(localPlayer, target)
    local targetPos = target:GetAbsOrigin()
    local playerPos = localPlayer:GetAbsOrigin()
    local targetForward = target:GetPropVector("tfnonlocaldata", "m_angEyeAngles[0]"):Forward()
    local backDirection = targetForward * -1
    local backPosition = targetPos + backDirection * 100 -- Adjust the multiplier as needed for the proper distance behind the target
    return PositionAngles(playerPos, backPosition)
end

-- Function to check if the local player is behind the target
local function isBehindTarget(localPlayer, target)
    local vecToTarget = target:GetAbsOrigin() - localPlayer:GetAbsOrigin()
    vecToTarget.z = 0
    vecToTarget:Normalize()

    local targetForward = target:GetPropVector("tfnonlocaldata", "m_angEyeAngles[0]"):Forward()
    targetForward.z = 0
    targetForward:Normalize()

    local flPosVsTargetViewDot = vecToTarget:Dot(targetForward)
    return flPosVsTargetViewDot < 0 -- Changed to '< 0' as we want to check if we are behind
end

-- Main function to handle the backstab logic
local function backstabAimbot(cmd)
    local localPlayer = entities.GetLocalPlayer()
    if not localPlayer or not localPlayer:IsAlive() then
        return
    end

    local weapon = localPlayer:GetPropEntity("m_hActiveWeapon")
    if not weapon or not weapon:GetPropBool("m_bKnifeExists") then
        return
    end

    local readyToBackstab = weapon:GetPropBool("m_bReadyToBackstab")

    local players = entities.FindByClass("CTFPlayer")
    for _, target in ipairs(players) do
        if target:IsAlive() and target:GetTeamNumber() ~= localPlayer:GetTeamNumber() then
            local distance = (target:GetAbsOrigin() - localPlayer:GetAbsOrigin()):Length()
            if distance <= 100 then
                local backstabAngles = calculateBackstabAngles(localPlayer, target)
                if isBehindTarget(localPlayer, target) then
                    engine.SetViewAngles(backstabAngles)
                    if readyToBackstab then
                        cmd:SetButtons(cmd:GetButtons() | IN_ATTACK)
                        stabbing = true
                    else
                        stabbing = false
                    end
                    return -- Exit after attempting to backstab
                end
            end
        end
    end
end

-- PositionAngles function for consistent angle calculations
function PositionAngles(source, dest)
    local delta = dest - source
    local pitch = math.deg(math.atan(delta.z / delta:Length2D()))
    local yaw = math.deg(math.atan(delta.y / delta.x))
    if delta.x >= 0 then
        yaw = yaw + 180
    end
    return EulerAngles(pitch, yaw, 0)
end

draw.SetFont(draw.CreateFont("Tahoma", 16, 800))

local function drawInfo()
    local localPlayer = entities.GetLocalPlayer()
    if not localPlayer then
        return
    end

    local weapon = localPlayer:GetPropEntity("m_hActiveWeapon")
    local readyToBackstab = weapon and weapon:GetPropBool("m_bReadyToBackstab")
    local screenWidth, screenHeight = draw.GetScreenSize()

    draw.Color(255, 255, 255, 255)
    draw.Text(screenWidth * 0.05, screenHeight * 0.20, "360° Backstab Aimbot Active: " .. (readyToBackstab and "Ready" or "Not Ready"))
    draw.Text(screenWidth * 0.05, screenHeight * 0.25, "Stabbing: " .. (stabbing and "Yes" or "No"))
end

callbacks.Register("CreateMove", backstabAimbot)
callbacks.Register("Draw", drawInfo)
