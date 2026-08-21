local value = 0
local font = draw.CreateFont("Verdana", 18, 800)

local COOLDOWN = 0.1
local nextAcceptAt = 0

local function readWheelStep()
    local currentTime = globals.CurTime()

    if currentTime < nextAcceptAt then
        return 0
    end

    if input.IsButtonPressed(MOUSE_WHEEL_UP) then
        nextAcceptAt = currentTime + COOLDOWN
        return 1
    end

    if input.IsButtonPressed(MOUSE_WHEEL_DOWN) then
        nextAcceptAt = currentTime + COOLDOWN
        return -1
    end

    return 0
end

local function onCreateMove(cmd)
    if engine.Con_IsVisible() or engine.IsGameUIVisible() or engine.IsChatOpen() or gui.IsMenuOpen() then
        return
    end

    local step = readWheelStep()

    if step ~= 0 then
        value = value + step
    end
end

local function onDraw()
    draw.SetFont(font)
    draw.Color(255, 255, 255, 255)
    draw.Text(10, 10, "Value: " .. value)
end

callbacks.Register("CreateMove", "mwheel_Logic", onCreateMove)
callbacks.Register("Draw", "mwheel_Drawing", onDraw)