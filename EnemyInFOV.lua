-- Cache necessary lmaobox libraries
local entities = entities
local callbacks = callbacks
local gui = gui
local engine = engine
local vector = vector
local math = math
local globals = globals
local printc = printc
local Vector3 = Vector3

--
--
--

local function customAction()
    -- Custom action to be performed when a target is in FOV
    -- For example, play a sound
    engine.PlaySound("ui/buttonclick.wav")
end
--
--
--

local wasTargetInFov = false
local lastCheckTime = 0
local CHECKS_PER_SECOND = 10
local checkInterval = 1 / CHECKS_PER_SECOND

local function main_logic()
    if globals.CurTime() - lastCheckTime < checkInterval then
        return
    end
    lastCheckTime = globals.CurTime()

    local me = entities.GetLocalPlayer()
    if not me or not me:IsAlive() then
        return
    end

    local aimbotFov = gui.GetValue("aim fov") or 0
    local myViewAngles = engine.GetViewAngles()
    local myEyePosition = me:GetAbsOrigin() + me:GetPropVector("localdata", "m_vecViewOffset[0]")
    
    local isTargetInFovThisFrame = false

    local players = entities.FindByClass("CTFPlayer")
    for i, p in ipairs(players) do
        if p and p:IsValid() and p:IsAlive() and p:GetTeamNumber() ~= me:GetTeamNumber() then
            
            local box = p:HitboxSurroundingBox()

            if box then
                local mins, maxs = box[1], box[2]

                local closestX = math.max(mins.x, math.min(myEyePosition.x, maxs.x))
                local closestY = math.max(mins.y, math.min(myEyePosition.y, maxs.y))
                local closestZ = math.max(mins.z, math.min(myEyePosition.z, maxs.z))

                local targetPos = Vector3(closestX, closestY, closestZ)
                
                local direction = vector.Subtract(targetPos, myEyePosition)
                direction:Normalize()
                local aimAngles = direction:Angles()

                local deltaYaw = math.abs(myViewAngles.y - aimAngles.y)
                if deltaYaw > 180 then deltaYaw = 360 - deltaYaw end
                local deltaPitch = math.abs(myViewAngles.x - aimAngles.x)
                
                local fovDistance = math.sqrt(deltaPitch^2 + deltaYaw^2)
                
                if fovDistance <= aimbotFov then
                    isTargetInFovThisFrame = true
                    break
                end
            end
        end
    end

    if isTargetInFovThisFrame and not wasTargetInFov then
        customAction()
    end

    wasTargetInFov = isTargetInFovThisFrame
end

callbacks.Register("Draw", "FovDetectorLogic", main_logic)

callbacks.Register("Unload", "UnloadFovDetector", function()
    callbacks.Unregister("Draw", "FovDetectorLogic")
end)

printc(100, 255, 100, 255, "Closest Point FOV Action script loaded successfully.")