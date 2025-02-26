-- Instant Stop Lua

-- 0 = Normal movement
-- 1 = Not moving: PDA open, waiting for delay
-- 2 = Not moving: PDA toggled off (after delay)

local me = nil
local state = 0

callbacks.Register("CreateMove", "InstantStopMovementMonitor", function(cmd)
    if not me or me:IsValid() then
        me = entities.GetLocalPlayer()
        return
    end
    local moving = input.IsButtonDown(KEY_W) or input.IsButtonDown(KEY_A) or 
                   input.IsButtonDown(KEY_S) or input.IsButtonDown(KEY_D)

    if not moving then
        if state == 0 then
            -- Transition from moving to not moving: trigger the stop.
            client.Command("cyoa_pda_open 1", true)
            state = 1
        elseif state == 1 and me:GetPropBool("m_bViewingCYOAPDA") then
            --Toggle off the PDA.
            client.Command("cyoa_pda_open 0", true)
            state = 2
        end
    elseif moving and state ~= 0 then
        state = 0
    end
end)
