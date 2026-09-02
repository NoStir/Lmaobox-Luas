--===============================================================
--
-- # Discord
-- @ purrspire
--
-- # GitHub
-- @ NoStir
--
-- # Lbox forums
-- @ TimLeary
--
-- Toggle for Trigger Bot
--===============================================================

local key     = "MOUSE_5"          -- toggle key (E_ButtonCode)
local setting = "trigger shoot"  -- setting to toggle

local button    = E_ButtonCode[key]
local last_tick = nil

local function FlipToggle()
    local state = gui.GetValue(setting)
    gui.SetValue(setting, state == 0 and 1 or 0)
    printc(255, 255, 255, 255, setting .. " = " .. tostring(gui.GetValue(setting)))
end

callbacks.Register("CreateMove", "toggle_setting", function(cmd)
    local pressed, tick = input.IsButtonPressed(button)

    if pressed and tick ~= last_tick then
        last_tick = tick
        FlipToggle()
    end
end)
