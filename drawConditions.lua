-- Set up font for drawing text
draw.SetFont(draw.CreateFont("Tahoma", 16, 800))

-- Function to draw information on the screen
local function drawInfo()
    draw.Color(255, 255, 255, 255) -- Set drawing color to white
    local me = entities.GetLocalPlayer() -- Get the local player entity
    if not me then
        return -- Exit if local player entity is not found
    end

    -- Get screen size
    local screenSize = {x = 0, y = 0}
    screenSize.x, screenSize.y = draw.GetScreenSize()

    -- Set initial drawing position
    local drawPOS = {x = screenSize.x * 0.05, y = screenSize.y * 0.20}
    local moveFactorY = 0.05
    local moveFactorX = 0.15

    -- Table to hold information to be displayed
    local Info = {}

    -- Check conditions between -1 and 150
    for condition, index in pairs(E_TFCOND) do
        if me:InCond(index) then
            table.insert(Info, condition .. " (" .. index .. "): true")
        end
    end

    -- Draw the information on the screen
    for _, info in ipairs(Info) do
        draw.Text(drawPOS.x, drawPOS.y, info)
        drawPOS.y = drawPOS.y + (screenSize.y * moveFactorY)

        if drawPOS.y > screenSize.y * 0.80 then
            drawPOS.y = screenSize.y * 0.20
            drawPOS.x = drawPOS.x + (screenSize.x * moveFactorX)
        end
    end
end

-- Register the drawInfo function to be called on the Draw event
callbacks.Register("Draw", drawInfo)