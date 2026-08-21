-- Pulse the ConTracker (cyoa PDA) on a keypress: opens it, then closes it
-- again on the next tick.
--
-- One tick open is enough for the server to run ItemPostFrame with
-- CanAttack() false, which is what makes the active weapon react. Staying
-- open any longer only costs you movement, since the server zeroes all
-- buttons while the panel is up.

local PULSE_KEY = MOUSE_5

local wasDown = false
local stage = nil
local stageTick = 0

local function KeyEdge()
    local down = input.IsButtonDown(PULSE_KEY)

    if engine.Con_IsVisible() or engine.IsGameUIVisible() or engine.IsChatOpen() then
        wasDown = down
        return false
    end

    local pressed = down and not wasDown
    wasDown = down
    return pressed
end

local function Pulse()
    local me = entities.GetLocalPlayer()
    if not me or not me:IsAlive() then
        stage = nil
        return
    end

    local currentTick = globals.TickCount()

    if stage == nil then
        if KeyEdge() then
            client.Command("cyoa_pda_open 1", true)
            stage, stageTick = "opened", currentTick
        end
    elseif stage == "opened" then
        if currentTick > stageTick then
            client.Command("cyoa_pda_open 0", true)
            stage = nil
        end
    end
end

callbacks.Register("CreateMove", "CyoaPdaPulse", Pulse)

callbacks.Register("Unload", "CyoaPdaPulseUnload", function()
    client.Command("cyoa_pda_open 0", true)
end)
