local value = 0 -- Whatever value you want to start with
local font = draw.CreateFont("Verdana", 18, 800)

-- Define the minimum and maximum limits for our value
local MIN_VALUE = 0
local MAX_VALUE = 10

-- Coalesce rapid wheel pulses
local COOLDOWN = 0.12  -- seconds; adjust if needed, but .12 seems to be the sweet spot
local nextAcceptAt = 0
local lastWheelTick = -1

local function now()
    if globals.RealTime then return globals.RealTime() end
    return 0
end

local function clamp(num, min, max)
    return math.min(math.max(num, min), max)
end

-- Derive a single neutral step (-1, 0, +1) from mouse wheel input
local function readWheelStep(t)
    local pressed, tick = input.IsButtonPressed(112) -- 112 = MOUSE_WHEEL_UP so idk why you're using custom?
    if pressed and tick ~= lastWheelTick and t >= nextAcceptAt then
        lastWheelTick, nextAcceptAt = tick, t + COOLDOWN
        return 1
    end
    pressed, tick = input.IsButtonPressed(113) -- 113 = MOUSE_WHEEL_DOWN again so idk why you're using custom?
    if pressed and tick ~= lastWheelTick and t >= nextAcceptAt then
        lastWheelTick, nextAcceptAt = tick, t + COOLDOWN
        return -1
    end
    return 0
end

local function onDraw()
    -- Input handling is skipped while UI is open, but we still draw
    local uiOpen = engine.Con_IsVisible() or engine.IsGameUIVisible()
                or engine.IsChatOpen() or gui.IsMenuOpen()

    if not uiOpen then
        local t = now()
        local step = readWheelStep(t)
        if step ~= 0 then
            -- First, apply the step to the value
            local newValue = value + step
            -- Then, clamp the result to our defined limits
            value = clamp(newValue, MIN_VALUE, MAX_VALUE)
        end
    end

    -- Draw current value + limits for demonstration
    draw.SetFont(font)
    draw.Color(255, 255, 255, 255)
    draw.Text(10, 10, string.format("Value: %d [%d to %d]", value, MIN_VALUE, MAX_VALUE))
end

callbacks.Register("Draw", "mwheel_step_value", onDraw)

-- Cleanup on unload
callbacks.Register("Unload", "mwheel_step_value_unload", function()
    callbacks.Unregister("Draw", "mwheel_step_value")
end)