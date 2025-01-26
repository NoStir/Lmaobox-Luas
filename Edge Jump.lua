-- Edge Jump Script (Optimized Version)

-- Minimum horizontal speed to bother checking for edges
local MIN_SPEED_2D = 20

local function EdgeJump_CreateMove(cmd)
    local localPlayer = entities.GetLocalPlayer()
    if not localPlayer or not localPlayer:IsAlive() then
        return
    end

    -- Retrieve flags, velocity, and position
    local flags    = localPlayer:GetPropInt("m_fFlags")
    local velocity = localPlayer:GetPropVector("localdata", "m_vecVelocity[0]")
    local position = localPlayer:GetAbsOrigin()

    -- Check ground and crouch state
    local OnGround  = (flags & FL_ONGROUND) ~= 0
    local Crouching = (flags & FL_DUCKING) ~= 0
    
    -- If we're not on the ground or are crouching, skip edge jumping
    if (not OnGround) or Crouching then
        return
    end

    -- Check if we have some horizontal movement before doing traces
    local speed2D = math.sqrt(velocity.x^2 + velocity.y^2)
    if speed2D < MIN_SPEED_2D then
        return
    end

    -- Predict next position (X/Y only)
    local frameTime = globals.FrameTime()
    local predictedPosition = Vector3(
        position.x + velocity.x * frameTime,
        position.y + velocity.y * frameTime,
        position.z
    )

    -- 1) First do a single center trace:
    local centerStart = predictedPosition
    local centerEnd   = centerStart - Vector3(0, 0, 20)  -- Down 20 units
    local centerTrace = engine.TraceLine(centerStart, centerEnd, MASK_PLAYERSOLID)

    -- If the fraction < 1.0, there is ground directly under the center of the player
    if centerTrace.fraction < 1.0 then
        return
    end

    -- 2) Only if the center is fully empty, do additional side traces
    local offsets = {
        Vector3( 15,   0, 0),  -- Right
        Vector3(-15,   0, 0),  -- Left
        Vector3(  0,  15, 0),  -- Forward
        Vector3(  0, -15, 0)   -- Backward
    }
    
    for _, offset in ipairs(offsets) do
        local startPos = predictedPosition + offset
        local endPos   = startPos - Vector3(0, 0, 20)
        local trace    = engine.TraceLine(startPos, endPos, MASK_PLAYERSOLID)
        if trace.fraction < 1.0 then
            -- Found ground on at least one side trace, so not actually an edge
            return
        end
    end
    
    -- If we get here, *all* traces are empty => we are about to fall
    cmd.buttons = cmd.buttons | (1 << 1)  -- IN_JUMP
end

callbacks.Register("CreateMove", "EdgeJumpScript", EdgeJump_CreateMove)
