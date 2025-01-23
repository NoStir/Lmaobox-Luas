-- Variables to manage noisemaker toggling
local noisemakerEndTime = 0

-- Helper function to enable or disable the noisemaker
local function setNoisemakerState(enabled)
    gui.SetValue("Noisemaker Spam", enabled and 1 or 0)
end

-- Frame-based callback to check if noisemaker should be disabled
local function checkNoisemakerToggle()
    if globals.RealTime() >= noisemakerEndTime then
        setNoisemakerState(false)
        callbacks.Unregister("Draw", "CheckNoisemakerToggle")
    end
end

-- Event callback to handle player kills
local function onPlayerKill(event)
    if event:GetName() == "player_death" then
        local attackerIndex = event:GetInt("attacker")
        local localPlayerIndex = client.GetLocalPlayerIndex() + 1

        -- Check if the local player is the attacker
        if attackerIndex == localPlayerIndex then
            setNoisemakerState(true)
            noisemakerEndTime = globals.RealTime() + 1

            -- Register the frame callback
            callbacks.Register("Draw", "CheckNoisemakerToggle", checkNoisemakerToggle)
        end
    end
end

-- Register the event callback
callbacks.Register("FireGameEvent", "AutoTauntOnKill", onPlayerKill)
