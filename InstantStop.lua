-- Instant Stop Lua

-- 0 = Normal movement
-- 1 = Not moving: PDA open, waiting for delay
-- 2 = Not moving: PDA toggled off (after delay)

local state = 0
local stopTick = 0
local toggleDelayTicks = 2  -- Tick delay for toggling off the PDA

callbacks.Register("CreateMove", "InstantStopMovementMonitor", function(cmd)
    local moving = input.IsButtonDown(KEY_W) or input.IsButtonDown(KEY_A) or 
                   input.IsButtonDown(KEY_S) or input.IsButtonDown(KEY_D)
    local curTick = globals.TickCount()

    if not moving then
        if state == 0 then
            -- Transition from moving to not moving: trigger the stop.
            client.Command("cyoa_pda_open 1", true)
            state = 1
            stopTick = curTick
        elseif state == 1 and (curTick - stopTick >= toggleDelayTicks) then
            -- After the delay, toggle off the PDA.
            client.Command("cyoa_pda_open 0", true)
            state = 2
        end
    elseif moving and state ~= 0 then
        -- Movement resumed: ensure the PDA is closed and reset state.
        client.Command("cyoa_pda_open 0", true)
        state = 0
    end
end)
