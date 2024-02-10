local endTime = 0
local frameCallbackRegistered = false

local function disableNoisemaker()
    gui.SetValue("Noisemaker Spam", 0)
    endTime = 0
    if frameCallbackRegistered then
        callbacks.Unregister("Draw", "CheckNoisemakerToggle")
        frameCallbackRegistered = false
    end
end

local function onPlayerDeath(event)
    if event:GetName() == "player_death" and event:GetInt("attacker") == client.GetLocalPlayerIndex() + 1 then
        gui.SetValue("Noisemaker Spam", 1)
        endTime = globals.RealTime() + 1
        
        if not frameCallbackRegistered then
            callbacks.Register("Draw", "CheckNoisemakerToggle", function()
                if globals.RealTime() >= endTime then
                    disableNoisemaker()
                end
            end)
            frameCallbackRegistered = true
        end
    end
end

callbacks.Register("FireGameEvent", "AutoTauntOnKill", onPlayerDeath)
