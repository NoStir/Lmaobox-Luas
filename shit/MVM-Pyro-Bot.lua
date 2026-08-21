local me
local anyKeyPressed = false

callbacks.Register("Draw", function()
    if not me then
        me = entities.GetLocalPlayer()
        return
    end
    for keyCode = 0, 255 do
        if input.IsButtonDown(keyCode) then
            anyKeyPressed = true
            break
        else
            anyKeyPressed = false
        end
    end
    if me:InCond(44) == true then
        gui.SetValue("Aim Method", "plain")
        gui.SetValue("Aim Method (Projectile)", "plain")
        gui.SetValue("Aim Key", 0)
    else
        gui.SetValue("Aim Method", "silent +")
        gui.SetValue("Aim Method (Projectile)", "silent +")
        gui.SetValue("Aim Key", KEY_LSHIFT)
    end
end)


local MAX_SPEED = 450 -- Maximum speed the player can move
local TWO_PI = 2 * math.pi
local DEG_TO_RAD = math.pi / 180
local function ComputeMove(userCmd, a, b)
    local DirectionX, DirectionY = b.x - a.x, b.y - a.y

    local targetYaw = (math.atan(DirectionX, DirectionY) + TWO_PI) % TWO_PI
    local _, currentYaw = userCmd:GetViewAngles()
    currentYaw = currentYaw * DEG_TO_RAD

    local yawDiff = (targetYaw - currentYaw + math.pi) % TWO_PI - math.pi

    return Vector3(
        math.cos(yawDiff) * MAX_SPEED,
        math.sin(-yawDiff) * MAX_SPEED,
        0
    )
end

local function WalkTo(cmd, localPlayer, destination)
    local localPos = localPlayer:GetAbsOrigin()
    local result = ComputeMove(cmd, localPos, destination)

    cmd:SetForwardMove(result.x)
    cmd:SetSideMove(result.y)
    cmd:SetButtons(cmd.buttons | IN_ATTACK)
end

local function PyroBot(cmd)
    if not input.IsButtonDown(KEY_LSHIFT) then
        if anyKeyPressed then return end
    end
    me = entities.GetLocalPlayer()
    if not me then return end

    if input.IsButtonDown(KEY_LSHIFT) and tostring(me:GetPropFloat("m_flRageMeter")) == "100.0" then
        cmd:SetButtons(cmd.buttons | IN_ATTACK2)
    end

    if me:InCond(44) == false then return end
    
    local source = me:GetAbsOrigin() + me:GetPropVector("localdata", "m_vecViewOffset[0]")
    local destination = source + engine.GetViewAngles():Forward() * 30000

    local trace = engine.TraceLine(source, destination, MASK_SHOT_HULL)
    
    if trace and trace.entity and trace.entity:IsPlayer() or trace.entity:GetClass() == "CTFTankBoss" then
        local entity = trace.entity
        if entity:GetTeamNumber() ~= me:GetTeamNumber() then
            WalkTo(cmd, me, entity:GetAbsOrigin())
        end
    end
end

callbacks.Register("CreateMove", PyroBot)
